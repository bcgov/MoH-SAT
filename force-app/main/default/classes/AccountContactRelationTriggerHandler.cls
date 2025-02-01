/**********************************************************************************************
* @Author:      Accenture 
* @Date:        21 Aug 2024
* @Description: The purpose of this class is to create methods which can be used by different trigger event
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
                21 Aug -  EDRD-911          -  Accenture   -  Added Patient Share/delete With Provider User
***********************************************************************************************/
public with sharing class AccountContactRelationTriggerHandler {
/**
* @author: Deepak
* @date: 21 Aug 2024
* @description: The purpose of this method is to share patient records with provider on ACR insert.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
                     20Sept -  EDRD-911          -  Deepak      -  Adding NULL Check & updated asper user trigger
*/     
    public static void createPatientShare(List<AccountContactRelation> aCRList){
        Map<Id, Set<Id>> providerIdVsPatientIdSet1 = new Map<Id, Set<Id>>();
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
}