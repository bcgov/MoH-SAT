/**********************************************************************************************
* @Author:      Deepak 
* @Date:        07 Jan 2024
* @Description: The purpose of this Trigger is to trigger on particular events
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]
***********************************************************************************************/
trigger EDRD_tgr_MedicinalIngredient on MedicinalIngredient (after update) {
    
    Set<Id> MedicinalIDSet = new Set<Id>();
    if(trigger.isAfter && trigger.isUpdate){
        for(MedicinalIngredient MIObj: trigger.new){
            if(trigger.newMap.get(MIObj.Id).Unit_Price__c != trigger.oldMap.get(MIObj.Id).Unit_Price__c){
                MedicinalIDSet.add(MIObj.Id);
            }
        }
        if(!MedicinalIDSet.isEmpty() && EDRD_cls_medicinalIngredientHandler.updateOpenMedicationRequest_RunOnce){
            EDRD_cls_medicinalIngredientHandler.updateOpenMedicationRequest(MedicinalIDSet);
            EDRD_cls_medicinalIngredientHandler.updateOpenMedicationRequest_RunOnce = false;
        }
    }
    
}