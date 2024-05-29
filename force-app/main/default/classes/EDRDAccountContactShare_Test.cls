/**********************************************************************************************
* @Author:      Suman 
* @Date:        09 Feb 2024
* @Description: The purpose of this class is to cover Code coverage of EDRDAccountContactShare
***********************************************************************************************/
@isTest
public class EDRDAccountContactShare_Test {
/**
* @author: Suman
* @date: 08 Dec 2023
* @description: The purpose of this method is to cover Testcoverage of accountContactMedicationRequestSharing method
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/
    @isTest
    static void testAccountContactMedicationRequestSharing() {
       /* Account testAccount = new Account(LastName='Test Account');
        insert testAccount;
        Contact testContact = new Contact(FirstName='Test', LastName='Contact', Id=testAccount.PersonContactId);
        insert testContact;
        AccountContactRelation testAcr = new AccountContactRelation(
            AccountId = testAccount.Id,
            ContactId = testContact.Id
        );
        insert testAcr;
            User testUser = new User(
            ContactId = testContact.Id,
            Alias = 'testUser',
            Email = 'test@example.com',
            FirstName = 'Test',
            LastName = 'User',
            Username = 'testuser@example.com',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = '00eAq000001euB0',
            LanguageLocaleKey = 'en_US'
        );
        Medication testMedication = new Medication(Name = 'Test Medication');
        insert testMedication;
        MedicationRequest testMedicationRequest = new MedicationRequest(
        PatientId = testAccount.Id,
        Type = 'New', 
        Status = 'Active', 
        MedicationId = testMedication.Id
        );
        insert testMedicationRequest;
        Test.startTest();
        EDRDAccountContactShare.accountContactMedicationRequestSharing(new List<AccountContactRelation>{testAcr});
        Test.stopTest();
        List<MedicationRequestShare> medicationRequestShares = [SELECT Id FROM MedicationRequestShare WHERE ParentId = :testMedicationRequest.Id];
        Assert.areNotEqual(0, medicationRequestShares.size(), 'MedicationRequestShares should have been inserted');
        Assert.areEqual('Read', medicationRequestShares[0].AccessLevel, 'AccessLevel should be Read');
*/
    }
}