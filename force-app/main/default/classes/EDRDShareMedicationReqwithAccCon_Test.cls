/**********************************************************************************************
* @author:      Suman 
* @Date:        08 Feb 2024
* @Description: The purpose of this class is to cover Code coverage of EDRDMedicationReqwithACRHandler
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description] 
***********************************************************************************************/
@isTest
public class EDRDShareMedicationReqwithAccCon_Test {
/**
* @author: Suman
* @date: 08 Feb 2024
* @description: The purpose of this method is to cover Testcoverage of shareMedicationRequestsWithPatientAccount method
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/
   @isTest
    static void testShareMedicationRequestsWithPatientAccount() {
        Account testAccount = new Account(LastName = 'Test Account');
        insert testAccount;
        System.debug('testAccount '+testAccount);
        Contact testContact = new Contact(LastName = 'Test Contact', Id = testAccount.PersonContactId);
        insert testContact;
        System.debug('testContact '+testContact);
        User testUser = new User(
            ContactId = testContact.Id,
            Alias = 'testUser',
            Email = 'test@example.com',
            FirstName = 'Test',
            LastName = 'User',
            Username = 'testuser@example.com',
            TimeZoneSidKey = 'America/New_York', // Provide a valid time zone
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = '00eAq000001euB0', // Assigning a valid profile
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        System.debug('testUser '+testUser);
        Medication testMedication = new Medication(Name = 'Test Medication');
        insert testMedication;
        System.debug('testMedication '+testMedication);
        MedicationRequest testMedicationRequest = new MedicationRequest(
            PatientId = testAccount.Id, 
            Type = 'New', 
            Status = 'Active', 
            MedicationId = testMedication.Id
        );
        insert testMedicationRequest;
        System.debug('testMedicationRequest '+testMedicationRequest);
        Test.startTest();
        EDRDMedicationReqwithACRHandler.shareMedicationRequestsWithPatientAccount(new List<MedicationRequest>{ testMedicationRequest });
        Test.stopTest();
        List<MedicationRequestShare> medicationRequestShares = [
            SELECT Id, ParentId, UserOrGroupId, AccessLevel
            FROM MedicationRequestShare
            WHERE ParentId = :testMedicationRequest.Id
        ];
        Assert.areEqual(1, medicationRequestShares.size(), 'One MedicationRequestShare record should be created.');
        Assert.areNotEqual(null, testMedicationRequest.MedicationId, 'MedicationId should not be null.');

    }
}