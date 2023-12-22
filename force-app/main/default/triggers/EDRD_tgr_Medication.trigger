/**********************************************************************************************
* @Author:      Deepak 
* @Date:        16 Dec 2023
* @Description: The purpose of this Trigger is to trigger on particular events
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]
***********************************************************************************************/
trigger EDRD_tgr_Medication on Medication (after Update) {
    
    if(trigger.isAfter && trigger.isUpdate){
        EDRD_cls_MedicationHandler.changeCaseStatus(trigger.oldMap, trigger.newMap);
    }
}