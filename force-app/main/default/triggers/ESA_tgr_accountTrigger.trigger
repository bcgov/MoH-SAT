/**********************************************************************************************
* @Author:      Deepak 
* @Date:        09 Mar 2023
* @Description: The purpose of this Trigger is to trigger on particular events
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
                11 Nov -  EDRD-82           -  Accenture   -  Added Close Case method on Account Inactive
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
            ESA_cls_accountTriggerHandler.populateSpecialty(trigger.new, trigger.newMap, trigger.oldMap);
            ESA_cls_accountTriggerHandler.closeCaseOnAccDeceased(trigger.new, trigger.newMap, trigger.oldMap);
        }
    }
}