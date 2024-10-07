/**********************************************************************************************
* @Author:      Accenture 
* @Date:        21 Aug 2024
* @Description: The purpose of this Trigger is to trigger on particular events
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]
***********************************************************************************************/
trigger AccountContactRelationTrigger on AccountContactRelation (after insert, after update, after delete) {
    
    if(trigger.isInsert && trigger.isAfter){
        AccountContactRelationTriggerHandler.createPatientShare(trigger.new);
    }
    
    if(trigger.isUpdate && trigger.isAfter){
        AccountContactRelationTriggerHandler.updatePatientShare(trigger.oldMap, trigger.newMap);
    }
    
    if(trigger.isDelete && trigger.isAfter){
        AccountContactRelationTriggerHandler.removePatientShare(trigger.old);
    }
    
}