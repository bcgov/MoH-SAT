/**********************************************************************************************
* @Author:      Deepak 
* @Date:        07 Jan 2024
* @Description: The purpose of this class is to create methods which can be used by different trigger event
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]  
***********************************************************************************************/
public with sharing class medicinalIngredientTriggerHandler {
    
/**
* @author: Deepak
* @date: 07 Jan 2024
* @description: The purpose of this method is to update the open Medication Request.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
                     04-Oct     EDRD-679            Deepak         Adding Changes Related to Formulation Type-Bottle
*/ 
    public static Boolean updateOpenMedicationRequest_RunOnce = True;
    public static void updateOpenMedicationRequest(Set<Id> MedicinalIDSet){
        updateOpenMedicationRequest_RunOnce = false;
        List<MedicationRequest> MRList = [SELECT Id, Case__c, Dosage__c, Dosage_Units__c, Requested_Frequency__c, Requested_Frequency_Unit__c,
                                          Requested_Funding_Duration__c, Requested_Funding_Duration_Unit__c, List_Price_per_Unit__c,
                                          Strength__c, Case__r.EDRD_MOHApproved_Dosage__c, Case__r.EDRD_MOHApproved_Dosage_Unit__c, 
                                          Case__r.EDRD_MOHApproved_Frequency__c, Case__r.EDRD_MOHApproved_Frequency_Unit__c, 
                                          Case__r.EDRD_MOHApproved_Funding_Duration__c, Case__r.EDRD_MOHApproved_Funding_Duration_Unit__c, 
                                          Medication_Formulation__c FROM MedicationRequest WHERE Medication_Information__c IN: MedicinalIDSet 
                                          AND Status = 'Active' AND RecordType.DeveloperName = 'EDRD_Medication_Request' AND Case__c != NULL];
        
        List<MedicationRequest> MRListToUpdate = new List<MedicationRequest>();
        List<Case> caseListToUpdate = new List<Case>();
        if(MRList.isEmpty()){
            return;
        }else{
            for(MedicationRequest MRObj : MRList){
                Boolean isInputMRNotBlank = (MRObj.Dosage__c != NULL && MRObj.Dosage_Units__c != NULL && MRObj.Requested_Frequency__c != NULL && MRObj.Requested_Frequency_Unit__c != NULL &&
                                             MRObj.Requested_Funding_Duration__c != NULL && MRObj.Requested_Funding_Duration_Unit__c != NULL && MRObj.List_Price_per_Unit__c != NULL &&
                                             MRObj.Strength__c != NULL && MRObj.Medication_Formulation__c != NULL);
                if(isInputMRNotBlank){
                    MRObj.Expenditure_Estimate__c = EDRD_cls_DrugCostCalculator.populateMRExpenditureEstimate(MRObj.Dosage__c, 
                                                                                                              MRObj.Dosage_Units__c, 
                                                                                                              MRObj.Requested_Frequency__c, 
                                                                                                              MRObj.Requested_Frequency_Unit__c,
                                                                                                              MRObj.Requested_Funding_Duration__c, 
                                                                                                              MRObj.Requested_Funding_Duration_Unit__c,
                                                                                                              MRObj.List_Price_per_Unit__c, 
                                                                                                              MRObj.Strength__c,
                                                                                                              MRObj.Medication_Formulation__c);
                }else{
                    MRObj.Expenditure_Estimate__c = NULL;
                }
                MRListToUpdate.add(MRObj);
                
                Boolean isInputCaseNotBlank = (MRObj.Case__c != NULL && MRObj.Case__r.EDRD_MOHApproved_Dosage__c != NULL && MRObj.Case__r.EDRD_MOHApproved_Dosage_Unit__c != NULL &&
                                               MRObj.Case__r.EDRD_MOHApproved_Frequency__c != NULL && MRObj.Case__r.EDRD_MOHApproved_Frequency_Unit__c != NULL &&
                                               MRObj.Case__r.EDRD_MOHApproved_Funding_Duration__c != NULL && MRObj.Case__r.EDRD_MOHApproved_Funding_Duration_Unit__c != NULL
                                               && MRObj.List_Price_per_Unit__c != NULL && MRObj.Strength__c != NULL && MRObj.Medication_Formulation__c != NULL);
                Decimal drugCostOnCase;
                if(isInputCaseNotBlank){
                    drugCostOnCase = EDRD_cls_DrugCostCalculator.populateMRExpenditureEstimate(MRObj.Case__r.EDRD_MOHApproved_Dosage__c,
                                                                                               MRObj.Case__r.EDRD_MOHApproved_Dosage_Unit__c,
                                                                                               MRObj.Case__r.EDRD_MOHApproved_Frequency__c,
                                                                                               MRObj.Case__r.EDRD_MOHApproved_Frequency_Unit__c,
                                                                                               MRObj.Case__r.EDRD_MOHApproved_Funding_Duration__c,
                                                                                               MRObj.Case__r.EDRD_MOHApproved_Funding_Duration_Unit__c,
                                                                                               MRObj.List_Price_per_Unit__c, 
                                                                                               MRObj.Strength__c,
                                                                                               MRObj.Medication_Formulation__c);
                    
                }
                caseListToUpdate.add(new Case(Id = MRObj.Case__c, EDRD_MOHDrug_Cost_Forecast__c = drugCostOnCase));
            }
            if(!MRListToUpdate.isEmpty()){
                Update MRListToUpdate;
            }
            if(!caseListToUpdate.isEmpty()){
                Update caseListToUpdate;
            }
        }
    }
}