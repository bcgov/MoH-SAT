@isTest
public with sharing class PharmanetPayloadTest {
    @isTest
    static void test_action_with_empty_effective_date() {
        SpecialAuthorityRequest sar = TestFactory.newSpecialAuthorityRequest();
        sar.saCase.Effective_Date__c = null;

        StepAction actionParams = newPharmanetPayload();

        Test.startTest();
        Action action = new PharmanetPayload();
        action.execute(sar, actionParams);
        Test.stopTest();

        List<SAApprovalRequest> saApprovalRequests = sar.getSaApprovalRequests();
        system.assertEquals(Date.today(), sar.saCase.Effective_Date__c);
        system.assertEquals(1, saApprovalRequests.size());
        system.assertEquals('1111', saApprovalRequests[0].saRecord.specialItem.din);
    }

    private static StepAction newPharmanetPayload() {
        return new StepAction(
            StepAction.ActionType.PHARMANET_PAYLOAD,
            null,
            null,
            null,
            '1111',
            'DIN',
            'B',
            100,
            10,
            null, 
            'Indefinite',
            null,
            null
        );
    }
}