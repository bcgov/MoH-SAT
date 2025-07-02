/**********************************************************************************************
* @Author:      Accenture 
* @Date:        21 Aug 2024
* @Description: The purpose of this class is to create methods which can be used by different trigger event
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
                21 Aug -  EDRD-911          -  Accenture   -  Added Patient Share/delete With Provider User
                13 Dec -  EDRD-1150         -  Accenture   -  The purpose of this method is to update Committee based on ACR insert of EDRD_Committee & Provider OR Committee_Reviewer.
                20 Dec -  EDRD-1150         -  Accenture   -  The purpose of this method is to Remove Committee based on ACR delete of EDRD_Committee & Provider OR Committee_Reviewer.
                06 Jun -  EDRD-1476         -  Accenture   -  The purpose of this method is to Create a EDRD Public Group for provider whenever an ACR is created with Allied staff role
                06 Jun -  EDRD-1476         -  Accenture   -  The purpose of this method is to generate EDRD Public Group name for provider.
                29 Jun -  EDRD-1476         -  Accenture   -  The purpose of this future method is to Create a EDRD Public Group for provider whenever an ACR is created with Allied staff role.
                29 Jun -  EDRD-1476         -  Accenture   -  The purpose of this method is to Collect Contact Account & Contact from ACR to perform GM delete.
                29 Jun -  EDRD-1476         -  Accenture   -  The purpose of this method is to sent Ids to deleted Contact Users from Provider Public Group in async.
                29 Jun -  EDRD-1476         -  Accenture   -  The purpose of this future method is to deleted Contact Users from Provider Public Group in Elevated access.
                29 Jun -  EDRD-1476         -  Accenture   -  Class/Methods is to perform DML in without Sharing Context.
***********************************************************************************************/
public with sharing class AccountContactRelationTriggerHandler {
/**
* @author: Deepak
* @date: 21 Aug 2024
* @description: The purpose of this method is to share patient records with provider on ACR insert.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
                     20Sept -  EDRD-911      -  Deepak      -  Adding NULL Check & updated asper user trigger
*/     
   /* public static void createPatientShare(List<AccountContactRelation> aCRList){
        Map<Id, Set<Id>> providerIdVsPatientIdSet = new Map<Id, Set<Id>>();
        Map<Id, User> providerIdVsRec = new Map<Id, User>();
        Map<Id, Set<Id>> providerIdVsUserIdSet = new Map<Id, Set<Id>>();
        List<AccountShare> accShareListToInsert = new List<AccountShare>();
        
        for(AccountContactRelation aCRObj : aCRList){
            if(!providerIdVsPatientIdSet.containsKey(aCRObj.AccountId)){
                providerIdVsPatientIdSet.put(aCRObj.AccountId, new Set<Id>());
            }
            if(aCRObj.Is_Person_Account__c && !String.IsEmpty(aCRObj.Roles) && aCRObj.Roles.containsIgnoreCase(ESA_cls_constants.EDRD_PHYSICIAN) && !aCRObj.Is_EDRD_Data_Migration__c){
                providerIdVsPatientIdSet.get(aCrObj.AccountId).add(acrObj.ContactAccountId__c);               
            }
        }
        
        if(!providerIdVsPatientIdSet.isEmpty()){
            providerIdVsRec = new Map<Id, User>([SELECT Id, Contact.AccountId FROM User 
                                                 WHERE Contact.AccountId IN :providerIdVsPatientIdSet.keySet()]);
        }
        
        if(!providerIdVsRec.isEmpty()){
            for(User userObj : providerIdVsRec.values()){
                if(!providerIdVsUserIdSet.containsKey(userObj.Contact.AccountId)){
                    providerIdVsUserIdSet.put(userObj.Contact.AccountId, new Set<Id>()); 
                }
                providerIdVsUserIdSet.get(userObj.Contact.AccountId).add(userObj.Id);
            }
            
            for(Id providerId: providerIdVsPatientIdSet.keySet()){
                for(Id userId: providerIdVsUserIdSet.get(providerId)){
                    for(Id patientId: providerIdVsPatientIdSet.get(providerId)){
                        accShareListToInsert.add(new AccountShare(AccountId = patientId,
                                                                  AccountAccessLevel = 'Edit', UserOrGroupId = UserId,
                                                                  OpportunityAccessLevel = 'None'));
                    }
                }
            }
            
            if(!accShareListToInsert.isEmpty()){
                AccountContactShareHelper.insertAccountShares(accShareListToInsert);
            }
        }
    } */
    
/**
* @author: Deepak
* @date: 21 Aug 2024
* @description: The purpose of this method is to remove patient record shared with provider on ACR delete.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/  
   /* public static void removePatientShare(List<AccountContactRelation> aCRList){
        Map<Id, Id> providerIdVsPatientId = new Map<Id, Id>();
        
        for(AccountContactRelation aCRObj: aCRList){
            if(aCRObj.Is_Person_Account__c && !String.IsEmpty(aCRObj.Roles) && aCRObj.Roles.containsIgnoreCase(ESA_cls_constants.EDRD_PHYSICIAN)){
                providerIdVsPatientId.put(aCRObj.AccountId, aCRObj.ContactAccountId__c);
            }
        }
        
        if(!providerIdVsPatientId.isEmpty()){
            List<AccountShare> accShareList = [SELECT Id FROM AccountShare WHERE AccountId IN :providerIdVsPatientId.values()
                                               AND UserOrGroupId IN 
                                               (SELECT Id FROM User WHERE Contact.AccountId IN :providerIdVsPatientId.keySet())];
            
            if(!accShareList.isEmpty()){
                AccountContactShareHelper.deleteAccountShares(accShareList);
            }
        }
    }  */
    
/**
* @author: Deepak
* @date: 03 Sept 2024
* @description: The purpose of this method is to update patient record shared with provider on ACR update.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/  
  /*  public static void updatePatientShare(Map<Id, AccountContactRelation> oldACRMap, Map<Id, AccountContactRelation> newACRMap){
        Map<Id, Id> providerIdVsPatientId = new Map<Id, Id>();
        List<AccountContactRelation> accShareListToInsert = new List<AccountContactRelation>();
        
        for(AccountContactRelation aCRObj : newACRMap.values()){
            if(aCRObj.Is_Person_Account__c && !String.IsEmpty(aCRObj.Roles) && aCRObj.Roles.containsIgnoreCase(ESA_cls_constants.EDRD_PHYSICIAN) && aCRObj.IsActive){
                providerIdVsPatientId.put(aCRObj.AccountId, aCRObj.ContactAccountId__c);
                accShareListToInsert.add(aCRObj);
            }
        }
        
        if(!providerIdVsPatientId.isEmpty()){
            List<AccountShare> accShareList = [SELECT Id FROM AccountShare WHERE AccountId IN :providerIdVsPatientId.values()
                                               AND UserOrGroupId IN 
                                               (SELECT Id FROM User WHERE Contact.AccountId IN :providerIdVsPatientId.keySet())];
            
            if(accShareList.isEmpty()){
               createPatientShare(accShareListToInsert);
            }
        }
    } */
    
/**
* @author: Deepak
* @date: 13 Dec 2024
* @description: The purpose of this method is to update Committee based on ACR insert of EDRD_Committee & Provider OR Committee_Reviewer.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/
    public static void updateCommitteeFieldOnACRInsert(List<AccountContactRelation> aCRList) {        
        Set<Id> contactIdSet = new Set<Id>();
        Set<Id> accountIdSet = new Set<Id>();
        Map<Id, Account> providerIdVsRecToUpdate = new map<Id, Account>();
        List<AccountContactRelation> aCRListToProcess = New List<AccountContactRelation>();
        Set<String> accRecTypeSet = new Set<String>{'EDRD_Committee', 'Provider', 'Committee_Reviewer'};
            try{   
                for (AccountContactRelation aCRObj : aCRList) {
                    if (!String.isEmpty(aCRObj.Roles) && aCRObj.IsActive &&
                        (aCRObj.Roles.containsIgnoreCase('Reviewer') || aCRObj.Roles.containsIgnoreCase('Chair') || aCRObj.Roles.containsIgnoreCase('Vice Chair'))){
                            contactIdSet.add(aCRObj.ContactId);
                            accountIdSet.add(aCRObj.AccountId);
                            aCRListToProcess.add(aCrObj);
                        }
                }
                
                Map<Id, Account> accIdVsRec = new Map<Id, Account>([SELECT Id, Recordtype.DeveloperName, EDRD_Committee_Type__c, Name FROM Account Where Id IN: accountIdSet]);
                Map<Id, Contact> contactIdVsRec = new Map<Id, Contact>([SELECT Id, Contact.AccountId, Contact.Account.Recordtype.DeveloperName, Contact.Account.Committee__pc, Contact.Account.Committee_Name__pc FROM Contact Where Id IN: contactIdSet]);
                Account providerAccount = new Account();
                for(AccountContactRelation acRObj: aCRListToProcess){
                    providerAccount = contactIdVsRec.get(aCrObj.ContactId).Account;
                    Account businessAccount = accIdVsRec.get(aCrObj.AccountId);
                    if(accRecTypeSet.Contains(businessAccount.RecordType.DeveloperName) || (accRecTypeSet.Contains(providerAccount.RecordType.DeveloperName))){
                        String businessCommitteeTypes = businessAccount.EDRD_Committee_Type__c;
                        String oldProviderCommittee = providerAccount.Committee__pc;
                        
                        if (ESA_cls_constants.EDRD_BUSINESS_SC_ACCOUNT.equalsIgnoreCase(businessCommitteeTypes) && oldProviderCommittee == NULL) {
                            providerAccount.Committee__pc = ESA_cls_constants.EDRD_PERSONACCOUNT_SC;
                            providerAccount.Committee_Name__pc = providerAccount.Committee_Name__pc != NULL ? providerAccount.Committee_Name__pc +';'+ businessAccount.Name : businessAccount.Name;
                            providerIdVsRecToUpdate.put(providerAccount.Id, providerAccount);
                        } else if (ESA_cls_constants.EDRD_BUSINESS_AC_ACCOUNT.equalsIgnoreCase(businessCommitteeTypes) && oldProviderCommittee == NULL) {
                            providerAccount.Committee__pc = ESA_cls_constants.EDRD_PERSONACCOUNT_AC;
                            providerIdVsRecToUpdate.put(providerAccount.Id, providerAccount);
                        } else if(ESA_cls_constants.EDRD_BUSINESS_SC_ACCOUNT.equalsIgnoreCase(businessCommitteeTypes) && oldProviderCommittee == ESA_cls_constants.EDRD_PERSONACCOUNT_SC){
                            providerAccount.Committee__pc = ESA_cls_constants.EDRD_PERSONACCOUNT_SC;
                            providerAccount.Committee_Name__pc = providerAccount.Committee_Name__pc != NULL ? providerAccount.Committee_Name__pc +';'+ businessAccount.Name : businessAccount.Name;
                            providerIdVsRecToUpdate.put(providerAccount.Id, providerAccount);
                        } else if(ESA_cls_constants.EDRD_BUSINESS_SC_ACCOUNT.equalsIgnoreCase(businessCommitteeTypes) && oldProviderCommittee == ESA_cls_constants.EDRD_PERSONACCOUNT_AC){
                            providerAccount.Committee__pc = ESA_cls_constants.EDRD_PERSONACCOUNT_ACSC;
                            providerAccount.Committee_Name__pc = providerAccount.Committee_Name__pc != NULL ? providerAccount.Committee_Name__pc +';'+ businessAccount.Name : businessAccount.Name;
                            providerIdVsRecToUpdate.put(providerAccount.Id, providerAccount);
                        } else if (ESA_cls_constants.EDRD_BUSINESS_SC_ACCOUNT.equalsIgnoreCase(businessCommitteeTypes) && providerAccount.Committee__pc == ESA_cls_constants.EDRD_PERSONACCOUNT_ACSC){
                            providerAccount.Committee_Name__pc = providerAccount.Committee_Name__pc != NULL ? providerAccount.Committee_Name__pc +';'+ businessAccount.Name : businessAccount.Name;
                            providerIdVsRecToUpdate.put(providerAccount.Id, providerAccount);
                        } else if(ESA_cls_constants.EDRD_BUSINESS_AC_ACCOUNT.equalsIgnoreCase(businessCommitteeTypes) && oldProviderCommittee == ESA_cls_constants.EDRD_PERSONACCOUNT_SC){
                            providerAccount.Committee__pc = ESA_cls_constants.EDRD_PERSONACCOUNT_ACSC;
                            providerIdVsRecToUpdate.put(providerAccount.Id, providerAccount);
                        } else if(ESA_cls_constants.EDRD_BUSINESS_AC_ACCOUNT.equalsIgnoreCase(businessCommitteeTypes) && oldProviderCommittee == ESA_cls_constants.EDRD_PERSONACCOUNT_AC){
                            providerAccount.Committee__pc = ESA_cls_constants.EDRD_PERSONACCOUNT_AC;
                            providerIdVsRecToUpdate.put(providerAccount.Id, providerAccount);
                        } else if(ESA_cls_constants.EDRD_BUSINESS_AC_ACCOUNT.equalsIgnoreCase(businessCommitteeTypes) && oldProviderCommittee == ESA_cls_constants.EDRD_PERSONACCOUNT_ACSC){
                            providerAccount.Committee__pc = ESA_cls_constants.EDRD_PERSONACCOUNT_ACSC;
                            providerIdVsRecToUpdate.put(providerAccount.Id, providerAccount);
                        }
                    }                
                }
                if (!providerIdVsRecToUpdate.isEmpty()) {           
                    Database.update(providerIdVsRecToUpdate.values(), true);
                }
            }catch (DmlException e) {
                System.debug('Error Updating Provider/Reviewer record: ' + e.getMessage());
            }
    }
    
/**
* @author: Deepak
* @date: 20 Dec 2024
* @description: The purpose of this method is to Remove Committee based on ACR delete of EDRD_Committee & Provider OR Committee_Reviewer.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/
    public static void removeCommitteeFieldOnACRDelete(List<AccountContactRelation> aCRList) {
        Set<Id> contactIdSet = new Set<Id>();
        Set<Id> accountIdSet = new Set<Id>();
        List<AccountContactRelation> aCRListToIterate = new List<AccountContactRelation>();
        Map<Id, Account> providerIdVsRecToUpdate = new Map<Id, Account>();
        Set<String> accRecTypeSet = new Set<String>{'EDRD_Committee', 'Provider', 'Committee_Reviewer'};
            
            try {
                for (AccountContactRelation aCRObj : aCRList) {
                    if (!String.isEmpty(aCRObj.Roles) && 
                        (aCRObj.Roles.containsIgnoreCase('Reviewer') || aCRObj.Roles.containsIgnoreCase('Chair') || aCRObj.Roles.containsIgnoreCase('Vice Chair'))) {
                            contactIdSet.add(aCRObj.ContactId);
                            accountIdSet.add(aCRObj.AccountId);
                            aCRListToIterate.add(aCRObj);
                        }
                }
                
                Map<Id, Account> accIdVsRec = new Map<Id, Account>([SELECT Id, RecordType.DeveloperName, EDRD_Committee_Type__c, Committee__pc, Committee_Name__pc, Name 
                                                                    FROM Account WHERE Id IN :accountIdSet]);
                Map<Id, Contact> contactIdVsRec = new Map<Id, Contact>([SELECT Id, AccountId, Account.RecordType.DeveloperName, Account.Committee__pc, Account.Committee_Name__pc, Account.FirstName, Account.LastName
                                                                        FROM Contact WHERE Id IN :contactIdSet]);
                
                for (AccountContactRelation aCRObj : aCRListToIterate) {
                    Account providerAccount = contactIdVsRec.get(aCrObj.ContactId)?.Account;
                    Account businessAccount = accIdVsRec.get(aCrObj.AccountId);
                    String sCToRemove = accIdVsRec.get(aCRObj.AccountId)?.Name;
                    String businessCommitteeTypes = businessAccount.EDRD_Committee_Type__c;                    
                    
                    if(ESA_cls_constants.EDRD_BUSINESS_SC_ACCOUNT.equalsIgnoreCase(businessCommitteeTypes)  && (providerAccount.Committee__pc == ESA_cls_constants.EDRD_PERSONACCOUNT_SC || providerAccount.Committee__pc == ESA_cls_constants.EDRD_PERSONACCOUNT_ACSC)){
                        if(providerAccount.Committee_Name__pc.Contains(sCToRemove)){
                            Set<String> committeeSet = new Set<String>(providerAccount.Committee_Name__pc.Split(';'));
                            committeeSet.remove(sCToRemove);
                            
                            if(!committeeSet.isEmpty()){
                                providerAccount.Committee__pc = (providerAccount.Committee__pc == ESA_cls_constants.EDRD_PERSONACCOUNT_SC) ? ESA_cls_constants.EDRD_PERSONACCOUNT_SC : ESA_cls_constants.EDRD_PERSONACCOUNT_ACSC;
                                providerAccount.Committee_Name__pc = String.join(committeeSet, ';');
                                providerIdVsRecToUpdate.put(providerAccount.Id, new Account(Id = providerAccount.Id, Committee__pc = providerAccount.Committee__pc, Committee_Name__pc = providerAccount.Committee_Name__pc));
                            } else {
                                providerAccount.Committee__pc = (providerAccount.Committee__pc == ESA_cls_constants.EDRD_PERSONACCOUNT_ACSC) ? ESA_cls_constants.EDRD_PERSONACCOUNT_AC : NULL ;
                                providerAccount.Committee_Name__pc = NULL;
                                providerIdVsRecToUpdate.put(providerAccount.Id, new Account(Id = providerAccount.Id, Committee__pc = providerAccount.Committee__pc, Committee_Name__pc = NULL));
                            }
                        }
                    }else if(ESA_cls_constants.EDRD_BUSINESS_AC_ACCOUNT.equalsIgnoreCase(businessCommitteeTypes)  && (providerAccount.Committee__pc == ESA_cls_constants.EDRD_PERSONACCOUNT_AC || providerAccount.Committee__pc == ESA_cls_constants.EDRD_PERSONACCOUNT_ACSC)){
                        providerAccount.Committee__pc = (providerAccount.Committee__pc == ESA_cls_constants.EDRD_PERSONACCOUNT_ACSC) ? ESA_cls_constants.EDRD_PERSONACCOUNT_SC : NULL;
                        providerIdVsRecToUpdate.put(providerAccount.Id, new Account(Id = providerAccount.Id, Committee__pc = providerAccount.Committee__pc, Committee_Name__pc = providerAccount.Committee_Name__pc));
                    }                    
                }
                if (!providerIdVsRecToUpdate.isEmpty()) {
                    Database.update(providerIdVsRecToUpdate.values(), true);
                }
            } catch (DmlException e) {
                System.debug('Error Removing Committee from Provider/Reviewer record: ' + e.getMessage());
            }
    }
    
/**
* @author: Deepak
* @date: 06 Jun 2025
* @description: The purpose of this future method is to Create a EDRD Public Group for provider whenever an ACR is created with Allied staff role.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/
    @future
    public static void handleAlliedStaffACRPGInsert(Set<Id> acrIds){
        Set<Id> providerAccountIds = new Set<Id>();
        Set<Id> alliedStaffContactIds = new Set<Id>();
        List<Group> groupsToInsert = new List<Group>();
        Map<Id, Set<Id>> contactIdVsAccountIdSet = new Map<Id, Set<Id>>();
        Map<String, Group> existingGroupsByName = new Map<String, Group>();
        Map<Id, Id> providerToGroupIdMap = new Map<Id, Id>();
        Set<String> expectedGroupNames = new Set<String>();
        Map<Id, Account> providerAccounts = new Map<Id, Account>();
        Map<Id, Id> groupIdVsContactId = new Map<Id, Id>(); 
        
        List<AccountContactRelation> acrList = [SELECT Id, AccountId, ContactId, Roles FROM AccountContactRelation WHERE Id IN: acrIds];
        
        for (AccountContactRelation aCR : acrList) {
            if (aCR.Roles.containsIgnoreCase(ESA_cls_constants.EDRD_ALLIED_STAFF)) {
                providerAccountIds.add(aCR.AccountId);
                alliedStaffContactIds.add(aCR.contactId);
                if(!contactIdVsAccountIdSet.ContainsKey(aCR.contactId)){
                    contactIdVsAccountIdSet.put(aCR.contactId, new Set<Id>());
                }
                contactIdVsAccountIdSet.get(acr.ContactId).add(aCR.AccountId);
            }
        }
        
        if (!providerAccountIds.isEmpty()) {
            providerAccounts = new Map<Id, Account>([SELECT Id, EDRD_Provider_Public_GroupId__pc
                FROM Account WHERE Id IN :providerAccountIds AND Provider_Type__pc = 'Physician']);
        }
        
        for (Account acc : providerAccounts.values()) {
            if (String.isNotBlank(acc.Id)) {
                String groupName = generateGroupName(acc.Id);
                expectedGroupNames.add(groupName);
            }
        }
        
        if (!expectedGroupNames.isEmpty()) {
            for (Group groupObj : [SELECT Id, Name FROM Group WHERE Name IN :expectedGroupNames AND Type = 'Regular']) {
                existingGroupsByName.put(groupObj.Name, groupObj);
            }
        }
        
        for (Account acc : providerAccounts.values()) {
            String groupName = generateGroupName(acc.Id);
            if (String.isNotBlank(acc.EDRD_Provider_Public_GroupId__pc) && String.isNotBlank(acc.Id)) {              
                if (existingGroupsByName.containsKey(groupName)) {
                    providerToGroupIdMap.put(acc.Id, existingGroupsByName.get(groupName).Id);
                } 
            }else {
                Group newGroup = new Group(Name = groupName, DeveloperName = groupName, Type = 'Regular');
                groupsToInsert.add(newGroup);
                providerToGroupIdMap.put(acc.Id, null);
            }
        }
        
        if(!groupsToInsert.isEmpty()){
            new Elevated().insertGroup(groupsToInsert);
            
            for (Group groupObj : groupsToInsert) {
                existingGroupsByName.put(groupObj.Name, groupObj);
            }
            
            for (Account acc : providerAccounts.values()) {
                String groupName = generateGroupName(acc.Id);
                if (existingGroupsByName.containsKey(groupName)) {
                    providerToGroupIdMap.put(acc.Id, existingGroupsByName.get(groupName).Id);
                }
            }
        }
        
        List<Account> providersToUpdate = new List<Account>();
        for(Id accId : providerToGroupIdMap.keySet()){
            Id groupId = providerToGroupIdMap.get(accId);
            if (groupId != null) {
                providersToUpdate.add(new Account(Id = accId, EDRD_Provider_Public_GroupId__pc = groupId));
            }
        }
        
        if(!providersToUpdate.isEmpty()){
            update providersToUpdate;
        }
        
        if(!contactIdVsAccountIdSet.isEmpty()){
            addProvisionedUsersToProviderGroups(contactIdVsAccountIdSet);
        }        
    }
    
/**
* @author: Deepak
* @date: 06 Jun 2025
* @description: The purpose of this method is to generate EDRD Public Group name for provider.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/    
    private static String generateGroupName(Id accountId) {
        String name = 'EDRD_PROVIDER_PG_' + String.valueOf(accountId);
        return (name.length() > 40) ? name.substring(0, 40) : name;
    }
    
/**
* @author: Deepak
* @date: 25 Jun 2025
* @description: The purpose of this method is to Insert Users into Provider Public Group.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/    
    public static void addProvisionedUsersToProviderGroups(Map<Id, Set<Id>> contactIdVsAccountIdSet){
        Map<Id, Id> accountIdVsGroupId = new Map<Id, Id>();
        Map<Id, Id> providerIdVsGroupId = new Map<Id, Id>();
        Map<Id, Id> contactIdVsUserId = new Map<Id, Id>();
        Map<Id, Id> accountIdVsUserId = new Map<Id, Id>();
        Set<Id> accountIdSet = new Set<Id>();
        Set<Id> groupsetId = new Set<Id>();
        Set<String> existingPairs = new Set<String>();
        Map<Id, Set<Id>> userIdVsGroupSetId = new Map<Id, Set<Id>>();
        List<GroupMember> groupMembersToInsert = new List<GroupMember>();
        
        for(Set<Id> accIdSet: contactIdVsAccountIdSet.Values()){
            accountIdSet.addAll(accIdSet);
        }
        
        List<Account> providerList = [SELECT Id, EDRD_Provider_Public_GroupId__pc FROM Account WHERE Id IN: accountIdSet];
        
        for(Account accObj: providerList){
            providerIdVsGroupId.put(accObj.Id, accObj.EDRD_Provider_Public_GroupId__pc);
        }
        
        List<User> userList = [SELECT Id, ContactId, Contact.AccountId, Contact.Account.EDRD_Provider_Public_GroupId__pc FROM User 
                               WHERE IsActive = true AND (Contact.AccountId IN: accountIdSet OR ContactId IN: contactIdVsAccountIdSet.KeySet())];
        
        for(User userObj: userList){
            if(userObj.Contact.Account.EDRD_Provider_Public_GroupId__pc != NULL){
                accountIdVsUserId.put(userObj.Contact.AccountId, userObj.Id);
            }else{
                contactIdVsUserId.put(userObj.ContactId, userObj.Id);
            }
        }
        
        for(Id conId: contactIdVsAccountIdSet.KeySet()){
            for(Id accId: contactIdVsAccountIdSet.get(conId)){
                if(contactIdVsUserId.ContainsKey(conId) && !userIdVsGroupSetId.ContainsKey(contactIdVsUserId.get(conId))){
                    userIdVsGroupSetId.put(contactIdVsUserId.get(conId), new Set<Id>());
                }
                if(accountIdVsGroupId.ContainsKey(accId) && !userIdVsGroupSetId.ContainsKey(accountIdVsGroupId.get(accId))){
                    userIdVsGroupSetId.put(accountIdVsGroupId.get(accId), new Set<Id>());
                }
                if(contactIdVsUserId.ContainsKey(conId) && providerIdVsGroupId.ContainsKey(accId)){
                    userIdVsGroupSetId.get(contactIdVsUserId.get(conId)).add(providerIdVsGroupId.get(accId));
                }
                if(accountIdVsGroupId.ContainsKey(accId) && providerIdVsGroupId.ContainsKey(accId)){
                    userIdVsGroupSetId.get(accountIdVsGroupId.get(accId)).add(providerIdVsGroupId.get(accId));
                }
            }            
        }
        
        if(userIdVsGroupSetId.isEmpty()){
            return;
        }
        
        for(Set<Id> groupIdSet: userIdVsGroupSetId.Values()){
            groupsetId.addAll(groupIdSet);
        }
        
        for (GroupMember gm: [SELECT Id, GroupId, UserOrGroupId FROM GroupMember 
                              WHERE GroupId IN: groupsetId OR UserOrGroupId IN: userIdVsGroupSetId.KeySet()]) {
            existingPairs.add(gm.GroupId + '_' + gm.UserOrGroupId);
        }
        
        for (Id usrId : userIdVsGroupSetId.keySet()) {
            for(Id groupId: userIdVsGroupSetId.get(usrId)){
                String key = groupId + '_' + usrId;
                
                if (!existingPairs.contains(key)) {
                    groupMembersToInsert.add(new GroupMember(GroupId = groupId, UserOrGroupId = usrId));
                }
            }
        }
        
        if (!groupMembersToInsert.isEmpty()) {
            System.enqueueJob(new EDRD_cls_groupMemberQueable(groupMembersToInsert));
        }
    }
    
/**
* @author: Deepak
* @date: 29 Jun 2025
* @description: The purpose of this method is to Collect Contact Account & Contact from ACR to perform GM delete.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/  
    public static void removeAlliedStaffFromPG(List<AccountContactRelation> aCRList) {
        Map<Id, Set<Id>> accountIdVsContactSetId = new Map<Id, Set<Id>>();
        
        for (AccountContactRelation aCRObj : aCRList) {
            if (!String.isEmpty(aCRObj.Roles) && aCRObj.Roles.containsIgnoreCase(ESA_cls_constants.EDRD_ALLIED_STAFF) &&
                aCRObj.AccountId != null && aCRObj.ContactId != null) {
                    if(!accountIdVsContactSetId.ContainsKey(aCRObj.accountId)){
                        accountIdVsContactSetId.put(aCRObj.AccountId, new Set<Id>());
                    }
                    accountIdVsContactSetId.get(aCRObj.AccountId).add(aCRObj.ContactId);
                }
        }
        
        if (!accountIdVsContactSetId.isEmpty()) {
            removeAlliedStaffFromProviderGroup(accountIdVsContactSetId);
        }
    }

/**
* @author: Deepak
* @date: 29 Jun 2025
* @description: The purpose of this method is to sent Ids to deleted Contact Users from Provider Public Group in async.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/     
    public static void removeAlliedStaffFromProviderGroup(Map<Id, Set<Id>> accountIdVsContactSetId){        
        Set<Id> groupMembersIdSetToDelete = new Set<Id>();
        Set<Id> contactIdSet = new Set<Id>();
        Map<Id, Id> accountIdVsGroupId = new Map<Id, Id>();
        Map<Id, Id> contactIdVsUserId = new Map<Id, Id>();
        Map<Id, Id> userIdVsGroupId = new Map<Id, Id>();
        
        for(Set<Id> conId: accountIdVsContactSetId.values()){
            contactIdSet.addAll(conId);
        }
        
        for (Account acc : [SELECT Id, EDRD_Provider_Public_GroupId__pc FROM Account WHERE Id IN: accountIdVsContactSetId.KeySet() AND EDRD_Provider_Public_GroupId__pc != null]) {
            accountIdVsGroupId.put(acc.Id, acc.EDRD_Provider_Public_GroupId__pc);
        }
        
        if (accountIdVsGroupId.isEmpty()) {
            return;
        }
        
        for (User usr : [SELECT Id, ContactId FROM User WHERE IsActive = true AND ContactId IN: contactIdSet]) {
            if (usr.ContactId != null) {
                contactIdVsUserId.put(usr.ContactId, usr.Id);
            }
        }
        
        if (contactIdVsUserId.isEmpty()) {
            return;
        }
        
        for (Id accId : accountIdVsContactSetId.keySet()) {
            for(Id contactId: accountIdVsContactSetId.get(accId)){
                userIdVsGroupId.put(contactIdVsUserId.get(contactId), accountIdVsGroupId.get(accId));
            }
            
            List <GroupMember> groupMemberList = [SELECT Id, GroupId, UserOrGroupId FROM GroupMember
                                                  WHERE GroupId IN: userIdVsGroupId.values() OR UserOrGroupId IN: userIdVsGroupId.KeySet()];
            
            for(GroupMember gMObj: groupMemberList){
                if(userIdVsGroupId.get(gMObj.UserOrGroupId) == gMObj.GroupId){
                    groupMembersIdSetToDelete.add(gMObj.Id);
                }               
            }
            
            
            if (!groupMembersIdSetToDelete.isEmpty()) {
                deleteGMAsync(groupMembersIdSetToDelete);
            }
        } 
    }

/**
* @author: Deepak
* @date: 29 Jun 2025
* @description: The purpose of this future method is to deleted Contact Users from Provider Public Group in Elevated access.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/    
    @future
    public static void deleteGMAsync(Set<Id> groupMembersIdSetToDelete){            
        List<GroupMember> groupMembersToDelete = new List<GroupMember>();
        
        groupMembersToDelete = [SELECT Id FROM GroupMember WHERE Id IN: groupMembersIdSetToDelete];
        
        if (!groupMembersToDelete.isEmpty()) {
            new Elevated().deleteGroupMember(groupMembersToDelete);
        }
    }
    
/**
* @author: Deepak
* @date: 29 June 2025
* @description: The purpose of this Class/Methods is to perform DML in without Sharing Context.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/     
    public without sharing class Elevated{
        public void insertGroup(List<Group> groupsToInsert){
            Database.Insert(groupsToInsert, true);
        }
        public void deleteGroupMember(List<GroupMember> groupMembersToDelete){
            Database.Delete(groupMembersToDelete, true);
        }
    }
}