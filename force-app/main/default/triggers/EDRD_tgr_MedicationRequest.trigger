/**********************************************************************************************
* @Author:      Deepak 
* @Date:        14 Dec 2023
* @Description: The purpose of this Trigger is to trigger on particular events
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]
***********************************************************************************************/
trigger EDRD_tgr_MedicationRequest on MedicationRequest (before insert) {
    
    List<MedicationRequest> MRListValidate = new List<MedicationRequest>();
    
    if(trigger.isBefore){
        if(trigger.isInsert){
            for(MedicationRequest MRObj : trigger.new){
                if(trigger.isInsert && MRObj.Case__c != NULL){
                       MRListValidate.add(MRObj);
                   }
            }
            if(!MRListValidate.isEmpty()){
               EDRD_cls_medicationRequestHandler.validateMedicationRequest(MRListValidate);
            }
        }
    }
    
}