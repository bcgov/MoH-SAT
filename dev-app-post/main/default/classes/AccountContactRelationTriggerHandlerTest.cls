/**********************************************************************************************
* @Author:      Accenture 
* @Date:        21/08/2024
* @Description: The purpose of this class is to cover Code coverage of AccountContactRelationTriggerHandler
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description] 
                21 Aug -  EDRD-911          -  Accenture   -  Added Patient Share/delete With Provider User
                20 Dec -  EDRD-1150         -  Accenture   -  The purpose of this method is to update Committee based on ACR insert of EDRD_Committee & Provider OR Committee_Reviewer.
                20 Dec -  EDRD-1150         -  Accenture   -  The purpose of this method is to Remove Committee based on ACR delete of EDRD_Committee & Provider OR Committee_Reviewer.
                06 Jun -  EDRD-1476         -  Accenture   -  The purpose of this method is to Create a EDRD Public Group for provider whenever an ACR is created with Allied staff role
                29 Jun -  EDRD-1476         -  Accenture   -  The purpose of this method is to Collect Contact Account & Contact from ACR to perform GM delete.
                29 Jun -  EDRD-1476         -  Accenture   -  The purpose of this method is to sent Ids to deleted Contact Users from Provider Public Group in async.
                29 Jun -  EDRD-1476         -  Accenture   -  The purpose of this future method is to deleted Contact Users from Provider Public Group in Elevated access.
***********************************************************************************************/
@isTest
public class AccountContactRelationTriggerHandlerTest {
    
    @TestSetUp
    public static void createTestACRData() {
        List<Account> providerAccToInsert = new List<Account>();
        Account pharmacistAccount = TestFactory.newProvider('Patient Test');
        pharmacistAccount.Provider_Identifier__pc = '811222334';
        providerAccToInsert.add(pharmacistAccount);
        Account prescriberAccount = TestFactory.newProvider('Provider Test');
        prescriberAccount.Provider_Identifier__pc = '711222334';
        prescriberAccount.Provider_Type__pc = 'Physician';
        providerAccToInsert.add(prescriberAccount);
        insert providerAccToInsert;
        
        Map<Id, Contact> contactIdVsRec = new Map<Id, Contact>();
        for (Contact con : [SELECT Id, AccountId FROM Contact WHERE AccountId IN :providerAccToInsert]) {
            contactIdVsRec.put(con.AccountId, con);
        }
        Id prescriberConId = contactIdVsRec.get(prescriberAccount.Id).Id;
        Id pharmacistConId = contactIdVsRec.get(pharmacistAccount.Id).Id;
        
        Map<String, Profile> profileMap = new Map<String, Profile>();
        for(Profile profileObj: [SELECT Id, Name FROM Profile WHERE Name IN ('EDRD Prescriber Community User', 'BC HLTH Pharmacist Community User')]){
            profileMap.put(profileObj.Name, profileObj);
        }
        List<User> communityUserToInsert = new List<User>();
        User providercommunityUser = TestFactory.createCommunityUser(prescriberConId, profileMap.get('EDRD Prescriber Community User').Id, 'Test1', 'Provider');
        communityUserToInsert.add(providercommunityUser);
        User pharmacistCommunityUser = TestFactory.createCommunityUser(pharmacistConId, profileMap.get('BC HLTH Pharmacist Community User').Id, 'Test1', 'Pharmacist');
        communityUserToInsert.add(pharmacistCommunityUser);
        insert communityUserToInsert;
        
        AccountContactRelation ACRRec = new AccountContactRelation();
        ACRRec.AccountId = prescriberAccount.Id;
        ACRRec.ContactId = pharmacistConId;
        ACRRec.Roles = 'Allied Staff'; 
        
        Test.startTest();
        insert ACRRec;
        Test.stopTest();        
    }
    
/**
* @author: Deepak
* @date: 21 Aug 2024
* @description: The purpose of this method is to cover Testcoverage of createPatientShare
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/    
   /* @isTest
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
    } */
    
/**
* @author: Deepak
* @date: 21 Aug 2024
* @description: The purpose of this method is to cover Testcoverage of removePatientShare
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/   
   /* @isTest
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
    }  */
    
/**
* @author: Deepak
* @date: 03 Sept 2024
* @description: The purpose of this method is to cover Testcoverage of updatePatientShare
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/   
   /* @isTest
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
    }  */
    
/**
* @author: Deepak
* @date: 20 Dec 2024
* @description: The purpose of this method is to cover Testcoverage of updateCommitteeFieldOnACRInsert
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/   
    @isTest
    public static void updateCommitteeFieldOnACRInsertTest(){
        List<Account> providerList = new List<Account>();
        Account providerAcc = TestFactory.newProvider('Provider');
        providerAcc.Provider_Type__pc = ESA_cls_constants.EDRD_PHYSICIAN;
        providerList.add(providerAcc);
        Account providerAcc2 = TestFactory.newProvider('Provider2');
        providerAcc2.Provider_Identifier__pc = '111222';
        providerAcc2.Provider_Type__pc = ESA_cls_constants.EDRD_PHYSICIAN;
        providerList.add(providerAcc2);
        Account providerAcc3 = TestFactory.newProvider('Provider3');
        providerAcc3.Committee__pc = ESA_cls_constants.EDRD_PERSONACCOUNT_SC;
        providerAcc3.Committee_Name__pc = ESA_cls_constants.EDRD_PERSONACCOUNT_SC_METABOLIC_SUBCOMMITTEE;
        providerAcc3.Provider_Identifier__pc = '1112223';
        providerAcc3.Provider_Type__pc = ESA_cls_constants.EDRD_PHYSICIAN;
        providerList.add(providerAcc3);
        Account providerAcc4 = TestFactory.newProvider('Provider4');
        providerAcc4.Committee__pc = ESA_cls_constants.EDRD_PERSONACCOUNT_AC;
        providerAcc4.Provider_Identifier__pc = '1112224';
        providerAcc4.Provider_Type__pc = ESA_cls_constants.EDRD_PHYSICIAN;
        providerList.add(providerAcc4);
        Account providerAcc5 = TestFactory.newProvider('Provider5');
        providerAcc5.Committee__pc = ESA_cls_constants.EDRD_PERSONACCOUNT_ACSC;
        providerAcc5.Committee_Name__pc = 'Cystic Fibrosis Subcommittee;Ophthalmology Subcommittee';
        providerAcc5.Provider_Identifier__pc = '1112225';
        providerAcc5.Provider_Type__pc = ESA_cls_constants.EDRD_PHYSICIAN;
        providerList.add(providerAcc5);
        Account providerAcc6 = TestFactory.newProvider('Provider6');
        providerAcc6.Committee__pc = ESA_cls_constants.EDRD_PERSONACCOUNT_SC;
        providerAcc6.Committee_Name__pc = ESA_cls_constants.EDRD_PERSONACCOUNT_SC_METABOLIC_SUBCOMMITTEE;
        providerAcc6.Provider_Identifier__pc = '7112223';
        providerAcc6.Provider_Type__pc = ESA_cls_constants.EDRD_PHYSICIAN;
        providerList.add(providerAcc6);
        insert providerList;
        
        List<Account> committeeList = new List<Account>();
        Account sCBusinessAcc = TestFactory.createEDRDSCAccount(ESA_cls_constants.EDRD_PERSONACCOUNT_SC_METABOLIC_SUBCOMMITTEE);
        committeeList.add(sCBusinessAcc);
        Account sCBusinessAcc1 = TestFactory.createEDRDSCAccount('Cardiac Subcommittee');
        committeeList.add(sCBusinessAcc1);
        Account aCBusinessAcc = TestFactory.createEDRDACAccount(ESA_cls_constants.EDRD_PERSONACCOUNT_AC);
        committeeList.add(aCBusinessAcc);
        insert committeeList;
        
        List<AccountContactRelation> aCRListTOInsert = new List<AccountContactRelation>();
        Id providerContactId = [SELECT Id FROM Contact Where accountId =: providerAcc.Id].get(0).Id;
        AccountContactRelation ACRObj = new AccountContactRelation();
        ACRObj.AccountId = sCBusinessAcc.Id;
        ACRObj.ContactId = providerContactId;
        ACRObj.Roles = ESA_cls_constants.EDRD_ACR_ROLES_REVIEWER;
        aCRListTOInsert.add(ACRObj);
        Id provider2ContactId = [SELECT Id FROM Contact Where accountId =: providerAcc2.Id].get(0).Id;
        AccountContactRelation ACRObj2 = new AccountContactRelation();
        ACRObj2.AccountId = aCBusinessAcc.Id;
        ACRObj2.ContactId = provider2ContactId;
        ACRObj2.Roles = ESA_cls_constants.EDRD_ACR_ROLES_CHAIR;
        aCRListTOInsert.add(ACRObj2);
        Id provider3ContactId = [SELECT Id FROM Contact Where accountId =: providerAcc3.Id].get(0).Id;
        AccountContactRelation ACRObj3 = new AccountContactRelation();
        ACRObj3.AccountId = aCBusinessAcc.Id;
        ACRObj3.ContactId = provider3ContactId;
        ACRObj3.Roles = ESA_cls_constants.EDRD_ACR_ROLES_VICE_CHAIR;
        aCRListTOInsert.add(ACRObj3);
        Id provider4ContactId = [SELECT Id FROM Contact Where accountId =: providerAcc4.Id].get(0).Id;
        AccountContactRelation ACRObj4 = new AccountContactRelation();
        ACRObj4.AccountId = sCBusinessAcc1.Id;
        ACRObj4.ContactId = provider4ContactId;
        ACRObj4.Roles = ESA_cls_constants.EDRD_ACR_ROLES_VICE_CHAIR;
        aCRListTOInsert.add(ACRObj4);
        Id provider5ContactId = [SELECT Id FROM Contact Where accountId =: providerAcc5.Id].get(0).Id;
        AccountContactRelation ACRObj5 = new AccountContactRelation();
        ACRObj5.AccountId = sCBusinessAcc1.Id;
        ACRObj5.ContactId = provider5ContactId;
        ACRObj5.Roles = ESA_cls_constants.EDRD_ACR_ROLES_CHAIR;
        aCRListTOInsert.add(ACRObj5);
        Id provider6ContactId = [SELECT Id FROM Contact Where accountId =: providerAcc6.Id].get(0).Id;
        AccountContactRelation ACRObj6 = new AccountContactRelation();
        ACRObj6.AccountId = sCBusinessAcc1.Id;
        ACRObj6.ContactId = provider6ContactId;
        ACRObj6.Roles = ESA_cls_constants.EDRD_ACR_ROLES_REVIEWER;
        aCRListTOInsert.add(ACRObj6);
        AccountContactRelation ACRObj7 = new AccountContactRelation();
        ACRObj7.AccountId = aCBusinessAcc.Id;
        ACRObj7.ContactId = provider4ContactId;
        ACRObj7.Roles = ESA_cls_constants.EDRD_ACR_ROLES_CHAIR;
        aCRListTOInsert.add(ACRObj7);
        AccountContactRelation ACRObj8 = new AccountContactRelation();
        ACRObj8.AccountId = aCBusinessAcc.Id;
        ACRObj8.ContactId = provider5ContactId;
        ACRObj8.Roles = ESA_cls_constants.EDRD_ACR_ROLES_VICE_CHAIR;
        aCRListTOInsert.add(ACRObj8);
        
        Test.startTest();
        insert aCRListTOInsert;
        Test.stopTest();
        
        Map<Id, Account> updatedProviders = new Map<Id, Account>([SELECT Id, Committee__pc, Committee_Name__pc FROM Account
                                                                  WHERE Id IN (:providerAcc.Id, :providerAcc2.Id, :providerAcc3.Id)]);
        
        Account updatedProviderAccount = updatedProviders.get(providerAcc.Id);
        Assert.areEqual(ESA_cls_constants.EDRD_PERSONACCOUNT_SC, updatedProviderAccount.Committee__pc, 'Provider Record should be updated');
        Assert.areNotEqual(NULL, updatedProviderAccount.Committee_Name__pc, 'Committee_Name__pc on provider field should not be NULL');
        Assert.areEqual('Metabolic Subcommittee', updatedProviderAccount.Committee_Name__pc, 'Provider Committee_Name__pc should be updated');
        
        Account updatedProviderAccount2 = updatedProviders.get(providerAcc2.Id);
        Assert.areEqual(ESA_cls_constants.EDRD_PERSONACCOUNT_AC, updatedProviderAccount2.Committee__pc, 'Provider Record should be updated');
        Assert.areEqual(NULL, updatedProviderAccount2.Committee_Name__pc, 'Provider2 Committee_Name__pc should be NULL');
        
        Account updatedProviderAccount3 = updatedProviders.get(providerAcc3.Id);
        Assert.areEqual(ESA_cls_constants.EDRD_PERSONACCOUNT_ACSC, updatedProviderAccount3.Committee__pc, 'Provider3 Record should be updated');
        Assert.areNotEqual(NULL, updatedProviderAccount3.Committee_Name__pc, 'Committee_Name__pc on provider3 field should not be NULL');
        Assert.areEqual('Metabolic Subcommittee', updatedProviderAccount3.Committee_Name__pc, 'Provider Committee_Name__pc should be updated');
    }
    
/**
* @author: Deepak
* @date: 20 Dec 2024
* @description: The purpose of this method is to cover Testcoverage of removeCommitteeFieldOnACRDelete
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/   
    @isTest
    public static void removeCommitteeFieldOnACRDeleteTest(){
        List<Account> providerAccList = new List<Account>();
        Account provider = TestFactory.newProvider('Provider');
        provider.Provider_Type__pc = ESA_cls_constants.EDRD_PHYSICIAN;
        providerAccList.add(provider);
        Account provider2 = TestFactory.newProvider('Provider2');
        provider2.Provider_Identifier__pc = '111222';
        provider2.Provider_Type__pc = ESA_cls_constants.EDRD_PHYSICIAN;
        providerAccList.add(provider2);
        Account provider3 = TestFactory.newProvider('Provider3');
        provider3.Committee__pc = ESA_cls_constants.EDRD_PERSONACCOUNT_SC;
        provider3.Committee_Name__pc = ESA_cls_constants.EDRD_PERSONACCOUNT_SC_METABOLIC_SUBCOMMITTEE;
        provider3.Provider_Identifier__pc = '1112223';
        provider3.Provider_Type__pc = ESA_cls_constants.EDRD_PHYSICIAN;
        providerAccList.add(provider3);
        insert providerAccList;
        
        List<Account> committeeList = new List<Account>();
        Account sCBusinessAcc = TestFactory.createEDRDSCAccount(ESA_cls_constants.EDRD_PERSONACCOUNT_SC_METABOLIC_SUBCOMMITTEE);
        committeeList.add(sCBusinessAcc);
        Account aCBusinessAcc = TestFactory.createEDRDACAccount(ESA_cls_constants.EDRD_PERSONACCOUNT_AC);
        committeeList.add(aCBusinessAcc);
        insert committeeList;
        
        List<AccountContactRelation> aCRListTOInsert = new List<AccountContactRelation>();
        Id providerContactId = [SELECT Id FROM Contact Where accountId =: provider.Id].get(0).Id;
        AccountContactRelation ACRObj = new AccountContactRelation();
        ACRObj.AccountId = sCBusinessAcc.Id;
        ACRObj.ContactId = providerContactId;
        ACRObj.Roles = ESA_cls_constants.EDRD_ACR_ROLES_REVIEWER;
        aCRListTOInsert.add(ACRObj);
        Id provider2ContactId = [SELECT Id FROM Contact Where accountId =: provider2.Id].get(0).Id;
        AccountContactRelation ACRObj2 = new AccountContactRelation();
        ACRObj2.AccountId = aCBusinessAcc.Id;
        ACRObj2.ContactId = provider2ContactId;
        ACRObj2.Roles = ESA_cls_constants.EDRD_ACR_ROLES_CHAIR;
        aCRListTOInsert.add(ACRObj2);
        Id provider3ContactId = [SELECT Id FROM Contact Where accountId =: provider3.Id].get(0).Id;
        AccountContactRelation ACRObj3 = new AccountContactRelation();
        ACRObj3.AccountId = aCBusinessAcc.Id;
        ACRObj3.ContactId = provider3ContactId;
        ACRObj3.Roles = ESA_cls_constants.EDRD_ACR_ROLES_VICE_CHAIR;
        aCRListTOInsert.add(ACRObj3);
        insert aCRListTOInsert;
        
        Test.startTest();
        delete aCRListTOInsert;
        Test.stopTest();
        
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, Committee__pc, Committee_Name__pc FROM Account 
                                                            WHERE Id IN :new Set<Id>{provider2.Id, provider3.Id}]);
        
        Account provider3AfterDelete = accountMap.get(provider3.Id);
        Assert.areEqual(provider3AfterDelete.Committee__pc, ESA_cls_constants.EDRD_PERSONACCOUNT_SC, 'Committee should be null after deletion');
        Assert.areEqual(provider3AfterDelete.Committee_Name__pc, ESA_cls_constants.EDRD_PERSONACCOUNT_SC_METABOLIC_SUBCOMMITTEE, 'Committee Name should be null after deletion');
        Assert.areNotEqual(provider3AfterDelete.Committee__pc, NULL, 'Committee should not be null after deletion');
        Assert.areNotEqual(provider3AfterDelete.Committee_Name__pc, NULL, 'Committee Name should not be null after deletion');
        
        Account provider2AfterDelete = accountMap.get(provider2.Id);
        Assert.areEqual(provider2AfterDelete.Committee__pc, NULL, 'Provider2 Committee should not be null');
        Assert.areEqual(provider2AfterDelete.Committee_Name__pc, NULL, 'Provider2 Committee Name should remain unchanged');        
    }
    
/**
* @author: Deepak
* @date: 29 Jun 2025
* @description: The purpose of this method is to cover Testcoverage of handleAlliedStaffACRPGInsert/generateGroupName/addProvisionedUsersToProviderGroups
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/   
    @isTest
    public static void handleAlliedStaffACRPGInsertNAddToProviderPGTest(){
        List<Account> providerAccList = new List<Account>();
        Account pharmacistAcc = TestFactory.newProvider('Patient Test');
        providerAccList.add(pharmacistAcc);
        Account prescriberAcc = TestFactory.newProvider('Provider Test');
        prescriberAcc.Provider_Identifier__pc = '111222334';
        prescriberAcc.Provider_Type__pc = 'Physician';
        providerAccList.add(prescriberAcc);
        insert providerAccList;
        
        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        for (Contact con : [SELECT Id, AccountId FROM Contact WHERE AccountId IN :providerAccList]) {
            contactMap.put(con.AccountId, con);
        }
        Id prescriberContactId = contactMap.get(prescriberAcc.Id).Id;
        Id pharmacistContactId = contactMap.get(pharmacistAcc.Id).Id;
        
        Map<String, Profile> profileMap = new Map<String, Profile>();
        for(Profile profileObj: [SELECT Id, Name FROM Profile WHERE Name IN ('EDRD Prescriber Community User', 'BC HLTH Pharmacist Community User')]){
            profileMap.put(profileObj.Name, profileObj);
        }
        List<User> communityUserToInsert = new List<User>();
        User providercommunityUser = TestFactory.createCommunityUser(prescriberContactId, profileMap.get('EDRD Prescriber Community User').Id, 'Test1', 'Provider');
        communityUserToInsert.add(providercommunityUser);
        User pharmacistCommunityUser = TestFactory.createCommunityUser(pharmacistContactId, profileMap.get('BC HLTH Pharmacist Community User').Id, 'Test1', 'Pharmacist');
        communityUserToInsert.add(pharmacistCommunityUser);
        insert communityUserToInsert;
        
        AccountContactRelation ACRObj = new AccountContactRelation();
        ACRObj.AccountId = prescriberAcc.Id;
        ACRObj.ContactId = pharmacistContactId;
        ACRObj.Roles = 'Allied Staff';
        
        Test.startTest();
        insert ACRObj;
        Test.stopTest();
        
        Account updatedPrescriberAcc = [SELECT Id, EDRD_Provider_Public_GroupId__pc FROM Account WHERE Id =: prescriberAcc.Id];
        Assert.areNotEqual(null, updatedPrescriberAcc.EDRD_Provider_Public_GroupId__pc, 'Public Group ID should be set on Provider Account');
        
        Group publicGroup = [SELECT Id, Name FROM Group WHERE Id =: updatedPrescriberAcc.EDRD_Provider_Public_GroupId__pc];
        Assert.areEqual(updatedPrescriberAcc.EDRD_Provider_Public_GroupId__pc, publicGroup.Id, 'Group Id should present');
        Assert.areNotEqual(null, updatedPrescriberAcc.EDRD_Provider_Public_GroupId__pc, 'Public Group ID should not be Null');
        
        List<GroupMember> gmList = [SELECT Id, GroupId, UserOrGroupId FROM GroupMember WHERE GroupId = :publicGroup.Id];
        Set<Id> userIdsInGroup = new Set<Id>();
        for (GroupMember gm : gmList) {
            userIdsInGroup.add(gm.UserOrGroupId);
        }        
        Assert.areEqual(true, userIdsInGroup.contains(pharmacistCommunityUser.Id), 'Allied Staff User should be part of Provider Public Group');
    }
    
/**
* @author: Deepak
* @date: 29 Jun 2025
* @description: The purpose of this method is to cover Testcoverage of removeAlliedStaffFromPG/removeAlliedStaffFromProviderGroup/deleteGMAsync.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/   
    @isTest
    public static void removeAlliedStaffFromPGTest(){
        List<AccountContactRelation> aCRRec = [SELECT Id FROM AccountContactRelation WHERE Roles = 'Allied Staff'];  
        List<Account> prescriberAccount = [SELECT Id FROM Account WHERE Provider_Identifier__pc = '711222334' LIMIT 1]; 
        Map<String, User> communityUserMap = new Map<String, User>();
        for (User userObj : [SELECT Id, Profile.Name FROM User WHERE Profile.Name IN ('EDRD Prescriber Community User', 'BC HLTH Pharmacist Community User')]) {
            communityUserMap.put(userObj.Profile.Name, userObj);
        }
        User providerCommunityUser = communityUserMap.get('EDRD Prescriber Community User');
        User pharmacistCommunityUser = communityUserMap.get('BC HLTH Pharmacist Community User');
        
        Test.startTest();
        delete ACRRec;
        Test.stopTest();               
        
        Account accWithGroup = [SELECT Id, EDRD_Provider_Public_GroupId__pc FROM Account WHERE Id =: prescriberAccount[0].Id LIMIT 1];
        List<GroupMember> gmList = [SELECT Id, GroupId, UserOrGroupId FROM GroupMember WHERE GroupId =: accWithGroup.EDRD_Provider_Public_GroupId__pc LIMIT 1];
        
        Set<Id> userIdsInGroup = new Set<Id>();
        for (GroupMember gm : gmList) {
            userIdsInGroup.add(gm.UserOrGroupId);
        }
        
        Assert.areEqual(true, !userIdsInGroup.contains(pharmacistCommunityUser.Id), 'Pharmacist should be removed from Provider Public Group');
        Assert.areNotEqual(false, !userIdsInGroup.contains(pharmacistCommunityUser.Id), 'Pharmacist should be not be in Provider Public Group');
        //Assert.areEqual(true, userIdsInGroup.contains(providerCommunityUser.Id), 'Provider should still be present in Provider Public Group');
        //Assert.areEqual(false, !userIdsInGroup.contains(providerCommunityUser.Id), 'Provider should be in Provider Public Group');
    }
}