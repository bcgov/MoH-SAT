/**********************************************************************************************
* @Author:      Accenture 
* @Date:        16 Dec 2023
* @Description: The purpose of this Trigger is to trigger on particular events
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]
***********************************************************************************************/
trigger MedicationTrigger on Medication (after Update) {
    
    if(trigger.isAfter && trigger.isUpdate){
        MedicationTriggerHandler.changeCaseStatus(trigger.oldMap, trigger.newMap);
    }
}