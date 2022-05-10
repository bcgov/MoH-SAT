public without sharing class PDFGeneratorController {

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

    public void postToChatter() {
        Id caseId = ApexPages.currentPage().getParameters().get('id');
        Id templateId = ApexPages.currentPage().getParameters().get('templateId');
        String message = String.format(
            'Fax template generated: {0}', new String[] {
            [select Name from EmailTemplate where Id = :templateId].Name
        });

        if (!Test.isRunningTest()) ConnectApi.ChatterFeeds.postFeedElement(null, caseId, ConnectApi.FeedElementType.FeedItem, message);
    }
}