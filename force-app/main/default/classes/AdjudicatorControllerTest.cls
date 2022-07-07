@isTest
public with sharing class AdjudicatorControllerTest {
    
    @testSetup
    static void test_setup(){
        Case record = TestFactory.newCase(new Drug__c(), 'Test case');
        insert record;
    }

    @isTest
    static void test_run_adjudicator() {
        Case record = queryCase('Test case');

        try {
            Test.startTest();
            AdjudicatorController.runAdjudicator(record.Id, false);
            Test.stopTest();
            system.assert(true);
        } catch (Exception e) {
            system.assert(false, 'An unexpected exception was thrown.');
        }
    }
    
    @isTest
    static void test_run_adjudicator_error() {
        Id notACaseId = TestFactory.newId(Account.sobjectType);

        try {
            Test.startTest();
            AdjudicatorController.runAdjudicator(notACaseId, false);
            Test.stopTest();
            system.assert(false, 'An expected exception was not thrown.');
        } catch (Exception e) {
            system.assert(true);
        }
    }

    private static Case queryCase(String subject) {
        return [select Id from Case where Subject = :subject][0];
    }

}