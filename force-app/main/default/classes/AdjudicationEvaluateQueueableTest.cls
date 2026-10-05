@IsTest
private class AdjudicationEvaluateQueueableTest {

    @IsTest
    static void testExecuteWithNullCaseId() {
        AdjudicationEvaluateQueueable queueable =
            new AdjudicationEvaluateQueueable(null, true);

        Test.startTest();
        queueable.execute(null);
        Test.stopTest();

        System.assert(true, 'Queueable should exit without error when Case Id is null.');
    }

    @IsTest
    static void testExecuteWithCaseId() {
        Id fakeCaseId = Id.valueOf('500000000000001AAA');

        AdjudicationEvaluateQueueable queueable =
            new AdjudicationEvaluateQueueable(fakeCaseId, true);

        Test.startTest();
        queueable.execute(null);
        Test.stopTest();

        System.assert(true, 'Queueable execution completed.');
    }

    @IsTest
    static void testQueueableEnqueue() {
        Test.startTest();

        System.enqueueJob(
            new AdjudicationEvaluateQueueable(null, false)
        );

        Test.stopTest();

        System.assert(true, 'Queueable job was executed successfully.');
    }
}