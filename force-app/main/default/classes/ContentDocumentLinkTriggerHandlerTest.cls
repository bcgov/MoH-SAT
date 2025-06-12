/**********************************************************************************************
* @Author:      Accenture 
* @Date:        15 Jan 2025
* @Description: The purpose of this class is to cover Code coverage of ContentDocumentLinkTriggerHandler.
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]  
                21-Jan -  EDRD-1112         -  Deepak      -  Test Method for getDocumentGenerated & deleteDocumentGenerated.
***********************************************************************************************/
@isTest
public class ContentDocumentLinkTriggerHandlerTest {
    
/**
* @author: Deepak
* @date: 21 Jan 2025
* @description: The purpose of this method is to cover Testcoverage of getDocumentGenerated & deleteDocumentGenerated.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/        
    @isTest
    public static void getNDeleteDocumentGenerated_Test(){
        Account prescriberAccount = TestFactory.newProvider('Provider Test');
        insert prescriberAccount;
        Id recordTypeCaseEDRD = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('EDRD').getRecordTypeId();
        List<Case> caseRecord = TestFactory.createEDRDCase(1, recordTypeCaseEDRD, prescriberAccount.Id);
        insert caseRecord;
        Assessment assessmentRecord = TestFactory.createEDRDAssessment(caseRecord[0].Id);
        insert assessmentRecord;
        DocumentTemplate testDocumentTemplate = new DocumentTemplate(Name = 'EDRD BC DocGen-Template',
                                                                     Type = 'MicrosoftWord',
                                                                     TokenMappingType = 'JSON',
                                                                     TokenMappingMethodType = 'CustomClass',
                                                                     CustomClassName = 'EDRD_cls_generatePDFDoc');
        insert testDocumentTemplate;
        
        ContentVersion testContentVersionRec = new ContentVersion( Title = 'EDRD BC DocGen-Template',
                                                                  PathOnClient = 'TestDoc.pdf',
                                                                  VersionData = Blob.valueOf('Test content'),
                                                                  IsMajorVersion = true); 
        insert testContentVersionRec;
        
        EDRD_cls_generatePDFDoc.requestText = label.EDRD_label_DocGen_requestText.replace('CVID', testContentVersionRec.Id);
        
        Map<String, String> keyVsValue = new Map<String, String>{ 'TOKENDATA' => 'TestTokenData', 'RECORDID' => assessmentRecord.Id};
            
        Test.startTest();                
        EDRD_cls_generatePDFDoc.createDocumentGenerationProcessRequest(keyVsValue);        
        Test.stopTest();
        
        List<ContentVersion> ContentVersions = [SELECT Id FROM ContentVersion WHERE Id =: testContentVersionRec.Id];
        Assert.areEqual(1, ContentVersions.size(), 'The ContentVersion should not be deleted.');
        
        List<DocumentTemplate> existingTemplates = [SELECT Id FROM DocumentTemplate WHERE Name = 'EDRD BC DocGen-Template'];
        Assert.areNotEqual(0, existingTemplates.size(), 'The DocumentTemplate should not be deleted.');
        
    }
      @isTest
    static void testGetDocumentGenerated_deletesMatchingDocs() {
        // Create a dummy user (prefix '005') to simulate LinkedEntityId
        User u = new User(
            Alias = 'testu',
            Email = 'testuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'User',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = UserInfo.getProfileId(),
            TimeZoneSidKey = 'America/New_York',
            Username = 'testuser' + DateTime.now().getTime() + '@example.com'
        );
        insert u;

        // Step 1: Create a ContentVersion (which auto-creates a ContentDocument)
        ContentVersion cv = new ContentVersion(
            Title = 'Eform Responses',
            PathOnClient = 'test.docx',
            VersionData = Blob.valueOf('Test Content')
        );
        insert cv;

        // Retrieve the associated ContentDocumentId
        Id contentDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;

        // Step 2: Create a ContentDocumentLink (simulate upload to a record, e.g. User)
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = contentDocId,
            LinkedEntityId = u.Id, // starts with '005' in tests
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert cdl;

        // Step 3: Call method under test
        Test.startTest();
        ContentDocumentLinkTriggerHandler.getDocumentGenerated(new List<ContentDocumentLink>{ cdl });
        Test.stopTest(); // ensures @future runs

        // Step 4: Verify the document was deleted
        List<ContentDocument> remainingDocs = [SELECT Id FROM ContentDocument WHERE Id = :contentDocId];
        System.assertEquals(0, remainingDocs.size(), 'ContentDocument should have been deleted');
    }

    @isTest
    static void testGetDocumentGenerated_skipsNonMatchingEntity() {
        // Create another ContentVersion
        ContentVersion cv = new ContentVersion(
            Title = 'Eform Responses',
            PathOnClient = 'nonmatch.docx',
            VersionData = Blob.valueOf('Other Content')
        );
        insert cv;

        Id contentDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;

        // Simulate a record with a prefix NOT starting with '005' (e.g. Case: '500')
        Case fakeCase = new Case(Subject = 'Test Case');
        insert fakeCase;

        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = contentDocId,
            LinkedEntityId = fakeCase.Id, // starts with '500' (will be ignored in test)
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert cdl;

        // Call method under test
        Test.startTest();
        ContentDocumentLinkTriggerHandler.getDocumentGenerated(new List<ContentDocumentLink>{ cdl });
        Test.stopTest();

        // Since prefix in test mode is '005', nothing should be deleted
        List<ContentDocument> remainingDocs = [SELECT Id FROM ContentDocument WHERE Id = :contentDocId];
        System.assertEquals(1, remainingDocs.size(), 'ContentDocument should NOT have been deleted');
    }
}