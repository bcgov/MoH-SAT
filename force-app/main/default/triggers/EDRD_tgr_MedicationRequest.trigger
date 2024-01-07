/**********************************************************************************************
* @Author:      Deepak 
* @Date:        14 Dec 2023
* @Description: The purpose of this Trigger is to trigger on particular events
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]
***********************************************************************************************/
trigger EDRD_tgr_MedicationRequest on MedicationRequest (before insert, before Update) {
    
    List<MedicationRequest> MRListValidate = new List<MedicationRequest>();
    
    if(trigger.isBefore){
        if(trigger.isInsert || trigger.isUpdate){
            for(MedicationRequest MRObj : trigger.new){
                if(MRObj.Dosage_Units_Name__c != MRObj.Strength_Units__c){
                    MRObj.addError(label.EDRD_label_DosageAndStrengthUnits);
                }
                if(trigger.isInsert && MRObj.Case__c != NULL){
                       MRListValidate.add(MRObj);
                   }
                Boolean isCalculateInputChanged = trigger.isUpdate && (trigger.newMap.get(MRObj.Id).Dosage__c != trigger.oldMap.get(MRObj.Id).Dosage__c ||
                                                                       trigger.newMap.get(MRObj.Id).Dosage_Units__c != trigger.oldMap.get(MRObj.Id).Dosage_Units__c ||
                                                                       trigger.newMap.get(MRObj.Id).Requested_Frequency__c != trigger.oldMap.get(MRObj.Id).Requested_Frequency__c ||
                                                                       trigger.newMap.get(MRObj.Id).Requested_Frequency_Unit__c != trigger.oldMap.get(MRObj.Id).Requested_Frequency_Unit__c ||
                                                                       trigger.newMap.get(MRObj.Id).Requested_Funding_Duration__c != trigger.oldMap.get(MRObj.Id).Requested_Funding_Duration__c ||
                                                                       trigger.newMap.get(MRObj.Id).Requested_Funding_Duration_Unit__c != trigger.oldMap.get(MRObj.Id).Requested_Funding_Duration_Unit__c ||
                                                                       trigger.newMap.get(MRObj.Id).List_Price_per_Unit__c != trigger.oldMap.get(MRObj.Id).List_Price_per_Unit__c ||
                                                                       trigger.newMap.get(MRObj.Id).Strength__c != trigger.oldMap.get(MRObj.Id).Strength__c );
                Boolean iscalculateInputNotBlank = (MRObj.Dosage__c != NULL && MRObj.Dosage_Units__c != NULL && MRObj.Requested_Frequency__c != NULL && 
                                                    MRObj.Requested_Frequency_Unit__c != NULL && MRObj.Requested_Funding_Duration__c != NULL &&
                                                    MRObj.Requested_Funding_Duration_Unit__c != NULL && MRObj.List_Price_per_Unit__c != NULL && MRObj.Strength__c != NULL);
                if((trigger.isInsert || isCalculateInputChanged) && iscalculateInputNotBlank){
                    MRObj.Expenditure_Estimate__c = EDRD_cls_medicationRequestHandler.populateMRExpenditureEstimate(MRObj.Dosage__c, MRObj.Dosage_Units__c, MRObj.Requested_Frequency__c, 
                                                                                                                    MRObj.Requested_Frequency_Unit__c, MRObj.Requested_Funding_Duration__c,
                                                                                                                    MRObj.Requested_Funding_Duration_Unit__c, MRObj.List_Price_per_Unit__c, MRObj.Strength__c);
                }else if(!iscalculateInputNotBlank){
                    MRObj.Expenditure_Estimate__c = NULL;
                }
            }
            if(!MRListValidate.isEmpty()){
               EDRD_cls_medicationRequestHandler.validateMedicationRequest(MRListValidate);
            }
        }
    }
    
}