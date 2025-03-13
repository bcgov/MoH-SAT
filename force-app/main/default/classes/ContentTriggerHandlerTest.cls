@isTest
public class ContentTriggerHandlerTest {
 /* @isTest
  
  public static void ContentTriggerHandlerTest() {
    Case record = TestFactory.createCase();
    insert record;
    Blob beforeblob=Blob.valueOf('Unit Test Attachment Body');

    ContentVersion cv = new ContentVersion();
    cv.Title = 'test content trigger';
    cv.PathOnClient ='test';
    cv.VersionData =beforeblob;
    insert cv;

    ContentVersion testContent = [SELECT id, Title, ContentDocumentId FROM ContentVersion where Id = :cv.Id];

    ContentDocumentLink contentlink=new ContentDocumentLink();
    contentlink.LinkedEntityId=record.id;
    contentlink.ShareType= 'C';
    contentlink.LinkedEntityId = record.Id;
    contentlink.ContentDocumentId=testcontent.ContentDocumentId;
    contentlink.Visibility = 'AllUsers';

    List<ContentVersion> cvl = new List<ContentVersion>();
    cvl.add(testContent);

    ContentTriggerHandler.createPublicLinkForFile(cvl);
  }
    */
}