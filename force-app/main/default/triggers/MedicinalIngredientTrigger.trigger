/**********************************************************************************************
* @Author:      Accenture 
* @Date:        07 Jan 2024
* @Description: The purpose of this Trigger is to trigger on particular events
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]
***********************************************************************************************/
trigger MedicinalIngredientTrigger on MedicinalIngredient (after update) {
    
    Set<Id> MedicinalIDSet = new Set<Id>();
    if(trigger.isAfter && trigger.isUpdate){
        for(MedicinalIngredient MIObj: trigger.new){
            if(trigger.newMap.get(MIObj.Id).Unit_Price__c != trigger.oldMap.get(MIObj.Id).Unit_Price__c){
                MedicinalIDSet.add(MIObj.Id);
            }
        }
        if(!MedicinalIDSet.isEmpty() && medicinalIngredientTriggerHandler.updateOpenMedicationRequest_RunOnce){
            medicinalIngredientTriggerHandler.updateOpenMedicationRequest(MedicinalIDSet);
            medicinalIngredientTriggerHandler.updateOpenMedicationRequest_RunOnce = false;
        }
    }
    
}