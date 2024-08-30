/**********************************************************************************************
* @Author:      Accenture 
* @Date:        21/08/2024
* @Description: The purpose of this class is to cover Code coverage of AccountContactRelationTriggerHandlerTest
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description] 
***********************************************************************************************/
@isTest
public class AccountContactRelationTriggerHandlerTest {
    
/**
* @author: Deepak
* @date: 21 Aug 2024
* @description: The purpose of this method is to cover Testcoverage of createPatientShare
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/    
    @isTest
    public static void createPatientShare_Test(){
        Account patientAcc = TestFactory.newPatient('Patient Test');
        insert patientAcc;
        Account providerAccount = TestFactory.newProvider('Provider Test');
        insert providerAccount;
        Id ContactId = [SELECT Id FROM Contact WHERE AccountID =: providerAccount.Id].get(0).Id;
        Profile profileObj = [SELECT Id FROM Profile WHERE Name = 'EDRD Prescriber Community User'];
        User communityUser = TestFactory.createCommunityUser(ContactId, profileObj.Id, 'Test1', 'Test');
        insert communityUser;
        
        Id patientContactId = [SELECT Id FROM Contact Where accountId =: patientAcc.Id].get(0).Id;
        AccountContactRelation ACRObj = new AccountContactRelation();
        ACRObj.AccountId = providerAccount.Id;
        ACRObj.ContactId = patientContactId;
        ACRObj.Roles = 'Physician';
        ACRObj.IsActive = true;
        
        Test.startTest();
        insert ACRObj;
        Test.stopTest();
        
        List<AccountShare> accShare = [SELECT Id, AccountId, UserOrGroupId, RowCause, AccountAccessLevel 
                                       FROM AccountShare WHERE AccountId =: patientAcc.Id 
                                       AND UserOrGroupId =: communityUser.Id LIMIT 1];
        
        Assert.areEqual(accShare[0].AccountAccessLevel, 'Read', 'AccountShare access level should be Read');
        Assert.areEqual(accShare.size(), 1, 'AccountShare should have been created for the Patient');
        Assert.areNotEqual(accShare.isEmpty(), true, 'AccountShare list should not be empty');
        Assert.areNotEqual(accShare[0].UserOrGroupId, null, 'UserOrGroupId should not be null');     
    }
    
/**
* @author: Deepak
* @date: 21 Aug 2024
* @description: The purpose of this method is to cover Testcoverage of removePatientShare
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/   
    @isTest
    public static void removePatientShare_Test(){
        Account patientAcc = TestFactory.newPatient('Patient Test');
        insert patientAcc;
        Account prescriberAcc = TestFactory.newProvider('Provider Test');
        insert prescriberAcc;
        Id ContactId = [SELECT Id FROM Contact WHERE AccountID =: prescriberAcc.Id].get(0).Id;
        Profile profileRec = [SELECT Id FROM Profile WHERE Name = 'EDRD Prescriber Community User'];
        User communityUser = TestFactory.createCommunityUser(ContactId, profileRec.Id, 'Test1', 'Test');
        insert communityUser;
        
        Id patientContactId = [SELECT Id FROM Contact Where accountId =: patientAcc.Id].get(0).Id;
        AccountContactRelation ACRObj = new AccountContactRelation();
        ACRObj.AccountId = prescriberAcc.Id;
        ACRObj.ContactId = patientContactId;
        ACRObj.Roles = 'Physician';
        ACRObj.IsActive = true;
        insert ACRObj;
        
        Test.startTest();
        delete ACRObj;
        Test.stopTest();
        List<AccountShare> accShareList = [SELECT Id FROM AccountShare WHERE AccountId =: patientAcc.Id 
                                           AND UserOrGroupId =: communityUser.Id LIMIT 1];
        List<AccountContactRelation> deletedACRList = [SELECT Id FROM AccountContactRelation WHERE Id = :ACRObj.Id LIMIT 1];
        
        Assert.areEqual(accShareList.isEmpty(), true, 'AccountShare records should not exist after the ACR is deleted');
        Assert.areNotEqual(accShareList.size(), 1, 'AccountShare record should be deleted');
    } 
}