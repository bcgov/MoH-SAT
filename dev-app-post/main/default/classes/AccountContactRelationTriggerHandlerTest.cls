/**********************************************************************************************
* @Author:      Accenture 
* @Date:        21/08/2024
* @Description: The purpose of this class is to cover Code coverage of AccountContactRelationTriggerHandler
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description] 
                21 Aug -  EDRD-911          -  Accenture   -  Added Patient Share/delete With Provider User
                20 Dec -  EDRD-1150         -  Accenture   -  The purpose of this method is to update Committee based on ACR insert of EDRD_Committee & Provider OR Committee_Reviewer.
                20 Dec -  EDRD-1150         -  Accenture   -  The purpose of this method is to Remove Committee based on ACR delete of EDRD_Committee & Provider OR Committee_Reviewer.
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
        providerAcc.Provider_Type__pc = 'Physician';
        providerList.add(providerAcc);
        Account providerAcc2 = TestFactory.newProvider('Provider2');
        providerAcc2.Provider_Identifier__pc = '111222';
        providerAcc2.Provider_Type__pc = 'Physician';
        providerList.add(providerAcc2);
        Account providerAcc3 = TestFactory.newProvider('Provider3');
        providerAcc3.Committee__pc = 'EDRD Sub Committee';
        providerAcc3.Committee_Name__pc = 'Metabolic Subcommittee';
        providerAcc3.Provider_Identifier__pc = '1112223';
        providerAcc3.Provider_Type__pc = 'Physician';
        providerList.add(providerAcc3);
        Account providerAcc4 = TestFactory.newProvider('Provider4');
        providerAcc4.Committee__pc = 'EDRD Advisory Committee';
        providerAcc4.Provider_Identifier__pc = '1112224';
        providerAcc4.Provider_Type__pc = 'Physician';
        providerList.add(providerAcc4);
        Account providerAcc5 = TestFactory.newProvider('Provider5');
        providerAcc5.Committee__pc = 'EDRD Advisory/ Sub Committee';
        providerAcc5.Committee_Name__pc = 'Cystic Fibrosis Subcommittee;Ophthalmology Subcommittee';
        providerAcc5.Provider_Identifier__pc = '1112225';
        providerAcc5.Provider_Type__pc = 'Physician';
        providerList.add(providerAcc5);
        insert providerList;
        
        List<Account> committeeList = new List<Account>();
        Account sCBusinessAcc = TestFactory.createEDRDSCAccount('Metabolic Subcommittee');
        committeeList.add(sCBusinessAcc);
        Account sCBusinessAcc1 = TestFactory.createEDRDSCAccount('Cardiac Subcommittee');
        committeeList.add(sCBusinessAcc1);
        Account aCBusinessAcc = TestFactory.createEDRDACAccount('EDRD Advisory Committee');
        committeeList.add(aCBusinessAcc);
        insert committeeList;
        
        List<AccountContactRelation> aCRListTOInsert = new List<AccountContactRelation>();
        Id providerContactId = [SELECT Id FROM Contact Where accountId =: providerAcc.Id].get(0).Id;
        AccountContactRelation ACRObj = new AccountContactRelation();
        ACRObj.AccountId = sCBusinessAcc.Id;
        ACRObj.ContactId = providerContactId;
        ACRObj.Roles = 'Reviewer';
        aCRListTOInsert.add(ACRObj);
        Id provider2ContactId = [SELECT Id FROM Contact Where accountId =: providerAcc2.Id].get(0).Id;
        AccountContactRelation ACRObj2 = new AccountContactRelation();
        ACRObj2.AccountId = aCBusinessAcc.Id;
        ACRObj2.ContactId = provider2ContactId;
        ACRObj2.Roles = 'Chair';
        aCRListTOInsert.add(ACRObj2);
        Id provider3ContactId = [SELECT Id FROM Contact Where accountId =: providerAcc3.Id].get(0).Id;
        AccountContactRelation ACRObj3 = new AccountContactRelation();
        ACRObj3.AccountId = aCBusinessAcc.Id;
        ACRObj3.ContactId = provider3ContactId;
        ACRObj3.Roles = 'Vice Chair';
        aCRListTOInsert.add(ACRObj3);
        Id provider4ContactId = [SELECT Id FROM Contact Where accountId =: providerAcc4.Id].get(0).Id;
        AccountContactRelation ACRObj4 = new AccountContactRelation();
        ACRObj4.AccountId = sCBusinessAcc1.Id;
        ACRObj4.ContactId = provider4ContactId;
        ACRObj4.Roles = 'Vice Chair';
        aCRListTOInsert.add(ACRObj4);
        Id provider5ContactId = [SELECT Id FROM Contact Where accountId =: providerAcc5.Id].get(0).Id;
        AccountContactRelation ACRObj5 = new AccountContactRelation();
        ACRObj5.AccountId = sCBusinessAcc1.Id;
        ACRObj5.ContactId = provider5ContactId;
        ACRObj5.Roles = 'Chair';
        aCRListTOInsert.add(ACRObj5);
        AccountContactRelation ACRObj6 = new AccountContactRelation();
        ACRObj6.AccountId = sCBusinessAcc1.Id;
        ACRObj6.ContactId = provider3ContactId;
        ACRObj6.Roles = 'Reviewer';
        aCRListTOInsert.add(ACRObj6);
        AccountContactRelation ACRObj7 = new AccountContactRelation();
        ACRObj7.AccountId = aCBusinessAcc.Id;
        ACRObj7.ContactId = provider4ContactId;
        ACRObj7.Roles = 'Chair';
        aCRListTOInsert.add(ACRObj7);
        AccountContactRelation ACRObj8 = new AccountContactRelation();
        ACRObj8.AccountId = aCBusinessAcc.Id;
        ACRObj8.ContactId = provider5ContactId;
        ACRObj8.Roles = 'Vice Chair';
        aCRListTOInsert.add(ACRObj8);
        
        Test.startTest();
        insert aCRListTOInsert;
        Test.stopTest();
        
        Map<Id, Account> updatedProviders = new Map<Id, Account>([SELECT Id, Committee__pc, Committee_Name__pc FROM Account
                                                                  WHERE Id IN (:providerAcc.Id, :providerAcc2.Id, :providerAcc3.Id)]);
        
        Account updatedProviderAccount = updatedProviders.get(providerAcc.Id);
        Assert.areEqual(updatedProviderAccount.Committee__pc, 'EDRD Sub Committee', 'Provider Record should be updated');
        Assert.areNotEqual(updatedProviderAccount.Committee_Name__pc, NULL, 'Committee_Name__pc on provider field should not be NULL');
        Assert.areEqual(updatedProviderAccount.Committee_Name__pc, 'Metabolic Subcommittee', 'Provider Committee_Name__pc should be updated');
        
        Account updatedProviderAccount2 = updatedProviders.get(providerAcc2.Id);
        Assert.areEqual(updatedProviderAccount2.Committee__pc, 'EDRD Advisory Committee','Provider Record should be updated');
        Assert.areEqual(updatedProviderAccount2.Committee_Name__pc, NULL, 'Provider2 Committee_Name__pc should be NULL');
        
        Account updatedProviderAccount3 = updatedProviders.get(providerAcc3.Id);
        Assert.areEqual(updatedProviderAccount3.Committee__pc, 'EDRD Advisory/ Sub Committee', 'Provider3 Record should be updated');
        Assert.areNotEqual(updatedProviderAccount3.Committee_Name__pc, NULL, 'Committee_Name__pc on provider3 field should not be NULL');
        Assert.areEqual(updatedProviderAccount3.Committee_Name__pc, 'Cardiac Subcommittee;Metabolic Subcommittee', 'Provider Committee_Name__pc should be updated');
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
        provider.Provider_Type__pc = 'Physician';
        providerAccList.add(provider);
        Account provider2 = TestFactory.newProvider('Provider2');
        provider2.Provider_Identifier__pc = '111222';
        provider2.Provider_Type__pc = 'Physician';
        providerAccList.add(provider2);
        Account provider3 = TestFactory.newProvider('Provider3');
        provider3.Committee__pc = 'EDRD Sub Committee';
        provider3.Committee_Name__pc = 'Metabolic Subcommittee';
        provider3.Provider_Identifier__pc = '1112223';
        provider3.Provider_Type__pc = 'Physician';
        providerAccList.add(provider3);
        insert providerAccList;
        
        List<Account> committeeList = new List<Account>();
        Account sCBusinessAcc = TestFactory.createEDRDSCAccount('Metabolic Subcommittee');
        committeeList.add(sCBusinessAcc);
        Account aCBusinessAcc = TestFactory.createEDRDACAccount('EDRD Advisory Committee');
        committeeList.add(aCBusinessAcc);
        insert committeeList;
        
        List<AccountContactRelation> aCRListTOInsert = new List<AccountContactRelation>();
        Id providerContactId = [SELECT Id FROM Contact Where accountId =: provider.Id].get(0).Id;
        AccountContactRelation ACRObj = new AccountContactRelation();
        ACRObj.AccountId = sCBusinessAcc.Id;
        ACRObj.ContactId = providerContactId;
        ACRObj.Roles = 'Reviewer';
        aCRListTOInsert.add(ACRObj);
        Id provider2ContactId = [SELECT Id FROM Contact Where accountId =: provider2.Id].get(0).Id;
        AccountContactRelation ACRObj2 = new AccountContactRelation();
        ACRObj2.AccountId = aCBusinessAcc.Id;
        ACRObj2.ContactId = provider2ContactId;
        ACRObj2.Roles = 'Chair';
        aCRListTOInsert.add(ACRObj2);
        Id provider3ContactId = [SELECT Id FROM Contact Where accountId =: provider3.Id].get(0).Id;
        AccountContactRelation ACRObj3 = new AccountContactRelation();
        ACRObj3.AccountId = aCBusinessAcc.Id;
        ACRObj3.ContactId = provider3ContactId;
        ACRObj3.Roles = 'Vice Chair';
        aCRListTOInsert.add(ACRObj3);
        insert aCRListTOInsert;
        
        Test.startTest();
        delete aCRListTOInsert;
        Test.stopTest();
        
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, Committee__pc, Committee_Name__pc FROM Account 
                                                            WHERE Id IN :new Set<Id>{provider2.Id, provider3.Id}]);
        
        Account provider3AfterDelete = accountMap.get(provider3.Id);
        Assert.areEqual(provider3AfterDelete.Committee__pc, 'EDRD Sub Committee', 'Committee should be null after deletion');
        Assert.areEqual(provider3AfterDelete.Committee_Name__pc, 'Metabolic Subcommittee', 'Committee Name should be null after deletion');
        Assert.areNotEqual(provider3AfterDelete.Committee__pc, NULL, 'Committee should not be null after deletion');
        Assert.areNotEqual(provider3AfterDelete.Committee_Name__pc, NULL, 'Committee Name should not be null after deletion');
        
        Account provider2AfterDelete = accountMap.get(provider2.Id);
        Assert.areEqual(provider2AfterDelete.Committee__pc, NULL, 'Provider2 Committee should not be null');
        Assert.areEqual(provider2AfterDelete.Committee_Name__pc, NULL, 'Provider2 Committee Name should remain unchanged');        
    }
}