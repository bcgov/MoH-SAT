public class PDFGeneratorController {

    public Case caseRecord {get;set;}
    public String html {get;set;}

    public PDFGeneratorController() {
        // Link is: /apex/PDFGenerator?id=xxx&templateId=xxx
        caseRecord = [SELECT Id, Subject, Drug__r.name
                      FROM Case
                      WHERE Id = :ApexPages.currentPage().getParameters().get('id')];

        Id templateId = ApexPages.currentPage().getParameters().get('templateId');

        // Passed in email EmailTemplateId/contactId/caseId
        Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(templateId, UserInfo.getUserId(), caseRecord.Id);
        html = email.getHTMLBody();
    }
}