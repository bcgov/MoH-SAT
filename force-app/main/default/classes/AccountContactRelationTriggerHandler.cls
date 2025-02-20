/**********************************************************************************************
* @Author:      Accenture 
* @Date:        21 Aug 2024
* @Description: The purpose of this class is to create methods which can be used by different trigger event
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
                21 Aug -  EDRD-911          -  Accenture   -  Added Patient Share/delete With Provider User
                13 Dec -  EDRD-1150         -  Accenture   -  The purpose of this method is to update Committee based on ACR insert of EDRD_Committee & Provider OR Committee_Reviewer.
                20 Dec -  EDRD-1150         -  Accenture   -  The purpose of this method is to Remove Committee based on ACR delete of EDRD_Committee & Provider OR Committee_Reviewer.
***********************************************************************************************/
public with sharing class AccountContactRelationTriggerHandler {
/**
* @author: Deepak
* @date: 21 Aug 2024
* @description: The purpose of this method is to share patient records with provider on ACR insert.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
                     20Sept -  EDRD-911      -  Deepak      -  Adding NULL Check & updated asper user trigger
*/     
    public static void createPatientShare(List<AccountContactRelation> aCRList){
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
    }
    
/**
* @author: Deepak
* @date: 21 Aug 2024
* @description: The purpose of this method is to remove patient record shared with provider on ACR delete.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/  
    public static void removePatientShare(List<AccountContactRelation> aCRList){
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
    }  
    
/**
* @author: Deepak
* @date: 03 Sept 2024
* @description: The purpose of this method is to update patient record shared with provider on ACR update.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/  
    public static void updatePatientShare(Map<Id, AccountContactRelation> oldACRMap, Map<Id, AccountContactRelation> newACRMap){
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
    }
    
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
                        System.debug('oldProviderCommittee' + oldProviderCommittee);
                        
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
                //System.debug('::providerIdVsRecToUpdate'+  providerIdVsRecToUpdate);
                if (!providerIdVsRecToUpdate.isEmpty()) {
                    Database.update(providerIdVsRecToUpdate.values(), true);
                }
            } catch (DmlException e) {
                System.debug('Error Removing Committee from Provider/Reviewer record: ' + e.getMessage());
            }
    }
}