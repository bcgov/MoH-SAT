/**********************************************************************************************
* @Author:      Vasanthi 
* @Date:        09 Sep 2023
* @Description: The purpose of this Trigger is to validate the data before insert and clone related open cases after insert
***********************************************************************************************/
trigger ESA_tgr_ExternalCommitteeTrigger on External_Committee__c (before insert,after insert) {
    if (Trigger.isBefore && Trigger.isInsert){
        ESA_cls_ExternalCommitteeTriggerHandler.validateBeforeClone(Trigger.new);
    }
    if (Trigger.isAfter && Trigger.isInsert){ 
        if(ESA_cls_ExternalCommitteeTriggerHandler.cloneOpenCases_runsOne){
            ESA_cls_ExternalCommitteeTriggerHandler.cloneOpenCases(Trigger.new);   
        }
    }  
    
}