/**********************************************************************************************
* @Author:      Accenture 
* @Date:        24 Sept 2024
* @Description: The purpose of this class is to cover Code coverage of UserTriggerHandler
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]
                24Sept -  EDRD-911          -  Deepak   -  Added activateACROnEDRDPortalEnable_Test method
***********************************************************************************************/
@isTest
public class UserTriggerHandlerTest {
    
/**
* @author: Deepak
* @date: 24 Sept 2024
* @description: The purpose of this method is to cover Testcoverage of activateACROnAccportalEnable
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/    
    @isTest
    public static void activateACROnEDRDPortalEnable_Test(){
        Account patientAcc1 = TestFactory.newPatient('Patient1');
        insert patientAcc1;
        Account providerAcc = TestFactory.newProvider('Provider Test');
        insert providerAcc;
        
        Id patientContactId = [SELECT Id FROM Contact Where accountId =: patientAcc1.Id].get(0).Id;
        AccountContactRelation ACRObj = new AccountContactRelation();
        ACRObj.AccountId = providerAcc.Id;
        ACRObj.ContactId = patientContactId;
        ACRObj.Roles = ESA_cls_constants.EDRD_PHYSICIAN;
        ACRObj.IsActive = false;
        ACRObj.Is_EDRD_Data_Migration__c = true;
        insert ACRObj;
        
        Profile profileObj = [SELECT Id FROM Profile WHERE Name =: ESA_cls_constants.EDRD_PRESCRIBER_COMMUNITY_USER LIMIT 1];
        Id ContactId = [SELECT Id FROM Contact WHERE AccountID =: providerAcc.Id].get(0).Id;
        User accCommunityUser = TestFactory.createCommunityUser(ContactId, profileObj.Id, 'Provider', 'Test');
        
        Test.startTest();
        insert accCommunityUser;
        Test.stopTest();
        
        List<User> communityUser = [SELECT Id FROM User WHERE Id =: accCommunityUser.Id LIMIT 1];
        
        List<Account> accUser = [SELECT Id, IsCustomerPortal FROM Account WHERE Id =: providerAcc.Id LIMIT 1];
        
        List<AccountContactRelation> aCRList = [SELECT Id, AccountId, ContactId, Roles, Is_EDRD_Data_Migration__c, IsActive 
                                                FROM AccountContactRelation 
                                                WHERE AccountID =: providerAcc.Id LIMIT 1];
        
        List<AccountShare> accShareList1 = [SELECT Id, AccountId, UserOrGroupId, RowCause, AccountAccessLevel 
                                            FROM AccountShare WHERE AccountId =: patientAcc1.Id 
                                            AND UserOrGroupId =: accCommunityUser.Id LIMIT 1];
        
        Assert.areEqual(accUser[0].IsCustomerPortal, True, 'Portal User should be Active');
        Assert.areEqual(aCRList[0].isActive, True, 'ACR should be Active');
        Assert.areEqual(accShareList1[0].AccountAccessLevel, 'Edit', 'AccountShare access level should be Edit');
        Assert.areEqual(accShareList1.size(), 1, 'AccountShare should have been created for the Patient');
        Assert.areNotEqual(accShareList1.isEmpty(), true, 'AccountShare list should not be empty');
        Assert.areNotEqual(accShareList1[0].UserOrGroupId, null, 'UserOrGroupId should not be null');  
    }
}