@isTest
private without sharing class ContentVersionBatchTest {
    
    @testSetup
    static void setupTestData() {
        // Create 3 ContentVersion records
        List<ContentVersion> testVersions = new List<ContentVersion>();
        for (Integer i = 0; i < 3; i++) {
            testVersions.add(new ContentVersion(
                Title = 'Test File ' + i,
                PathOnClient = 'TestFile' + i + '.pdf',
                VersionData = Blob.valueOf('Test Content ' + i)
            ));
        }
        insert testVersions;   
    }

    @isTest
    static void testBatchJob() {
        Test.startTest();
        Database.executeBatch(new ContentVersionBatch(), 3);
        Test.stopTest();

        Integer count = [SELECT COUNT() FROM ContentDistribution];
        System.assertEquals(3, count, 'Only 2 new ContentDistributions should be created.');
    }
}