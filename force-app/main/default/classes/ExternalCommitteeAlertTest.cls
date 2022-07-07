@isTest 
public with sharing class ExternalCommitteeAlertTest {

    @isTest 
    static void testSendAlert(){
        Account a = TestFactory.newAccount('Test Account');
        insert a;

        Contact c = TestFactory.newContact('Test Contact', 'testemail@test.com', a.Id);
        Drug__c d = TestFactory.newDrug('testdrug');
        insert c;
        insert d;

        External_Committee__c ec = TestFactory.newExternalCommittee('IBD DBAAC 3000-01-01', 'IBD DBAAC', a.Id);
        insert ec;

        Case ca = TestFactory.newCase(d, 'Test Case', ec);
        insert ca; 

        ExternalCommitteeAlert.sendAlert(ec.Id);

        ec = [SELECT Id, Agenda__c, Email_Sent__c FROM External_Committee__c WHERE Id = :ec.Id];
        
        System.assertEquals(false, String.isEmpty(ec.Agenda__c));
        System.assertEquals(true, ec.Email_Sent__c != null);
    }
}