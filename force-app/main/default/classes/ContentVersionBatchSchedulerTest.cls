@isTest
private class ContentVersionBatchSchedulerTest {

    @isTest
    static void testExecute() {

        String cronExp = '0 0 0,6,12,18 * * ?';
        ContentVersionBatchScheduler scheduler = new ContentVersionBatchScheduler();
        Test.startTest();
        String jobId = System.schedule('Test Content Version Batch Job', cronExp, scheduler);
 		Test.stopTest();
        
        CronTrigger[] cronTriggers = [SELECT Id, State, CronExpression FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals(1, cronTriggers.size(), 'Job should be scheduled');

    }
}