/**********************************************************************************************
* @Author:      Deepak 
* @Date:        21 Aug 2024
* @Description: The purpose of this class is to create methods which can be used by different trigger event
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
                21 Aug -  EDRD-             -  Accenture   -  Added Patient Share/delete With Provider User
***********************************************************************************************/
public with sharing class AccountContactRelationTriggerHandler {
/**
* @author: Deepak
* @date: 21 Aug 2024
* @description: The purpose of this method is to share patient records with provider on ACR insert.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/     
    public static void createPatientShare(List<AccountContactRelation> aCRList){
        Map<Id, Id> providerIdVsPatientId = new Map<Id, Id>();
        Map<Id, User> providerIdVsRec = new Map<Id, User>();
        Map<Id, Set<Id>> providerIdVsUserIdSet = new Map<Id, Set<Id>>();
        List<AccountShare> accShareListToInsert = new List<AccountShare>();
        
        for(AccountContactRelation aCRObj : aCRList){
            if(aCRObj.Is_Person_Account__c && !String.IsEmpty(aCRObj.Roles) && aCRObj.Roles.containsIgnoreCase('Physician')){
                providerIdVsPatientId.put(aCrObj.AccountId , acrObj.ContactAccountId__c);
            }
        }
        
        providerIdVsRec = new Map<Id, User>([SELECT Id, Contact.AccountId From User 
                                             WHERE contact.AccountId IN: providerIdVsPatientId.keySet()]);
        
        for(User userObj : providerIdVsRec.values()){
            if(!providerIdVsUserIdSet.containsKey(userObj.Contact.AccountId)){
                providerIdVsUserIdSet.put(userObj.Contact.AccountId, new Set<Id>()); 
            }
            
            providerIdVsUserIdSet.get(userObj.Contact.AccountId).add(userObj.Id);
        }
        
        for(Id providerId: providerIdVsPatientId.keySet()){
            for(Id userId: providerIdVsUserIdSet.get(providerId)){
                accShareListToInsert.add(new AccountShare(AccountId = providerIdVsPatientId.get(providerId),
                                                          AccountAccessLevel = 'Read', UserOrGroupId = UserId,
                                                          OpportunityAccessLevel = 'None'));
            }
        }
        
        if(!accShareListToInsert.isEmpty()){
            database.insert(accShareListToInsert, true);
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
        
        for(AccountContactRelation aCRObj : aCRList){
            if(aCRObj.Is_Person_Account__c && !String.IsEmpty(aCRObj.Roles) && aCRObj.Roles.containsIgnoreCase('Physician'))
                providerIdVsPatientId.put(aCRObj.AccountId , aCRObj.ContactAccountId__c);
        }
        
        if(!providerIdVsPatientId.isEmpty()){
            List<AccountShare> accShareList = [SELECT Id FROM AccountShare WHERE AccountId IN :providerIdVsPatientId.values() 
                                               AND UserOrGroupId IN 
                                               (SELECT Id FROM User WHERE Contact.AccountId IN :providerIdVsPatientId.keySet())];
            
            if(!accShareList.isEmpty()){
                Database.delete(accShareList, true);
            }
        }
    }  
}