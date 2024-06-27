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
        Account providerAccount = TestFactory.newProvider('Provider Test');
        insert providerAccount;
        Account patientAccount1 = TestFactory.newPatient('Patient Test');
        insert patientAccount1;
        Id ContactId = [SELECT Id FROM Contact WHERE AccountID =: providerAccount.Id].get(0).Id;
        Profile profileObj = [SELECT Id FROM Profile WHERE Name = 'EDRD Prescriber Community User'];
        User communityUser = TestFactory.createCommunityUser(ContactId, profileObj.Id, 'Test1', 'Test');
        insert communityUser;
        List<Medication> MedicationRecList = TestFactory.createMedication(1, 'Test Medication');
        insert MedicationRecList;
        List<MedicationRequest> MedicationRequestRecList = TestFactory.createMedicationRequest(1, MedicationRecList.get(0).Id, NULL, providerAccount.Id, patientAccount1.Id); 
        insert MedicationRequestRecList;
        
        Id patientContactId = [SELECT Id FROM Contact Where accountId =: patientAccount1.Id].get(0).Id;
        AccountContactRelation ACRObj = new AccountContactRelation();
        ACRObj.AccountId = providerAccount.Id;
        ACRObj.ContactId = patientContactId;
        ACRObj.Roles = 'Physician';
        insert ACRObj;
        List<AccountContactRelation> aCRList = [SELECT Id, ContactId, Contact.AccountId, Account.PersonContactId, AccountId 
                                                FROM AccountContactRelation Order By CreatedDate DESC LIMIT 1];
        
        Test.startTest();
        EDRDAccountContactShare.accountContactMedicationRequestSharing(aCRList);
        Test.stopTest();
        List<MedicationRequestShare> medicationRequestShares = [SELECT Id, AccessLevel, UserOrGroup.Name FROM MedicationRequestShare 
                                                                WHERE ParentId = :MedicationRequestRecList[0].Id ORDER BY AccessLevel];
        
        Assert.areNotEqual(0, medicationRequestShares.size(), 'MedicationRequestShares should have been inserted');
        Assert.areEqual('Read', medicationRequestShares[0].AccessLevel, 'AccessLevel should be Read');
        Assert.areEqual('All', medicationRequestShares[1].AccessLevel, 'AccessLevel should be ALL');
    }
}