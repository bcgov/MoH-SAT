@isTest
public with sharing class PdfViewerTest {
    @isTest
    static void test_get_pdf() {
        Fax_File__c record = new Fax_File__c();
        record.Status__c = 'Open'; 
        insert record;

        ContentVersion cv = new ContentVersion();
        cv.Title = 'test.pdf';
        cv.PathOnClient ='test.pdf';
        cv.VersionData =Blob.toPdf('Unit Test Attachment Body');
        cv.FirstPublishLocationId = record.Id;
        insert cv;

        Test.startTest();
        PdfViewer.File file = PdfViewer.getPdf(record.Id);
        Test.stopTest();

        system.assertEquals(cv.Title, file.title);
    }
}