@isTest
public class EDRDAccountLookupController_Test {
     @isTest
    static void testGetAccount() {
        // Test data setup for testGetAccount
        Account testPatientAccount = new Account(
            LastName = 'Test Patient Account'
        );
        insert testPatientAccount;

        Contact testPatientContact = new Contact(
            LastName = 'Test Patient Contact',
            Patient_Identifier__c = '8910947511',
            Birthdate = Date.newInstance(2000, 1, 1),
            AccountId = testPatientAccount.Id
        );
        insert testPatientContact;
        
        Test.startTest();
        List<Account> result = EDRDAccountLookupController.getAccount('8910947511');
        Test.stopTest();

        // Assertions
        System.assertEquals(1, result.size(), 'Expected one account in the result list');
        Account retrievedAccount = result[0];
        System.assertEquals(testPatientAccount.Id, retrievedAccount.Id, 'Unexpected Account Id');
        System.assertEquals(testPatientAccount.LastName, retrievedAccount.LastName, 'Unexpected Account Name');
        System.assertEquals(testPatientContact.Patient_Identifier__c, retrievedAccount.PersonContact.Patient_Identifier__c, 'Unexpected Contact Patient');
        System.assertEquals(testPatientContact.Birthdate, retrievedAccount.PersonContact.Birthdate, 'Unexpected Contact Birthdate');
}

    @isTest
    static void testGetProviderAccount() {
        // Test data setup
        Account testAccount = new Account(
            Name = 'Test Account'
        );
        insert testAccount;

        Contact testContact = new Contact(
            LastName = 'Test Contact',
            Provider_Identifier__c = '11AA086',
            AccountId = testAccount.Id
        );
        insert testContact;

        // Call the method to be tested
        Test.startTest();
        List<Account> result = EDRDAccountLookupController.getProviderAccount('11AA086');
        Test.stopTest();

        // Assertions
        System.assertEquals(1, result.size(), 'Expected one account in the result list');
        Account retrievedAccount = result[0];
       
        System.assertEquals(testAccount.Id, retrievedAccount.Id, 'Unexpected Account Id');
        System.assertEquals(testAccount.LastName, retrievedAccount.LastName, 'Unexpected Account Name');
        System.assertEquals(testContact.Provider_Identifier__c, retrievedAccount.PersonContact.Provider_Identifier__c, 'Unexpected Contact Provider Identifier');
        
    }
}