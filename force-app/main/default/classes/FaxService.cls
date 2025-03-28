public with sharing class FaxService implements Queueable, Database.AllowsCallouts {
    private List<Id> caseIds;

    public FaxService(List<Id> caseIds) {
        this.caseIds = caseIds;
    }

    public void execute(QueueableContext context) {
        runSendFax(caseIds);
    }

    private static Map<String, EmailTemplate> EMAIL_TEMPLATES {
        get {
            if (EMAIL_TEMPLATES == null) {
                EMAIL_TEMPLATES = new Map<String, EmailTemplate>();
                for (EmailTemplate ET : FolderUtility.getTemplates()) {
                    EMAIL_TEMPLATES.put(ET.DeveloperName, ET);
                }
            }
            return EMAIL_TEMPLATES;
        }
        set;
    }

    private static List<String> MY_EMAILS {
        get {
            if (MY_EMAILS == null) {
                MY_EMAILS = new List<String>();                
                for (EmailServicesAddress esa : queryEmailServiceAddresses()) {
                    MY_EMAILS.add(esa.LocalPart+'@'+esa.EmailDomainName);
                }
            }

            return MY_EMAILS;
        }
        set;
    }
   
    @AuraEnabled(cacheable=false)
    public static void sendFax(Id caseId, Id templateId) {
        Case record = queryCases(new Id[] {caseId})[0];

        if (record.Provider_Fax__c == null) 
            throw new AuraHandledException('Missing Provider Fax.');
        
        FaxService.Payload payload = buildPayload(
            record.ID,
            record.CaseNumber,
            record.Provider_Fax__c,
            getRecipientName(record),
            generatePdf(record.Id,templateId),
            MY_EMAILS
        );
       
        try {
            sendFax(new FaxService.Payload[] {payload});

        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @InvocableMethod(label='Send fax to Accuroute' description='Send fax to Accuroute.') 
    public static void sendFax(List<Id> caseIds) {
        System.enqueueJob(new FaxService(caseIds));
    }
    
    private static void runSendFax(List<Id> caseIds) {
        Map<Id, Case> caseMap = new Map<Id, Case>(queryCases(caseIds));

        List<FaxService.Payload> payloads = new List<FaxService.Payload>();
        
        for (Id caseId : caseIds) {
            Case record = caseMap.get(caseId);
            EmailTemplate emailTemplate = getEmailTemplate(record.status, record.Drug__r.Drug_Code__c);

            FaxService.Payload payload = buildPayload(
                record.Id,
                record.CaseNumber,
                record.Provider_Fax__c,
                getRecipientName(record),
                generatePdf(caseId,emailTemplate.id),
                MY_EMAILS
            );

            payloads.add(payload);
        }

        sendFax(payloads);
    }
    @TestVisible
    private static void sendFax(List<FaxService.Payload> payloads) {

        List<FaxService.FcResponse> fcResponses = sendHttpRequest(payloads);
        
        if (!evaluateFcResponse(fcResponses)) {
           throw new FaxServiceException('Invalid Payload');
        }

        assignToQueue(payloads);
        setFaxSentDates(payloads);
    }
    
    @TestVisible
    private static List<FaxService.FcResponse> sendHttpRequest(List<FaxService.Payload> load){
        HttpRequest req = new HttpRequest();
        req.setBody(JSON.serialize(load));
        req.setEndpoint('callout:FilescanConnectWs/SA/sf2fsc');
        req.setMethod('POST');
        
        HttpResponse res;

        try {
            res = new Http().send(req);
        }
        catch (Exception e){
            throw e;
        }

        if (res.getStatusCode() != 200) {
            throw new FaxServiceException(res.getBody());
        }


        List<FaxService.FcResponse> fcResponses = 
            (List<FaxService.FcResponse>) JSON.deserialize(res.getBody(), List<FaxService.FcResponse>.class);
            
        return fcResponses;
    }
    
    private static Boolean evaluateFcResponse(List<FaxService.FcResponse> fcResponses) {
        for (FaxService.FcResponse fcResponse : fcResponses) {
            if (fcResponse.status == 'fail') {
                return false;
            }
        }
        return true;
    }
   
    private static void assignToQueue(List<FaxService.Payload> payloads) {
        List<QueueOwnerSetter.CaseQueue> caseQueues = new List<QueueOwnerSetter.CaseQueue>();
        
        for (FaxService.Payload payload : payloads) {
            QueueOwnerSetter.CaseQueue queue = new QueueOwnerSetter.CaseQueue();
            queue.caseId = payload.caseId;
            queue.queueName = 'Regular';
            caseQueues.add(queue);
        }    
        
        QueueOwnerSetter.setOwner(caseQueues);
    }
    
    private static void setFaxSentDates(List<FaxService.Payload> payloads) {
        List<Case> cases = new List<Case>();
        for (FaxService.Payload payload : payloads) {
            Case record = new Case();
            record.Id = payload.caseId;
            record.Fax_Sent_Date__c = Datetime.now();
            cases.add(record);
        }
        update cases;
    }
    
    private static List<Case> queryCases(List<Id> caseIds) {
        return new List<Case>([
            select Id, CaseNumber, status,Provider_Fax__c,Provider__r.name,DEC__r.name, Drug__r.Drug_Code__c 
            from Case 
            where Id in :caseIds
        ]);
    }

    private static String getRecipientName(Case record) {
        if (record.Provider__r != null) return record.Provider__r.Name;
        else if (record.DEC__r != null) return record.DEC__r.Name; 
        else return 'NO_RECIPIENT_NAME';
     }

    private static List<EmailServicesAddress> queryEmailServiceAddresses() {
        return [
            SELECT Id, LocalPart, EmailDomainName 
            FROM EmailServicesAddress 
            WHERE DeveloperName in ('FcEmailservice') 
            AND IsActive=true
        ];
    }

    
    private static EmailTemplate getEmailTemplate(String status, String drugCode) {
        if (status == 'Approved' && drugCode == 'omnipod') return EMAIL_TEMPLATES.get('Insulin_Pump_Approval_Letter_Omnipod');
        else if (status == 'Approved' && drugCode == 'ypsopump') return EMAIL_TEMPLATES.get('Insulin_Pump_Approval_Letter_YpsoPump');
        else if (status == 'Approved' && drugCode == 'minimed') return EMAIL_TEMPLATES.get('Insulin_Pump_Approval_Letter_Medtronic');
        else if (status == 'Approved') return EMAIL_TEMPLATES.get('Approved_Fax_Template');
        else if (status == 'Not Approved') return EMAIL_TEMPLATES.get('Not_Approved_Fax_Template');
        else if (status == 'Currently Approved') return EMAIL_TEMPLATES.get('Currently_Approved_Fax_Template');
        else if (status.containsIgnoreCase('MIR') || status.contains('More Information Requested')) return EMAIL_TEMPLATES.get('MIR_Fax_Template');
        else return null;
    }

    @TestVisible
    private static String generatePdf(ID caseId, ID templateId){
        PageReference ref=Page.PDFGenerator;
        ref.getParameters().put('templateId',templateId);
        ref.getParameters().put('Id',caseId);
        Blob pdf;
        if(Test.IsRunningTest()) {
            pdf=Blob.valueOf('UNIT.TEST');
        }
        else {
            pdf=ref.getContent();
        } 
        return EncodingUtil.base64encode(pdf);
    }

   @TestVisible
    private static FaxService.Payload buildPayload(
            Id caseId, 
            String caseNumber, 
            String faxNumber, 
            String recepientName, 
            String attachment, 
            List<String> emails) {
        FaxService.Payload payload=new FaxService.Payload();
        payload.caseId = caseId;
        payload.caseNumber = caseNumber;
        payload.faxNumber = faxNumber; 
        payload.recepientName = recepientName;
        payload.attachment = attachment;
        payload.emails = emails;
        return payload;
    }
@TestVisible
    public class Payload {
        public Id caseId;
        public String caseNumber;
        public String faxNumber;
        public String recepientName;
        public String attachment;
        public List<String> emails;
    }

    public class FcResponse {
        public String status;
        public String error;
    }

    public class FaxServiceException extends Exception {}
}