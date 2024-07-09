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
        Account requestorAccount = TestFactory.newProvider('Provider Test');
        insert requestorAccount;
        Account patientAccount1 = TestFactory.newPatient('Patient Test');
        insert patientAccount1;
        Id ContactId = [SELECT Id FROM Contact WHERE AccountID =: requestorAccount.Id].get(0).Id;
        Profile profileObj1 = [SELECT Id FROM Profile WHERE Name = 'EDRD Prescriber Community User'];
        User communityUser = TestFactory.createCommunityUser(ContactId, profileObj1.Id, 'Test1', 'Test');
        insert communityUser;
        List<Medication> MedicationRecList = TestFactory.createMedication(1, 'Test Medication');
        insert MedicationRecList;
        List<MedicationRequest> MedicationRequestRecList = TestFactory.createMedicationRequest(1, MedicationRecList.get(0).Id, NULL, requestorAccount.Id, patientAccount1.Id); 
        insert MedicationRequestRecList;
        
        Id patientContactId = [SELECT Id FROM Contact Where accountId =: patientAccount1.Id].get(0).Id;
        AccountContactRelation ACRObj = new AccountContactRelation();
        ACRObj.AccountId = requestorAccount.Id;
        ACRObj.ContactId = patientContactId;
        ACRObj.Roles = 'Physician';
        insert ACRObj;
        
        Test.startTest();
        EDRDMedicationReqwithACRHandler.shareMedicationRequestsWithPatientAccount(MedicationRequestRecList);
        Test.stopTest();
        List<MedicationRequestShare> medicationRequestShares = [SELECT Id, ParentId, UserOrGroupId, AccessLevel
                                                                FROM MedicationRequestShare
                                                                WHERE ParentId = :MedicationRequestRecList[0].Id];
        
        Assert.areEqual(2, medicationRequestShares.size(), 'Two MedicationRequestShare record should be created.');
        Assert.areNotEqual(null, MedicationRequestRecList[0].MedicationId, 'MedicationId should not be null.');
    }
}