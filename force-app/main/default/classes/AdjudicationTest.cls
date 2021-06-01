@isTest
public with sharing class AdjudicationTest {

    @isTest
    static void test_action() {
        SpecialAuthorityRequest sar = TestFactory.newSpecialAuthorityRequest();
        StepAction stepAction = newAction('Approved');

        Test.startTest();
        Action action = new Adjudication();
        action.execute(sar, stepAction);
        Test.stopTest();

        system.assertEquals(sar.saCase.Status, stepAction.adjudicationStatus);
        system.assert(null != sar.saCase.Auto_Adjudicated_Date__c);
    }

    private static StepAction newAction(String status) {
        return new StepAction(
            StepAction.ActionType.ADJUDICATION,
            null,
            null,
            status,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null
        );
    }
}
