/**********************************************************************************************
* @Author:      Deepak 
* @Date:        14 Dec 2023
* @Description: The purpose of this class is to create methods which can be used by different trigger event
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]
				19 Dec -  EDRD-282          -  Accenture   -  Added populateMRExpenditureEstimate Method
                09 Jan -  EDRD-139          -  Accenture   -  Added calDrugForecastOnCase Method
                09 Jan -  EDRD-139          -  Accenture   -  Added updateForecastOnCase Method
***********************************************************************************************/
public with sharing class medicationRequestTriggerHandler {
    
/**
* @author: Deepak
* @date: 14 Dec 2023
* @description: The purpose of this method is to validate the Medication Request Insert.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
                     20 Jun -     EDRD-764		 -  Accenture   -  Populate EDRD Reference number
*/ 
    public static void validateMedicationRequest(List<MedicationRequest> MRListValidate){
        Set<Id> caseIdSet = new Set<Id>();
        for(MedicationRequest MRObj: MRListValidate){
            caseIdSet.add(MRObj.Case__c);
        }
        Map<Id, Case> caseIdVsRec = new Map<Id, case> ([SELECT Id, EDRD_Ref_No__c, (SELECT Id, Case__c FROM Medication_Requests__r) 
                                     FROM Case WHERE ID IN: caseIdSet]);
        for(MedicationRequest MRObj : MRListValidate)
        {
            if(String.isBlank(MRObj.EDRD_Reference_Number__c))
			{                
                Boolean isMRInsertNHasOldMR = trigger.isInsert && caseIdVsRec.containsKey(MRObj.Case__c) && 
                                               caseIdVsRec.get(MRObj.Case__c).medication_Requests__r != NULL && 
                                               !caseIdVsRec.get(MRObj.Case__c).medication_Requests__r.isEmpty();
                if(isMRInsertNHasOldMR){
                    MRObj.addError(label.EDRD_label_MR_duplicateCase);
                }
                else{
                    MRObj.EDRD_Reference_Number__c = caseIdVsRec?.get(MRObj.Case__c)?.EDRD_Ref_No__c;
                }                
          	}
        }
    }   
      
/**
* @author: Deepak
* @date: 09 Jan 2024
* @description: The purpose of this method is to return DrugForecast with Respect to Case.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
                     04-Oct     EDRD-679            Deepak         Adding Changes Related to Formulation Type-Bottle
*/    
    public static Map<Id, Decimal> calDrugForecastOnCase(Set<Id> caseIdSet, Map<Id, case> caseIdVsRec){
        Map<Id, Decimal> caseIdVsForcastAmnt = new Map<Id, Decimal>();
        Boolean isInputNotBlank = false;
        List<MedicationRequest> MRCaseList = [SELECT Id, Case__c, Case__r.EDRD_MOHApproved_Dosage__c, Case__r.EDRD_MOHApproved_Dosage_Unit__c,
                                              Case__r.EDRD_MOHApproved_Frequency__c, Case__r.EDRD_MOHApproved_Frequency_Unit__c, 
                                              Case__r.EDRD_MOHApproved_Funding_Duration__c, Case__r.EDRD_MOHApproved_Funding_Duration_Unit__c, Case__r.EDRD_MOHIndefinite_Funding__c,
                                              Medication_Information__c, Strength__c, Strength_Units__c, List_Price_per_Unit__c, Medication_Formulation__c FROM MedicationRequest
                                              WHERE Case__c IN: caseIdSet AND recordType.developerName = 'EDRD_Medication_Request'];
        
        for(MedicationRequest MRObj: MRCaseList){
            Decimal Dosage, RecFrequency, RecFundingDuration;
            String RecFrequencyUnits, DosageUnits, RecFundingDurationUnit;
            Boolean isFromCaseTrigger = caseIdVsRec.ContainsKey(MRObj.Case__c);
            
            Dosage = isFromCaseTrigger ? caseIdVsRec.get(MRObj.Case__c).EDRD_MOHApproved_Dosage__c : MRObj.Case__r.EDRD_MOHApproved_Dosage__c;
            DosageUnits = isFromCaseTrigger ? caseIdVsRec.get(MRObj.Case__c).EDRD_MOHApproved_Dosage_Unit__c : MRObj.Case__r.EDRD_MOHApproved_Dosage_Unit__c;
            RecFrequency = isFromCaseTrigger ? caseIdVsRec.get(MRObj.Case__c).EDRD_MOHApproved_Frequency__c : MRObj.Case__r.EDRD_MOHApproved_Frequency__c;
            RecFrequencyUnits = isFromCaseTrigger ? caseIdVsRec.get(MRObj.Case__c).EDRD_MOHApproved_Frequency_Unit__c : MRObj.Case__r.EDRD_MOHApproved_Frequency_Unit__c;
            Boolean isIndefiniteFunding = isFromCaseTrigger ? caseIdVsRec.get(MRObj.Case__c).EDRD_MOHIndefinite_Funding__c : MRObj.Case__r.EDRD_MOHIndefinite_Funding__c;
            RecFundingDuration = isFromCaseTrigger ? (isIndefiniteFunding ? 1 : caseIdVsRec.get(MRObj.Case__c).EDRD_MOHApproved_Funding_Duration__c) : (isIndefiniteFunding ? 1: MRObj.Case__r.EDRD_MOHApproved_Funding_Duration__c);
            RecFundingDurationUnit = isFromCaseTrigger ? ( isIndefiniteFunding ? 'Years' : caseIdVsRec.get(MRObj.Case__c).EDRD_MOHApproved_Funding_Duration_Unit__c) : (isIndefiniteFunding ? 'Years' : MRObj.Case__r.EDRD_MOHApproved_Funding_Duration_Unit__c);
            
            isInputNotBlank = (Dosage != NULL && DosageUnits != NULL && RecFrequency != NULL && 
                               RecFrequencyUnits != NULL && RecFundingDuration != NULL &&
                               RecFundingDurationUnit != NULL && MRObj.List_Price_per_Unit__c != NULL && MRObj.Strength__c != NULL);
            
            if(isInputNotBlank){
                Decimal forecastDrugOncase = EDRD_cls_DrugCostCalculator.populateMRExpenditureEstimate(Dosage, 
                                                                                                   DosageUnits, 
                                                                                                   RecFrequency, 
                                                                                                   RecFrequencyUnits,
                                                                                                   RecFundingDuration,
                                                                                                   RecFundingDurationUnit,
                                                                                                   MRObj.List_Price_per_Unit__c, 
                                                                                                   MRObj.Strength__c,
                                                                                                   MRObj.Medication_Formulation__c);
                caseIdVsForcastAmnt.put(MRObj.Case__c, forecastDrugOncase);
                ESA_cls_caseTriggerHandler.caseIdVsCostPerDose.put(MRObj.Case__c, ESA_cls_caseTriggerHandler.costPerDose);
            }
        }
        return caseIdVsForcastAmnt;
    }
 
/**
* @author: Deepak
* @date: 09 Jan 2024
* @description: The purpose of this method is to Update Drug Forecast cost.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/  
    public static void updateForecastOnCase(Set<Id> caseIdSet){
        List<Case> caseListToUpdate = new List<Case>();
        Map<Id, Decimal> caseIdVsForcastAmnt = calDrugForecastOnCase(caseIdSet, new Map<Id, case>());
        for(Id CaseId: caseIdSet){
            caseListToUpdate.add(new Case(Id = CaseId,
                                          EDRD_MOHDrug_Cost_Forecast__c = caseIdVsForcastAmnt.ContainsKey(CaseId) 
                                          ? caseIdVsForcastAmnt.get(CaseId) : NULL));
        }
        if(!caseListToUpdate.isEmpty()){
            Update caseListToUpdate;
        }
    }
}