/**********************************************************************************************
* @Author:      Accenture 
* @Date:        14 Dec 2023
* @Description: The purpose of this Trigger is to trigger on particular events
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]
				19 Dec -  EDRD-282          -  Accenture   -  populate MR ExpenditureEstimate
                09 Jan -  EDRD-139          -  Accenture   -  Calculate Drug Forecast with Respect to Case
                09 Jan -  EDRD-139          -  Accenture   -  update Forecast On Case
                04-Oct -  EDRD-679          -  Accenture   -  Adding Changes Related to Formulation Type-Bottle
***********************************************************************************************/
trigger MedicationRequestTrigger on MedicationRequest (before insert, before Update, after Update) {
    
    List<MedicationRequest> MRListValidate = new List<MedicationRequest>();
    
    if(trigger.isBefore){
        if(trigger.isInsert || trigger.isUpdate){
            for(MedicationRequest MRObj : trigger.new){
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
                                                                       trigger.newMap.get(MRObj.Id).Medication_Formulation__c != trigger.oldMap.get(MRObj.Id).Medication_Formulation__c ||
                                                                       trigger.newMap.get(MRObj.Id).Strength__c != trigger.oldMap.get(MRObj.Id).Strength__c );
                Boolean iscalculateInputNotBlank = (MRObj.Dosage__c != NULL && MRObj.Dosage_Units__c != NULL && MRObj.Requested_Frequency__c != NULL && 
                                                    MRObj.Requested_Frequency_Unit__c != NULL && MRObj.Requested_Funding_Duration__c != NULL && MRObj.Medication_Formulation__c != NULL &&
                                                    MRObj.Requested_Funding_Duration_Unit__c != NULL && MRObj.List_Price_per_Unit__c != NULL && MRObj.Strength__c != NULL);
                Boolean iscalculateInputNotBlankForIndefinite = (MRObj.Dosage__c != NULL && MRObj.Dosage_Units__c != NULL && MRObj.Requested_Frequency__c != NULL && MRObj.Medication_Formulation__c != NULL &&
                                                    MRObj.Requested_Frequency_Unit__c != NULL && MRObj.EDRD_Indefinite_Funding__c && MRObj.List_Price_per_Unit__c != NULL && MRObj.Strength__c != NULL);
                Boolean isCalculateInputChangedForIndefinite = trigger.isUpdate && (trigger.newMap.get(MRObj.Id).Dosage__c != trigger.oldMap.get(MRObj.Id).Dosage__c ||
                                                                       trigger.newMap.get(MRObj.Id).Dosage_Units__c != trigger.oldMap.get(MRObj.Id).Dosage_Units__c ||
                                                                       trigger.newMap.get(MRObj.Id).Requested_Frequency__c != trigger.oldMap.get(MRObj.Id).Requested_Frequency__c ||
                                                                       trigger.newMap.get(MRObj.Id).Requested_Frequency_Unit__c != trigger.oldMap.get(MRObj.Id).Requested_Frequency_Unit__c ||
                                                                       trigger.newMap.get(MRObj.Id).EDRD_Indefinite_Funding__c != trigger.oldMap.get(MRObj.Id).EDRD_Indefinite_Funding__c ||
                                                                       trigger.newMap.get(MRObj.Id).List_Price_per_Unit__c != trigger.oldMap.get(MRObj.Id).List_Price_per_Unit__c ||
                                                                       trigger.newMap.get(MRObj.Id).Medication_Formulation__c != trigger.oldMap.get(MRObj.Id).Medication_Formulation__c ||
                                                                       trigger.newMap.get(MRObj.Id).Strength__c != trigger.oldMap.get(MRObj.Id).Strength__c );
                if((trigger.isInsert || isCalculateInputChangedForIndefinite) && MRObj.EDRD_Indefinite_Funding__c && iscalculateInputNotBlankForIndefinite){
                    MRObj.Expenditure_Estimate__c = EDRD_cls_DrugCostCalculator.populateMRExpenditureEstimate(MRObj.Dosage__c, MRObj.Dosage_Units__c, MRObj.Requested_Frequency__c, 
                                                                                                              MRObj.Requested_Frequency_Unit__c, 1,
                                                                                                              'Years', MRObj.List_Price_per_Unit__c, MRObj.Strength__c, MRObj.Medication_Formulation__c);
                }else if((trigger.isInsert || isCalculateInputChanged) && iscalculateInputNotBlank){
                    MRObj.Expenditure_Estimate__c = EDRD_cls_DrugCostCalculator.populateMRExpenditureEstimate(MRObj.Dosage__c, MRObj.Dosage_Units__c, MRObj.Requested_Frequency__c, 
                                                                                                              MRObj.Requested_Frequency_Unit__c, MRObj.Requested_Funding_Duration__c,
                                                                                                              MRObj.Requested_Funding_Duration_Unit__c, MRObj.List_Price_per_Unit__c, MRObj.Strength__c, MRObj.Medication_Formulation__c);
                }else if(!iscalculateInputNotBlank){
                    MRObj.Expenditure_Estimate__c = NULL;
                }
            }
            if(!MRListValidate.isEmpty()){
               medicationRequestTriggerHandler.validateMedicationRequest(MRListValidate);
            }
        }
    }
    if(trigger.isAfter && trigger.isUpdate){
        Set<Id> caseIdSet = new Set<Id>();
        for(MedicationRequest MRObj: trigger.new){
            Boolean isChangedMedicationInformation = (trigger.newMap.get(MRObj.Id).Medication_Information__c != trigger.oldMap.get(MRObj.Id).Medication_Information__c);
            if(isChangedMedicationInformation){
                caseIdSet.add(MRObj.Case__c);
            }
        }
        if(!caseIdSet.isEmpty()){
            medicationRequestTriggerHandler.updateForecastOnCase(caseIdSet);
        }
    }
    if (Trigger.isAfter && Trigger.isInsert) {
        EDRDMedicationReqwithACRHandler.shareMedicationRequestsWithPatientAccount(Trigger.new);
    }
}