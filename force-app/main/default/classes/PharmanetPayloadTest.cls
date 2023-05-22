@isTest
public with sharing class PharmanetPayloadTest {
    @isTest
    static void test_action_with_empty_effective_date() {
        SpecialAuthorityRequest sar = TestFactory.newSpecialAuthorityRequest();
        sar.saCase.Effective_Date__c = null;
		Step_Action__c record = PharmanetPayloadTest.getStepActionRecord();
        StepAction action = new StepAction(record);

        Test.startTest();
 	    action.run(sar);
        Test.stopTest();

        List<SAApprovalRequest> saApprovalRequests = sar.getSaApprovalRequests();
        system.assertEquals(Date.today(), sar.saCase.Effective_Date__c);
        system.assertEquals(1, saApprovalRequests.size());
        system.assertEquals('1111', saApprovalRequests[0].saRecord.specialItem.din);
    }

    
    
    Private static Step_Action__c getStepActionRecord(){
        Step_Action__c record = new Step_Action__c(Duration_Unit__c='Indefinite',Days_Supply__c=10,Price_Percent__c=100,SA_Type__c='B',Key_Type__c='DIN',Pharmanet_Code__c='1111');
            record.RecordTypeId = TestFactory.getRecordTypeInfosByDeveloperName('Step_Action__c', 'Pharmanet_Payload').getRecordTypeId();
            
            return record;
    }
}