@IsTest
private class AdjudicationEvaluateQueueableTest {

    private static final String CASE_SUBJECT = 'Test case 1';

    // Creates the queue, a Drug owned by it, and a Case with triggers disabled.
    @TestSetup
    static void setup() {
        Group testGroup = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'General_Queue' LIMIT 1];

        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert new QueueSobject[] {
                new QueueSobject(QueueId = testGroup.Id, SObjectType = 'Case'),
                new QueueSobject(QueueId = testGroup.Id, SObjectType = 'Drug__c')
            };
        }

        Drug__c drug = TestFactory.newDrug('Drug 1');
        drug.OwnerId = testGroup.Id;
        insert drug;

        SaSettings.disableTriggers(); 
        Case saCase = TestFactory.newCase(drug, CASE_SUBJECT);
        insert saCase;
        SaSettings.enableTriggers();
    }

    // Safety-net mock: returns a 200 JSON response if the service ever makes a callout.
    private class Mock implements HttpCalloutMock {

        // Returns a 200 JSON response for any request.
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{}');
            return res;
        }
    }

    // Looks up the Id of the Case created in test setup.
    private static Id testCaseId() {
        return [SELECT Id FROM Case WHERE Subject = :CASE_SUBJECT LIMIT 1].Id;
    }

    // Returns the current owner of the given Case.
    private static Id ownerOf(Id caseId) {
        return [SELECT OwnerId FROM Case WHERE Id = :caseId].OwnerId;
    }

    // Returns the owner of the Drug that the test Case belongs to.
    private static Id drugOwnerId() {
        return [SELECT OwnerId FROM Drug__c LIMIT 1].OwnerId;
    }

    // Runs execute() directly and returns the exception it threw, or null if it completed cleanly.
    private static Exception run(Id caseId, Boolean assignOwner) {
        Test.setMock(HttpCalloutMock.class, new Mock());
        Exception thrown;
        Test.startTest();
        try {
            new AdjudicationEvaluateQueueable(caseId, assignOwner).execute(null);
        } catch (Exception e) {
            thrown = e;
        }
        Test.stopTest();
        return thrown;
    }

    // Asserts that a run completed without throwing, surfacing the message if it did not.
    private static void assertSucceeded(Exception thrown) {
        Assert.isNull(thrown, 'Evaluation should succeed: ' + (thrown == null ? '' : thrown.getMessage()));
    }

    // A null Case Id returns early: no exception and the Case is untouched.
    @IsTest
    static void testExecuteWithNullCaseId() {
        Id caseId = testCaseId();
        Id ownerBefore = ownerOf(caseId);

        Exception thrown = run(null, true);

        Assert.isNull(thrown, 'Null Case Id should return silently');
        Assert.areEqual(ownerBefore, ownerOf(caseId), 'Case owner must not change');
    }

    // With assignOwner = true the Case is reassigned to the Drug's owner queue.
    @IsTest
    static void testExecuteSuccess_AssignOwnerTrue() {
        Id caseId = testCaseId();

        assertSucceeded(run(caseId, true));

        Assert.areEqual(drugOwnerId(), ownerOf(caseId), 'Case should be owned by the Drug owner queue');
    }

    // With assignOwner = false the Case owner is left unchanged.
    @IsTest
    static void testExecuteSuccess_AssignOwnerFalse() {
        Id caseId = testCaseId();
        Id ownerBefore = ownerOf(caseId);

        assertSucceeded(run(caseId, false));

        Assert.areEqual(ownerBefore, ownerOf(caseId), 'Case owner must not change when assignOwner is false');
    }

    // Runs through System.enqueueJob to prove the queueable works in a real async context.
    @IsTest
    static void testEnqueueJob_Success() {
        Id caseId = testCaseId();
        Test.setMock(HttpCalloutMock.class, new Mock());

        Test.startTest();
        System.enqueueJob(new AdjudicationEvaluateQueueable(caseId, true));
        Test.stopTest();

        Assert.areEqual(drugOwnerId(), ownerOf(caseId), 'Enqueued job should reassign the Case owner');
    }

    // A Drug owner queue that cannot own Cases makes the Case update fail with a DmlException.
    @IsTest
    static void testExecuteDmlException_QueueCannotOwnCase() {
        Group drugOnlyQueue = new Group(Name = 'Drug Only Queue', DeveloperName = 'Drug_Only_Queue', Type = 'Queue');
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert drugOnlyQueue;
            insert new QueueSobject(QueueId = drugOnlyQueue.Id, SObjectType = 'Drug__c'); // no Case support
        }

        Drug__c drug = [SELECT Id FROM Drug__c LIMIT 1];
        drug.OwnerId = drugOnlyQueue.Id;
        update drug;

        Id caseId = testCaseId();
        Id ownerBefore = ownerOf(caseId);

        Exception thrown = run(caseId, true);

        Assert.isNotNull(thrown, 'DmlException should be rethrown');
        Assert.isInstanceOfType(thrown, DmlException.class, 'Expected DmlException but got ' + thrown.getTypeName());
        Assert.areEqual(ownerBefore, ownerOf(caseId), 'Failed update must not change the Case owner');
    }

    // A Case deleted before the service queries it surfaces as a QueryException.
    @IsTest
    static void testExecuteQueryException_CaseDeleted() {
        Id caseId = testCaseId();
        delete new Case(Id = caseId);

        Exception thrown = run(caseId, true);

        Assert.isNotNull(thrown, 'QueryException should be rethrown for a missing Case');
        Assert.isInstanceOfType(thrown, QueryException.class, 'Expected QueryException but got ' + thrown.getTypeName());
    }

    // A null assignOwner is an attempt to reach the generic catch (e.g. a NullPointerException in the service).
    @IsTest
    static void testExecuteGenericException_NullAssignOwner() {
        Exception thrown = run(testCaseId(), null);

        Assert.isTrue(
            thrown == null || !(thrown instanceof DmlException || thrown instanceof QueryException),
            'Any failure here should be handled by the generic catch, but got ' + (thrown == null ? 'none' : thrown.getTypeName())
        );
    }
}