@isTest
public with sharing class StepsTest {
    @testSetup
    static void test_setup() {
        List<Drug__c> drugs = new List<Drug__c>();
        drugs.add(TestFactory.newDrug('tylenol'));
        drugs.add(TestFactory.newDrug('advil'));
        insert drugs;
    }

    @isTest
    static void test_set_external_ids() {
        Step__c step1 = new Step__c();
        step1.Drug__c = queryDrug('tylenol').Id;
        step1.Order__c = 1;
        step1.Name = 'Tylenol step';
        step1.External_ID__c = null;

        Step__c step2 = new Step__c();
        step2.Drug__c = queryDrug('advil').Id;
        step2.Order__c = 2;
        step2.Name = 'Advil step';
        step2.External_ID__c = null;
        
        Test.startTest();
        insert new Step__c[] {step1, step2};
        Test.stopTest();

        system.assertEquals('tylenol_1_Tylenol_step', [select External_ID__c from Step__c where Id = :step1.Id].External_ID__c);
        system.assertEquals('advil_2_Advil_step', [select External_ID__c from Step__c where Id = :step2.Id].External_ID__c);
    }

    @isTest
    static void test_set_external_ids_if_existing() {
        Step__c step1 = new Step__c();
        step1.Drug__c = queryDrug('tylenol').Id;
        step1.Order__c = 1;
        step1.Name = 'Tylenol step';
        step1.External_ID__c = 'existing-external-id';
        
        Test.startTest();
        new Steps(new Step__c[] {step1}).setExternalIds();
        Test.stopTest();

        system.assertEquals('existing-external-id', step1.External_ID__c);
    }

    private static Drug__c queryDrug(String name) {
        return [select Id, Name, Pre_Adjudication_Apex__c, Post_Adjudication_Apex__c from Drug__c where Name = :name limit 1][0];
    }
}
