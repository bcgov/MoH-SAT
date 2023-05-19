@isTest
public with sharing class ESA_cls_CaseUpdateTest {
    
    @isTest
    static void testCaseUpdate() {
        SpecialAuthorityRequest sar = TestFactory.newSpecialAuthorityRequest();
        sar.saCase.Effective_Date__c = null;
		Step_Action__c record  = TestFactory.newCaseUpdateStepAction(new Step__c(),1,20,12,'days','Test Case','Testing','Rationale1');
        StepAction action = new StepAction(record);

        Test.startTest();
  
        action.run(sar);
       
        Assert.areEqual(String.Valueof(20),sar.saCase.Max_Days_Supply__c, 'Max days Supply is not udpated on Case');
        Test.stopTest();
        
    }

  
}