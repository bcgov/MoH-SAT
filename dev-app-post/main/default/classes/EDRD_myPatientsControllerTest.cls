/**********************************************************************************************
* @Author:      Accenture
* @Date:        19/01/2024
* @Description: The purpose of this class is to cover Code coverage of EDRD_myPatientsController
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]
                07 Jan -  EDRD-1112         -  Accenture   - method is to cover Testcoverage of assignStatus
                23 May -  EDRD-1407         -  Deepak      - method is to display List of EDRD Providers Team in EDRD Portal
                23 May -  EDRD-1407         -  Deepak      - method is to display List of related EDRD Providers Team in EDRD Portal
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
            Profile profileObj = [SELECT Id, UserLicense.Name FROM Profile WHERE Name = 'EDRD Prescriber Community User' 
                                  AND UserLicense.Name = 'Customer Community Plus' LIMIT 1];
            Id contactId = [SELECT Id FROM Contact WHERE AccountID =: provider.Id].get(0).Id;
            communityUser = TestFactory.createCommunityUser(contactId, profileObj.Id, 'Test1', 'Test');
            insert communityUser;
            Account patientAccount = TestFactory.newPatient('Patient Test');
            insert patientAccount;
            Id patientContactId = [select Id from Contact where AccountId =:patientAccount.Id].get(0).Id;
            AccountContactRelation accountContact = new AccountContactRelation(
                AccountId=provider.Id,
                ContactId =patientContactId,
                Roles = 'Physician',
                IsActive = true);
            insert accountContact;
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'EDRD_PS_Physicians'];
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
    
/**
* @author: Deepak
* @date: 23/05/2025
* @description: The purpose of this method is to cover Testcoverage of getAlliedStaffList
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/  
    @isTest
    public static void getAlliedStaffListTest(){
        User currentUser = [SELECT Id FROM User where Id=:UserInfo.getUserId()];
        system.runAs(currentUser){
            Account pharmacistAcc = TestFactory.newProvider('Patient Test');
            insert pharmacistAcc;
            Account providerAccount = TestFactory.newProvider('Provider Test');
            providerAccount.Provider_Identifier__pc = '111222334';
            providerAccount.Provider_Type__pc = 'Provider';
            insert providerAccount;
            Id ContactId = [SELECT Id FROM Contact WHERE AccountID =: providerAccount.Id].get(0).Id;
            Profile profileObj = [SELECT Id FROM Profile WHERE Name = 'EDRD Prescriber Community User'];
            User communityUser = TestFactory.createCommunityUser(ContactId, profileObj.Id, 'Test1', 'Test');
            insert communityUser;
            
            Id pharmacistContactId = [SELECT Id FROM Contact Where accountId =: pharmacistAcc.Id].get(0).Id;
            AccountContactRelation ACRObj = new AccountContactRelation();
            ACRObj.AccountId = providerAccount.Id;
            ACRObj.ContactId = pharmacistContactId;
            ACRObj.Roles = 'Allied Staff';
            ACRObj.IsActive = true;
            insert ACRObj;

            system.runAs(communityUser) {
                test.startTest();
                EDRD_myPatientsController.getAlliedStaffList();
                test.stopTest();
            }
            List<AccountContactRelation> aCRList = [SELECT Id, ContactId, AccountId FROM AccountContactRelation];
            Assert.areEqual(aCRList[0].ContactId, pharmacistContactId, 'Contact Id match');
            Assert.areEqual(aCRList[0].AccountId, providerAccount.Id, 'Account Id match');
            Assert.areNotEqual(aCRList, NULL,'List contains records' );
        }
    }
    
/**
* @author: Deepak
* @date: 23/05/2025
* @description: The purpose of this method is to cover Testcoverage of getRelatedPhysiciansList
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/  
    @isTest
    public static void getRelatedPhysiciansListTest(){
        User currentUser = [SELECT Id FROM User where Id=:UserInfo.getUserId()];
        system.runAs(currentUser){
            Account providerAccount = TestFactory.newProvider('Provider Test');
            providerAccount.Provider_Identifier__pc = '111222334';
            providerAccount.Provider_Type__pc = 'Provider';
            insert providerAccount;
            Account pharmacistAcc = TestFactory.newProvider('Patient Test');
            insert pharmacistAcc;
            Id ContactId = [SELECT Id FROM Contact WHERE AccountID =: pharmacistAcc.Id].get(0).Id;
            Profile profileObj = [SELECT Id FROM Profile WHERE Name = 'BC HLTH Pharmacist Community User'];
            User communityUser = TestFactory.createCommunityUser(ContactId, profileObj.Id, 'Test1', 'Pharmacist');
            insert communityUser;
            
            AccountContactRelation ACRObj = new AccountContactRelation();
            ACRObj.AccountId = providerAccount.Id;
            ACRObj.ContactId = ContactId;
            ACRObj.Roles = 'Allied Staff';
            ACRObj.IsActive = true;
            insert ACRObj;            
            
            system.runAs(communityUser) {
                test.startTest();
                EDRD_myPatientsController.getRelatedPhysiciansList();
                test.stopTest();
            }
            List<AccountContactRelation> aCRInsertList = [SELECT Id, ContactId, AccountId FROM AccountContactRelation];
            Assert.areEqual(aCRInsertList[0].ContactId, ContactId, 'Contact Id match');
            Assert.areEqual(aCRInsertList[0].AccountId, providerAccount.Id, 'Account Id match');
            Assert.areNotEqual(aCRInsertList, NULL,'List contains records' );
        }
    }
}