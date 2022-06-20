@isTest
public with sharing class OwnerAssignmentTest {
    @isTest
    static void test_action() {
        SpecialAuthorityRequest sar = TestFactory.newSpecialAuthorityRequest();
        StepAction stepAction = newAction(TestFactory.newId(Group.getSObjectType()));

        Test.startTest();
        Action action = new OwnerAssignment();
        action.execute(sar, stepAction);
        Test.stopTest();
        
        system.assertEquals(sar.saCase.OwnerId, stepAction.ownerId);
    }

    private static StepAction newAction(Id ownerId) {
        return new StepAction(ownerId);
    }
}