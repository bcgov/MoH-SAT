/**********************************************************************************************
* @author:      Suman 
* @Date:        08 Dec 2023
* @Description: The purpose of this class is to cover Code coverage of EDRDAccountLookupController
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description] 
***********************************************************************************************/
@isTest
public class EDRDAccountLookupController_Test {
/**
* @author: Suman
* @date: 08 Dec 2023
* @description: The purpose of this method is to cover Testcoverage of getAccount method
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/
    @isTest
    static void testGetAccount() {        
       Id accountRecType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Patient').getRecordTypeId();
                Account testPatientAccount = new Account(
                LastName = 'Test Patient Account',
                Patient_Identifier__pc = '8910947511',
                PersonBirthdate = Date.newInstance(2000, 1, 1),
                RecordTypeId = accountRecType
            );
            insert testPatientAccount;
        Test.startTest();
        List<Account> result = EDRDAccountLookupController.getAccount('8910947511');
        Test.stopTest();
        Assert.areEqual(1, result.size(), 'Expected one account in the result list');
        Account retrievedAccount = result[0];
        Assert.areEqual('Test Patient Account', retrievedAccount.LastName, 'Unexpected Account Name');
        Assert.areEqual('8910947511', retrievedAccount.Patient_Identifier__pc, 'Unexpected Contact Patient Identifier');
        Assert.areEqual(Date.newInstance(2000, 1, 1), retrievedAccount.PersonBirthdate, 'Unexpected Contact Birthdate');
        Assert.areNotEqual(testPatientAccount.Patient_Identifier__pc, 'DifferentValue', 'Expected different Contact Patient Identifier');
}    
/**
* @author: Suman
* @date: 08 Dec 2023
* @description: The purpose of this method is to cover Testcoverage of getProviderAccount method
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/
    @isTest
    static void testGetProviderAccount() {
        Id accountRecType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Provider').getRecordTypeId();
        Account testProviderAccount = new Account(
            LastName = 'Test Provider Account',
            Provider_Identifier__pc = '11AA086',
            RecordTypeId = accountRecType
        );
        insert testProviderAccount;
        Test.startTest();
        List<Account> result = EDRDAccountLookupController.getProviderAccount('11AA086');
        Test.stopTest();
        Assert.areEqual(1, result.size(), 'Expected one account in the result list');
        Account retrievedAccount = result[0];       
        Assert.areEqual(testProviderAccount.Id, retrievedAccount.Id, 'Unexpected Account Id');
        Assert.areEqual(testProviderAccount.LastName, retrievedAccount.LastName, 'Unexpected Account Name');
        Assert.areEqual(testProviderAccount.Provider_Identifier__pc, retrievedAccount.PersonContact.Provider_Identifier__c, 'Unexpected Contact Provider Identifier');
        Assert.areNotEqual(testProviderAccount.Provider_Identifier__pc, 'DifferentValue', 'Expected different Contact Provider Identifier');
    }
}