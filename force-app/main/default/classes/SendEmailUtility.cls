public class SendEmailUtility{
        public Case record{get; set;}
        public Case caseRec{get;set;}
        public static  List<MedicationRequest> medRequests{get;set;}
        public static  Case recCase{get;set;}
        public List<String> medicationNames{get;set;}
        public String medicationDisplay {get;set;}
        public String Status{get;set;}

    public SendEmailUtility(ApexPages.StandardController stdController) {
    
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String statusParam = params.get('parameters');
        
        List<String> receivedStatuses = new List<String>();
            if (String.isNotBlank(statusParam)) {
                receivedStatuses = statusParam.split(',');
            }
        
        
        this.record = (Case)stdController.getRecord();
        
        this.caseRec = [Select Id,Provider__r.Name,Provider__r.Email, Provider__c,EDRD_MOHFunding_Decision__c,EDRD_Ref_No__c,EDRD_MOHFunding_Start_Date__c,
        EDRD_MOHFunding_Expiry_Date__c,EDRD_Next_SC_Presentation_Date__c,EDRD_MOHApproved_Dosage__c,EDRD_MOHApproved_Dosage_Unit__r.name,
        EDRD_MOHApproved_Frequency__c,EDRD_MOHApproved_Frequency_Unit__c,PNL_Comments__c,Status
        from Case where Id =: receivedStatuses[0]];
        this.Status = receivedStatuses[1]; 
        this.medicationNames = new List<String>();
        for(MedicationRequest medReq : [SELECT MedicationId,Medication.Name from MedicationRequest  where Case__c =: caseRec.Id]){
            medicationNames.add(medReq.Medication.Name);
        }
        medicationDisplay = String.join(medicationNames, ', ');
    }

 
    
    @InvocableMethod(
    label='Send Email from Case'
    description='Processes a list of case and related records passed from flow'
    category='Case Utilities'
)
public static void processCases(List<generatePDFParams> caseRecs) {
    if (caseRecs == null || caseRecs.isEmpty()) {
        return;
    }

    OrgWideEmailAddress[] owea = [
        SELECT Id
        FROM OrgWideEmailAddress
        WHERE Address = 'noreply@hlthsa.gov.bc.ca'
        LIMIT 1
    ];
    if (owea.isEmpty()) {
        throw new AuraHandledException('Org-wide email address not found.');
    }
        // If you need fresh fields for the VF page, query the full Case here
        Case caseRec = [
            SELECT Id, Provider__c, EDRD_Ref_No__c,Status,EDRD_MOHFunding_Decision__c
            FROM Case
            WHERE Id = :caseRecs[0].recordId AND EDRD_MOHFunding_Decision__c =: caseRecs[0].caseStatus
            LIMIT 1
        ];

        Contact provider = [
            SELECT Email
            FROM Contact
            WHERE Id = :caseRec.Provider__c
            LIMIT 1
        ];
        List<String> params = new List<String>{caseRecs[0].recordId,caseRecs[0].caseStatus};
        PageReference vfPage = new PageReference('/apex/emailPDFTemplate');
        vfPage.getParameters().put('parameters', String.join(params, ','));

        Blob pdfBlob;
        
        if (Test.isRunningTest()) {
            pdfBlob = Blob.valueOf('Unit Test PDF Content');
        }else{
            pdfBlob = vfPage.getContentAsPDF();
        }

        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setFileName('PNL_' + caseRec.EDRD_Ref_No__c + '.pdf');
        attachment.setBody(pdfBlob);
        attachment.setContentType('application/pdf');

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setOrgWideEmailAddressId(owea[0].Id);
        email.setToAddresses(new String[] { provider.Email });
        email.setSubject('EDRD Physician Notification Letter – ' + caseRec.EDRD_Ref_No__c);
        email.setPlainTextBody(
            'Attached: PNL_' + caseRec.EDRD_Ref_No__c + '\n' +
            'Please see the attached letter outlining the Ministry’s decision regarding your patient’s EDRD coverage.\n' +
            'This is an automated message and this inbox is not monitored. For inquiries, please contact psp@phsa.ca.'
        );
        email.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });

        Messaging.SendEmailResult[] results =
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });

        if (results != null && !results.isEmpty() && results[0].isSuccess()) {
            Attachment legacyAttachment = new Attachment();
            legacyAttachment.Body = pdfBlob;
            legacyAttachment.Name = 'PNL_' + caseRec.EDRD_Ref_No__c + '.pdf';
            legacyAttachment.ParentId = caseRec.Id;
            insert legacyAttachment;
        }
}

public class generatePDFParams{
    public generatePDFParams(){}
    @invocableVariable( required = true)
    public String caseStatus;
    
    @InvocableVariable(required=true)
    public Id recordId;
}

}