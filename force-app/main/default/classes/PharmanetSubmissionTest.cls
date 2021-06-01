@IsTest
public with sharing class PharmanetSubmissionTest {
    @isTest
    public static void PharmanetSubmissionTest() {
        SpecialAuthorityRequest sar = TestFactory.newSpecialAuthorityRequest();
        sar.saCase.Status = 'Approved';
        sar.saCase.Pushed_to_Pnet__c = false;

        sar.addSaApprovalRequest(newPharmanetPayload());

        PharmanetSubmission action = new PharmanetSubmission();
        action.mockResult = new SAApprovalRequestResponse();
        
        Test.startTest();
        action.execute(sar, null);
        Test.stopTest();

        system.assertEquals(true, sar.saCase.Pushed_to_Pnet__c);
        system.assert(null != sar.saCase.Termination_Date__c);
    }

    private static StepAction newPharmanetPayload() {
        return new StepAction(
            StepAction.ActionType.PHARMANET_PAYLOAD,
            null,
            null,
            null,
            '1111',
            'B',
            'DIN',
            100,
            10,
            null, 
            'Indefinite',
            null,
            null
        );
    }
}