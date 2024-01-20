/**********************************************************************************************
* @Author:      Accenture
* @Date:        19/01/2024
* @Description: The purpose of this class is to cover Code coverage of EDRD_myPatientsController
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]
***********************************************************************************************/
@isTest
public class EDRD_myPatientsControllerTest {
    /**
* @author: Accenture
* @date: 19/01/2024
* @description: The purpose of this method is to cover Testcoverage of assignStatus
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/  
    @isTest
    public static void getPatientListTest(){
        User communityUser;
        User currentUser = [SELECT Id FROM User where Id=:UserInfo.getUserId()];
        system.runAs(currentUser){
            Account provider = TestFactory.newProvider('Provider Test');
            insert provider;
            Profile profileObj = [SELECT Id FROM Profile WHERE Name = 'EDRD Prescriber Community User'];
            Id ContactId = [SELECT Id FROM Contact WHERE AccountID =: provider.Id].get(0).Id;
            communityUser = TestFactory.createCommunityUser(ContactId, profileObj.Id, 'Test1', 'Test');
            insert communityUser;
            Account patientAccount = TestFactory.newPatient('Patient Test');
            insert patientAccount;
            Id patientContactId = [select Id from Contact where AccountId =:patientAccount.Id].get(0).Id;
            AccountContactRelation accountContact = new AccountContactRelation(
                AccountId=provider.Id,
                ContactId =patientContactId,
                IsActive = true);
            insert accountContact;
            PermissionSet ps = [SELECT Id 
                                FROM PermissionSet 
                                WHERE Name = 'EDRD_PS_Physicians'];
            insert new PermissionSetAssignment(AssigneeId = communityUser.Id, PermissionSetId = ps.Id);
            system.runAs(communityUser) {
                test.startTest();
                EDRD_myPatientsController.getPatientList();
                test.stopTest();
            }
            List<AccountContactRelation> accountContactResults = [SELECT Id, ContactId, AccountId 
                                                                  FROM AccountContactRelation];
            Assert.areEqual(accountContactResults[0].ContactId, patientContactId, 'Contact Id match');
            Assert.areEqual(accountContactResults[0].AccountId, provider.Id, 'Account Id match');
            Assert.areNotEqual(accountContactResults, NULL,'List contains records' );
        }
    }
}