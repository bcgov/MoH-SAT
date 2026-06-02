public with sharing class SendEmailUtility {
    public Case record { get; set; }
    public Case caseRec { get; set; }
    public static List<MedicationRequest> medRequests { get; set; }
    public static Case recCase { get; set; }
    public List<String> medicationNames { get; set; }
    public String medicationDisplay { get; set; }
    public String Status { get; set; }
    public List<Case> cases;

    /**
     * Constructor used by the Visualforce PDF page.
     * Loads the Case, status parameter, and medication display string.
     */
    public SendEmailUtility(ApexPages.StandardController stdController) {
        this.medicationNames = new List<String>();
        this.medicationDisplay = '';
        this.cases = new List<Case>();

        if (stdController == null || ApexPages.currentPage() == null) {
            return;
        }

        Map<String, String> params = ApexPages.currentPage().getParameters();
        String statusParam = (params != null) ? params.get('parameters') : null;

        List<String> receivedStatuses = new List<String>();
        if (String.isNotBlank(statusParam)) {
            receivedStatuses = statusParam.split(',');
        }

        this.record = (Case) stdController.getRecord();

        if (receivedStatuses == null || receivedStatuses.size() < 2 || String.isBlank(receivedStatuses[0])) {
            return;
        }

        this.cases = [
            SELECT Id, Provider__r.Name, Provider__r.Email, Provider__c,
                   EDRD_MOHFunding_Decision__c, EDRD_Ref_No__c,
                   EDRD_MOHFunding_Start_Date__c, EDRD_MOHFunding_Expiry_Date__c,
                   EDRD_Next_SC_Presentation_Date__c, EDRD_MOHApproved_Dosage__c,
                   EDRD_MOHApproved_Dosage_Unit__r.Name, EDRD_MOHApproved_Frequency__c,
                   EDRD_MOHApproved_Frequency_Unit__c, PNL_Comments__c, Status
            FROM Case
            WHERE Id = :receivedStatuses[0]
            LIMIT 1
        ];

        if (this.cases == null || this.cases.isEmpty()) {
            return;
        }

        this.caseRec = this.cases[0];
        this.Status = receivedStatuses[1];

        if (this.caseRec == null || this.caseRec.Id == null) {
            return;
        }

        for (MedicationRequest medReq : [
            SELECT MedicationId, Medication.Name
            FROM MedicationRequest
            WHERE Case__c = :caseRec.Id
            LIMIT 100
        ]) {
            if (medReq != null && medReq.Medication != null && String.isNotBlank(medReq.Medication.Name)) {
                medicationNames.add(medReq.Medication.Name);
            }
        }

        if (!medicationNames.isEmpty()) {
            medicationDisplay = String.join(medicationNames, ', ');
        }
    }

    /**
     * Sends the notification email, generates the PDF, and saves the PDF as a File on the Case.
     */
    @InvocableMethod(
        label='Send Email from Case'
        description='Processes a list of case and related records passed from flow'
        category='Case Utilities'
    )
    public static void processCases(List<generatePDFParams> caseRecs) {
        if (caseRecs == null || caseRecs.isEmpty() || caseRecs[0] == null) {
            return;
        }

        if (String.isBlank(caseRecs[0].recordId) || String.isBlank(caseRecs[0].caseStatus)) {
            return;
        }

        OrgWideEmailAddress[] owea = [
            SELECT Id
            FROM OrgWideEmailAddress
            WHERE Address = :System.Label.owdEmailforCaseStatusUpdateNotification
            LIMIT 1
        ];

        if (owea == null || owea.isEmpty()) {
            throw new AuraHandledException('Org-wide email address not found.');
        }

        List<Case> caseRecsList = [
            SELECT Id, Provider__c, EDRD_Ref_No__c, Status, EDRD_MOHFunding_Decision__c
            FROM Case
            WHERE Id = :caseRecs[0].recordId
              AND EDRD_MOHFunding_Decision__c = :caseRecs[0].caseStatus
            WITH USER_MODE
            LIMIT 1
        ];

        Case caseRec = (caseRecsList == null || caseRecsList.isEmpty()) ? null : caseRecsList[0];
        if (caseRec == null || caseRec.Id == null) {
            return;
        }

        List<Contact> providers = [
            SELECT Email
            FROM Contact
            WHERE Id = :caseRec.Provider__c
            WITH USER_MODE
            LIMIT 1
        ];

        Contact provider = (providers == null || providers.isEmpty()) ? null : providers[0];
        if (provider == null || String.isBlank(provider.Email)) {
            return;
        }

        List<String> params = new List<String>{ String.valueOf(caseRecs[0].recordId), caseRecs[0].caseStatus };
        PageReference vfPage = new PageReference('/apex/emailPDFTemplate');
        vfPage.getParameters().put('parameters', String.join(params, ','));

        Blob pdfBlob;
        if (Test.isRunningTest()) {
            pdfBlob = Blob.valueOf('Unit Test PDF Content');
        } else {
            pdfBlob = vfPage.getContentAsPDF();
        }

        if (pdfBlob == null) {
            return;
        }

        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setFileName('PNL_' + caseRec.EDRD_Ref_No__c + '.pdf');
        attachment.setBody(pdfBlob);
        attachment.setContentType('application/pdf');
        
        List<EmailTemplate> emailTemplate = [
            SELECT Id, Subject, Description, Body 
            FROM EmailTemplate 
            WHERE DeveloperName ='EDRD_Physician_Notification_1780429755402' 
            LIMIT 1
        ];
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setOrgWideEmailAddressId(owea[0].Id);
        email.setTargetObjectId(provider.Id);
        email.setWhatId(caseRec.Id);
        if(!emailTemplate.isEmpty()){email.setTemplateId(emailTemplate[0].Id);}
        email.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });
        Messaging.SendEmailResult[] results =
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        if (results == null || results.isEmpty() || !results[0].isSuccess()) {
            return;
          }
          
        ContentVersion conVersion = new ContentVersion();
        conVersion.Title = 'PNL_' + caseRec.EDRD_Ref_No__c;
        conVersion.PathOnClient = 'ApexGeneratedFile.pdf';
        conVersion.VersionData = pdfBlob;
        conVersion.IsMajorVersion = true;
        insert conVersion;

        Id conDocumentId = [
            SELECT ContentDocumentId
            FROM ContentVersion
            WHERE Id = :conVersion.Id
        ].ContentDocumentId;

        if (conDocumentId == null) {
            return;
        }

        ContentDocumentLink conDocLink = new ContentDocumentLink();
        conDocLink.ContentDocumentId = conDocumentId;
        conDocLink.LinkedEntityId = caseRec.Id;
        conDocLink.ShareType = 'V';
        conDocLink.Visibility = 'AllUsers';
        insert conDocLink;
    }

    /**
     * Wrapper class used by Flow to pass input values into the invocable method.
     */
    public class generatePDFParams {
        public generatePDFParams() {}

        @InvocableVariable(required = true)
        public String caseStatus;

        @InvocableVariable(required = true)
        public Id recordId;
    }
}