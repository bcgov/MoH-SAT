/**********************************************************************************************
* @Author:      Deepak 
* @Date:        09 Mar 2023
* @Description: The purpose of this class is to create methods which can be used by different trigger event
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
***********************************************************************************************/
public with sharing class ESA_cls_accountTriggerHandler {

/**
* @author: Deepak
* @date: 09 Mar 2023
* @description: The purpose of this method is to populate the specialty.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/ 
    public static void populateSpecialty(List<Account> newAccountList, Map<id,Account> oldAccountMap, Map<id,Account> newAccountMap) {
        set<id> accountIdSet = new set<id>();
        List<Contact> conListToUpdate = new List<Contact>();
        
        for (Account accObj:newAccountList){
            
            Boolean isSpecialtyChanged = trigger.isUpdate && oldAccountMap.get(accObj.id).Provider_Specialty__pc != newAccountMap.get(accObj.id).Provider_Specialty__pc;
            if (trigger.isInsert || isSpecialtyChanged){
               accountIdSet.add(accObj.id);
            } 
        } 
        List<Contact> conList = [Select Id, account.Provider_Specialty__pc from Contact Where accountID =: accountIdSet];
        for(Contact conObj: conList){
            conObj.ESA_Provider_Specialty__c = conObj.account.Provider_Specialty__pc;
            conListToUpdate.add(new Contact(id = conObj.id, ESA_Provider_Specialty__c = conObj.ESA_Provider_Specialty__c));
        }
        if(!conListToUpdate.isEmpty()){
          Update conListToUpdate;
        } 
    }
}