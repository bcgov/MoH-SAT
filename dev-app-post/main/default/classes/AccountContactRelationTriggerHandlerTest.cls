/**********************************************************************************************
* @Author:      Accenture 
* @Date:        21/08/2024
* @Description: The purpose of this class is to cover Code coverage of AccountContactRelationTriggerHandler
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
        
        Assert.areEqual(accShare[0].AccountAccessLevel, 'Edit', 'AccountShare access level should be Edit');
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
        Account patientAcc1 = TestFactory.newPatient('Patient Test');
        insert patientAcc1;
        Account prescriberAcc1 = TestFactory.newProvider('Provider Test');
        insert prescriberAcc1;
        Id ContactId = [SELECT Id FROM Contact WHERE AccountID =: prescriberAcc1.Id].get(0).Id;
        Profile profileRec = [SELECT Id FROM Profile WHERE Name = 'EDRD Prescriber Community User'];
        User communityUser = TestFactory.createCommunityUser(ContactId, profileRec.Id, 'Test1', 'Test');
        insert communityUser;
        
        Id patientContactId = [SELECT Id FROM Contact Where accountId =: patientAcc1.Id].get(0).Id;
        AccountContactRelation ACRObj = new AccountContactRelation();
        ACRObj.AccountId = prescriberAcc1.Id;
        ACRObj.ContactId = patientContactId;
        ACRObj.Roles = 'Physician';
        ACRObj.IsActive = true;
        insert ACRObj;
        
        Test.startTest();
        delete ACRObj;
        Test.stopTest();
        List<AccountShare> accShareList = [SELECT Id FROM AccountShare WHERE AccountId =: patientAcc1.Id 
                                           AND UserOrGroupId =: communityUser.Id LIMIT 1];
        List<AccountContactRelation> deletedACRList = [SELECT Id FROM AccountContactRelation WHERE Id = :ACRObj.Id LIMIT 1];
        
        Assert.areEqual(accShareList.isEmpty(), true, 'AccountShare records should not exist after the ACR is deleted');
        Assert.areNotEqual(accShareList.size(), 1, 'AccountShare record should be deleted');
    } 
    
/**
* @author: Deepak
* @date: 03 Sept 2024
* @description: The purpose of this method is to cover Testcoverage of updatePatientShare
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/   
    @isTest
    public static void updatePatientShare_Test(){
        Account patientAcc2 = TestFactory.newPatient('Patient Test');
        insert patientAcc2;
        Account prescriberAcc2 = TestFactory.newProvider('Provider Test');
        insert prescriberAcc2;
        Id ContactId = [SELECT Id FROM Contact WHERE AccountID =: prescriberAcc2.Id].get(0).Id;
        Profile profileRec = [SELECT Id FROM Profile WHERE Name = 'EDRD Prescriber Community User'];
        User communityUser = TestFactory.createCommunityUser(ContactId, profileRec.Id, 'Test1', 'Test');
        insert communityUser;
        
        Id patientContactId = [SELECT Id FROM Contact Where accountId =: patientAcc2.Id].get(0).Id;
        AccountContactRelation ACRObj = new AccountContactRelation();
        ACRObj.AccountId = prescriberAcc2.Id;
        ACRObj.ContactId = patientContactId;
        ACRObj.Roles = 'Physician';
        insert ACRObj;
        
        List<AccountShare> accShareList = [SELECT Id FROM AccountShare WHERE AccountId =: patientAcc2.Id 
                                           AND UserOrGroupId =: communityUser.Id LIMIT 1];
        delete accShareList;
        
        Test.startTest();
        ACRObj.IsActive = true;
        update ACRObj;
        Test.stopTest();
        List<AccountShare> accShareList2 = [SELECT Id, AccountId, UserOrGroupId, RowCause, AccountAccessLevel
                                            FROM AccountShare WHERE AccountId =: patientAcc2.Id 
                                            AND UserOrGroupId =: communityUser.Id LIMIT 1];
        List<AccountContactRelation> insertACRList = [SELECT Id FROM AccountContactRelation WHERE Id = :ACRObj.Id LIMIT 1];        
        
        Assert.areEqual(accShareList2.isEmpty(), false, 'AccountShare records should exist after the ACR is updated');
        Assert.areEqual(accShareList2[0].AccountAccessLevel, 'Edit', 'AccountShare access level should be Edit');
        Assert.areEqual(accShareList2.size(), 1, 'AccountShare record should be created');
        Assert.areNotEqual(accShareList2.size(), NULL, 'AccountShare record should is not created');
        Assert.areNotEqual(accShareList2.isEmpty(), true, 'AccountShare record list cannot be empty, after the ACR is updated');
    } 
}