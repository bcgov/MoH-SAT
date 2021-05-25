@IsTest
public with sharing class PharmanetSubmissionTest {
    @isTest
    public static void PharmanetSubmissionTest() {
        Case saCase = TestFactory.newCase(new Drug__c(), 'Test case 1');
        saCase.Status = 'Approved';
        saCase.Pushed_to_Pnet__c = false;
        insert saCase;

        SpecialAuthorityRequest sar = new SobjectSarBuilder(saCase.Id).build();

        PharmanetSubmission action = new PharmanetSubmission();
        action.mockResult = new SAApprovalRequestResponse();
        
        Test.startTest();
        action.execute(sar, null);
        Test.stopTest();

        system.assertEquals(true, sar.saCase.Pushed_to_Pnet__c);
        system.assert(null != sar.saCase.Termination_Date__c);
    }
}