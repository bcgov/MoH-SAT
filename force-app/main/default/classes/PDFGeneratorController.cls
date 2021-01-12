public class PDFGeneratorController {

    public Case caseRecord {get;set;}
    public String html {get;set;}

    public PDFGeneratorController() {

        // Link is: /apex/PDFGenerator?id=5000i000000sRHRAA2

        caseRecord = [SELECT Id, Subject, Drug__r.name
        FROM Case
        WHERE Id = :ApexPages.currentPage().getParameters().get('id')];

        // Passed in email EmailTemplateId/contactId/caseId
        Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate('00X0i000000dP30EAE', UserInfo.getUserId(), caseRecord.Id);
        html = email.getHTMLBody();
    }
}