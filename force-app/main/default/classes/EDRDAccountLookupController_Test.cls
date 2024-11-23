/**********************************************************************************************
* @author:      Suman 
* @Date:        08 Dec 2023
* @Description: The purpose of this class is to cover Code coverage of EDRDAccountLookupController
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description] 
                16-Nov -  EDRD-104          -  Deepak      -  Test method for Changes related to EDRD EMPI Integration for getAccount
                16-Nov -  EDRD-104          -  Deepak      -  Test method for method to return patient Accounts information based on Patient Identifiers
                16-Nov -  EDRD-104          -  Deepak      -  Test method for Validates if a patient record exists for the given Patient Identifier
***********************************************************************************************/
@isTest
public class EDRDAccountLookupController_Test {
/**
* @author: Suman
* @date: 08 Dec 2023
* @description: The purpose of this method is to cover Testcoverage of getAccount method
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
                     16-Nov -  EDRD-104          -  Deepak      -  Changes related to EDRD EMPI Integration
*/
    /*@isTest
    public static void testGetAccount() {        
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
    } */
    
/**
* @author: Suman
* @date: 08 Dec 2023
* @description: The purpose of this method is to cover Testcoverage of getProviderAccount method
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/
    @isTest
    public static void testGetProviderAccount() {
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
    
/**
* @author: Deepak
* @date: 16 Nov 2024
* @description: The purpose of this method is to cover Testcoverage of searchPatients
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/    
    @isTest
    public static void searchPatientsTest(){
        Account pntAccount = TestFactory.newPatient('Patient Test');
        insert pntAccount;
        Map<String, String> searchCriteria = new Map<String, String>{'patientIdentifier' => '222333444'};
            
        Test.startTest();
        List<Account> result = EDRDAccountLookupController.searchPatients(searchCriteria);
        Test.stopTest();
        
        Assert.areEqual(1, result.size(), 'Expected one patient record');
        Account retrievedPatient = result[0];
        Assert.areEqual('Patient Test', retrievedPatient.FirstName, 'Unexpected First Name');
        Assert.areEqual('TestPatient', retrievedPatient.LastName, 'Unexpected Last Name');
        Assert.areEqual('222333444', retrievedPatient.Patient_Identifier__pc, 'Unexpected Patient Identifier');
        Assert.areNotEqual('WrongFirstName', retrievedPatient.FirstName, 'First Name should not match an incorrect value');
        Assert.areNotEqual('WrongLastName', retrievedPatient.LastName, 'Last Name should not match an incorrect value');
        Assert.areNotEqual('999999999', retrievedPatient.Patient_Identifier__pc, 'Patient Identifier should not match an incorrect value');        
    }
    
/**
* @author: Deepak
* @date: 16 Nov 2024
* @description: The purpose of this method is to cover Testcoverage of validatePatientIdentifier
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/    
    @isTest
    public static void validatePatientIdentifierTest(){
        Account patientAccount = TestFactory.newPatient('Patient Test');
        insert patientAccount;
        
        Test.startTest();
        Boolean isValid = EDRDAccountLookupController.validatePatientIdentifier('222333444');
        Boolean isInvalid = EDRDAccountLookupController.validatePatientIdentifier('INVALID_PID');
        Test.stopTest();
        
        Assert.areEqual(isValid, true, 'Expected the patient identifier to be valid');
        Assert.areEqual(isInvalid, false, 'Expected the patient identifier to be invalid');
        Assert.areNotEqual(isValid, false, 'Patient identifier should not be invalid for valid input');
        Assert.areNotEqual(isInvalid, true, 'Patient identifier should not be valid for invalid input');        
    }
}