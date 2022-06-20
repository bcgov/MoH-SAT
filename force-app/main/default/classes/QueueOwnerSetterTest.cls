@isTest
public class QueueOwnerSetterTest {

    @TestSetup
    static void makeData() {
        Group testGroup = new Group(Name='TestGroup', DeveloperName='TestGroup', Type='Queue');
        insert testGroup;
        
        system.runAs(new User(Id=UserInfo.getUserId())) {    
            insert new QueueSobject[] { 
                new QueueSObject(QueueId=testGroup.id, SObjectType='Case'), 
                new QueueSObject(QueueId=testGroup.id, SObjectType='Drug__c') 
            };
        }
    }

    @isTest
    static void test_set_owner_to_queue() {
        Case saCase = TestFactory.newCase(new Drug__c(), 'Test case 1');
        insert saCase;

        List<QueueOwnerSetter.CaseQueue> caseQueues = new List<QueueOwnerSetter.CaseQueue>();
        caseQueues.add(newCaseQueue(saCase.Id, 'TestGroup'));

        Test.startTest();
        QueueOwnerSetter.setOwner(caseQueues);
        Test.stopTest();

        system.assertEquals(
            [select Id from Group where DeveloperName = 'TestGroup'].Id,
            [select OwnerId from Case where Id = :saCase.Id].OwnerId
        );
    }
    
    @isTest
    static void test_set_owner_to_non_existing_queue() {
        Case saCase = TestFactory.newCase(new Drug__c(), 'Test case 1');
        insert saCase;

        List<QueueOwnerSetter.CaseQueue> caseQueues = new List<QueueOwnerSetter.CaseQueue>();
        caseQueues.add(newCaseQueue(saCase.Id, 'Non_Existing_Queue'));

        Test.startTest();
        QueueOwnerSetter.setOwner(caseQueues);
        Test.stopTest();

        system.assertEquals(
            UserInfo.getUserId(),
            [select OwnerId from Case where Id = :saCase.Id].OwnerId
        );
    }

    private static QueueOwnerSetter.CaseQueue newCaseQueue(Id caseId, String queueName) {
        QueueOwnerSetter.CaseQueue caseQueue = new QueueOwnerSetter.CaseQueue();
        caseQueue.caseId = caseId;
        caseQueue.queueName = queueName;  
        return caseQueue;
    }
}