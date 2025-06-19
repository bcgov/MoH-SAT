@isTest
private class RelatedFilesTest {

    @isTest
    static void testGetRelatedFiles() {
        // Step 1: Create a test Case
        Case testCase = new Case(Subject = 'Test Case');
        insert testCase;

        // Step 2: Create a ContentVersion (creates ContentDocument automatically)
        ContentVersion cv = new ContentVersion(
            Title = 'Test File',
            PathOnClient = 'TestFile.txt',
            VersionData = Blob.valueOf('Test file content')
        );
        insert cv;

        // Step 3: Get the associated ContentDocument
        ContentVersion insertedCV = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        Id contentDocId = insertedCV.ContentDocumentId;

        // Step 4: Create ContentDocumentLink to link document to the case
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = contentDocId,
            LinkedEntityId = testCase.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert cdl;

        // Step 5: Create ContentDistribution for the ContentVersion
        ContentDistribution cd = new ContentDistribution(
            Name = 'Test Distribution',
            ContentVersionId = insertedCV.Id,
            PreferencesAllowViewInBrowser = true
        );
        insert cd;

        // Step 6: Call the method under test
        Test.startTest();
        List<RelatedFiles.RelatedFilesDownload> results = RelatedFiles.getRelatedFiles(testCase.Id);
        Test.stopTest();

        // Step 7: Assert the results
        System.assertNotEquals(0, results.size(), 'Expected at least one related file');
    }
}
