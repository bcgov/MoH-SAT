/**

1. Please create 1 Date/time field,Fax Sent, and stamp it here. 
2. Continue testing our bulkified call to WS.
3. Invoke sendFax(caseIds) from flow/process builder - ask jan/sadhana/anshul
4. Run functional tests below

TEST: Does "send fax" button still work
- Does it call WS
- Does it assign to Queue?
- Does it timestamp?
- Are errors handled?

TEST: Update a case so its approved and pushed to pnet 
- Does it call WS
- Does it assign to Queue?
- Does it timestamp?
- How are errors handled. Can users see them right away?

TEST: Bulk operations 
- Mass update 2 or more cases to approved and pushed to pnet
--- write an anonymous apex that updates cases 2, 10, 20, 100. what's the limit?
*/

public with sharing class FaxService {
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

    public static List<String> HARDCODED_EMAILS = new List<String>{
        'fcemailservice@3-41bw7asxl2wnqbetbivafaggrgp1zsy6cstktlpt9h7w7pr3e.1f-9nzxeaq.cs99.apex.sandbox.salesforce.com',
        'afreen.fatima.ahmed@pwc.com',
         'jan.j.julian@pwc.com'
    };
   
    @AuraEnabled(cacheable=false)
    public static void sendFax(Id caseId, Id templateId) {
        Case record = queryCases(new Id[] {caseId})[0];

        FaxService.Payload payload = buildPayload(
            record.ID,
            record.CaseNumber,
            record.Provider_Fax__c,
            record.Provider__r.Name,
            generatePdf(record.Id,templateId),
            HARDCODED_EMAILS
        );
       
        try {
            sendFax(new FaxService.Payload[] {payload});
        }
        catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
        }
        return;
    }

    @InvocableMethod(label='Send fax to Accuroute' description='Send fax to Accuroute.')
    public static void sendFax(List<Id> caseIds) {
        Map<Id, Case> caseMap = new Map<Id, Case>(queryCases(caseIds));

        List<FaxService.Payload> payloads = new List<FaxService.Payload>();
        
        for (Id caseId : caseIds) {
            Case record = caseMap.get(caseId);
            EmailTemplate emailTemplate = getEmailTemplate(record.status, record.Drug__r.Drug_Code__c);

            FaxService.Payload payload = buildPayload(
                record.Id,
                record.CaseNumber,
                record.Provider_Fax__c,
                record.Provider__r.Name,
                generatePdf(caseId,emailTemplate.id),
                HARDCODED_EMAILS
            );

            payloads.add(payload);
        }

        sendFax(payloads);
    }

    private static void sendFax(List<FaxService.Payload> payloads) {
        List<FaxService.FcResponse> fcResponses = sendHttpRequest(payloads);
        
        if (!evaluateFcResponse(fcResponses)) {
            throw new FaxServiceException('Erroneous payload.');
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
            throw new FaxServiceException(e);
        }

        if (res.getStatusCode() != 200) {
            throw new FaxServiceException(res.getBody());
        }

        List<FaxService.FcResponse> fcResponses = 
            (List<FaxService.FcResponse>) JSON.deserialize(res.getBody(), List<FaxService.FcResponse>.class);

         return fcResponses;
    }
    @TestVisible
    private static Boolean evaluateFcResponse(List<FaxService.FcResponse> fcResponses) {
        for (FaxService.FcResponse fcResponse : fcResponses) {
            if (fcResponse.status == 'fail') {
                return false;
            }
        }
        return true;
    }
    @TestVisible
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
    @TestVisible
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
            select Id, CaseNumber, status,Provider_Fax__c,Provider__r.name, Drug__r.Drug_Code__c 
            from Case 
            where Id in :caseIds 
        ]);
    }

    @TestVisible
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
        Blob pdf=ref.getContent();
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
