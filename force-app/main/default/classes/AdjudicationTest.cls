@isTest
public with sharing class AdjudicationTest {

    @isTest
    static void test_action() {
        SpecialAuthorityRequest sar = TestFactory.newSpecialAuthorityRequest();
		Step_Action__c record = AdjudicationTest.getStepActionRecord();
        StepAction action = new StepAction(record);
        Test.startTest();
         action.run(sar);
        Test.stopTest();

        system.assertEquals(sar.saCase.Status, 'Approved','Case status failed to update as Approved');
        system.assert(null != sar.saCase.Auto_Adjudicated_Date__c);
    }

    
    private static Step_Action__c getStepActionRecord(){
        Step_Action__c record = new Step_Action__c();
            record.RecordTypeId = TestFactory.getRecordTypeInfosByDeveloperName('Step_Action__c', 'Adjudication').getRecordTypeId();
            record.Adjudication_Status__c = 'Approved';
            
            return record;
            // 
    }
}