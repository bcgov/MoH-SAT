/**********************************************************************************************
* @Author:      Deepak 
* @Date:        09 Mar 2023
* @Description: The purpose of this Trigger is to trigger on particular events
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
***********************************************************************************************/
trigger ESA_tgr_accountTrigger on account (after insert, after update) {
    
    if (trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
        
        if(trigger.isInsert){
             List<Account> newAccountList = new List<Account>();
             List<String> saRecordTypeList = new List<String>{'Business_Account', 'DEC', 'Patient', 'Person', 'Provider'};
                for (Account acc : Trigger.new) {
                    if(saRecordTypeList.contains(acc.Record_Type_Name__c)){
                        newAccountList.add(acc);
                    }
                }
            if(newAccountList.size()>0){
                ESA_cls_accountTriggerHandler.populateSpecialty(newAccountList, NULL, NULL);
            }           
        }
        if(trigger.isUpdate){
            List<Account> newAccountList = new List<Account>();
            Map<Id,Account> newAccountMap = new Map<Id,Account>();
            Map<Id,Account> oldAccountMap = new Map<Id,Account>();
            List<String> saRecordTypeList = new List<String>{'Business_Account', 'DEC', 'Patient', 'Person', 'Provider'};
                for (Account acc : Trigger.new) {
                    if(saRecordTypeList.contains(acc.Record_Type_Name__c)){
                        newAccountList.add(acc);
                        newAccountMap.put(acc.Id,trigger.newMap.get(acc.Id));
                        oldAccountMap.put(acc.Id,trigger.oldMap.get(acc.Id));
                    }
                }
            if(newAccountList.size()>0){
                ESA_cls_accountTriggerHandler.populateSpecialty(newAccountList , newAccountMap, oldAccountMap);
            }
        }
    }
}