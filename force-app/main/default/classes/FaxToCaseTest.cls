@isTest
public class FaxToCaseTest {

    @isTest
    static void test_convert(){
        Fax_File__c fax = new Fax_File__c();
        fax.Status__c = 'Open'; 
        insert fax;

        ContentVersion cv = new ContentVersion();
        cv.Title = 'test.pdf';
        cv.PathOnClient ='test.pdf';
        cv.VersionData =Blob.toPdf('Unit Test Attachment Body');
        cv.FirstPublishLocationId = fax.Id;
        insert cv;

        Case caseRecord = new Case();
        insert caseRecord;

        FaxToCase.FaxAndCaseId param = new FaxToCase.FaxAndCaseId();
        param.faxId = fax.Id;
        param.caseId = caseRecord.Id;

        Test.startTest();
        FaxToCase.convert(new FaxToCase.FaxAndCaseId[] {param});
        Test.stopTest();

        fax = [select Id, Status__c from Fax_File__c where Id = :fax.Id];
        system.assertEquals('Converted', fax.Status__c);

        cv = [select Id, ContentDocumentId from ContentVersion where Id = :cv.Id];

        ContentDocumentLink cdl = [
            select Id 
            from ContentDocumentLink 
            where LinkedEntityId = :caseRecord.Id
            and ContentDocumentId = :cv.ContentDocumentId
        ];

        system.assert(cdl != null);
    }

}