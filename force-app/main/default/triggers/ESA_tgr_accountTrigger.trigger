/**********************************************************************************************
* @Author:      Deepak 
* @Date:        09 Mar 2023
* @Description: The purpose of this Trigger is to trigger on particular events
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
***********************************************************************************************/
trigger ESA_tgr_accountTrigger on account (after insert, after update) {
    
    if (trigger.isAfter){
        if (trigger.isInsert || trigger.isUpdate){
            if(trigger.isInsert){
                ESA_cls_accountTriggerHandler.populateSpecialty(trigger.new, NULL, NULL);
            }
            if(trigger.isUpdate){
                ESA_cls_accountTriggerHandler.populateSpecialty(trigger.new, trigger.newMap, trigger.oldMap);
            }
        }
    }
}