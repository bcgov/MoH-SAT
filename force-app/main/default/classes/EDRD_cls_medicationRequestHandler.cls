/**********************************************************************************************
* @Author:      Deepak 
* @Date:        14 Dec 2023
* @Description: The purpose of this class is to create methods which can be used by different trigger event
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]  
***********************************************************************************************/
public with sharing class EDRD_cls_medicationRequestHandler {
    
/**
* @author: Deepak
* @date: 14 Dec 2023
* @description: The purpose of this method is to validate the Medication Request Insert.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/ 
    public static void validateMedicationRequest(List<MedicationRequest> MRListValidate){
        Set<Id> caseIdSet = new Set<Id>();
        for(MedicationRequest MRObj: MRListValidate){
            caseIdSet.add(MRObj.Case__c);
        }
        Map<Id, Case> caseIdVsRec = new Map<Id, case> ([SELECT Id, (SELECT Id, Case__c FROM Medication_Requests__r) 
                                     FROM Case WHERE ID IN: caseIdSet]);
        
        for(MedicationRequest MRObj : MRListValidate){
            Boolean isMRInsertNHasOldMR = trigger.isInsert && caseIdVsRec.containsKey(MRObj.Case__c) && 
                                           caseIdVsRec.get(MRObj.Case__c).medication_Requests__r != NULL && 
                                           !caseIdVsRec.get(MRObj.Case__c).medication_Requests__r.isEmpty();
            if(isMRInsertNHasOldMR){
                MRObj.addError(label.EDRD_label_MR_duplicateCase);
            }
        }
    }
    
 /**
* @author: Deepak
* @date: 19 Dec 2023
* @description: The purpose of this method is to calculate drug forecast on Medication Request.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/ 
    public static Decimal populateMRExpenditureEstimate(Decimal Dosage, String DosageUnits, Decimal RecFrequency, 
                                                     String RecFrequencyUnits, Decimal RecFundingDuration, 
                                                     String RecFundingDurationUnit, Decimal ListPrice, Decimal Strength)
    {
        Decimal noOfUnit = 0;
        Integer RecFrequencyUnitsDays = returnDaysFrmUnits(RecFrequencyUnits);
        Integer RecFundingDurationUnitDays = returnDaysFrmUnits(RecFundingDurationUnit);        
        
        noOfUnit = Math.ceil((RecFundingDurationUnitDays * RecFundingDuration)/(RecFrequencyUnitsDays));
        noOfUnit = noOfUnit * RecFrequency ;
        Integer reqStandrdDosePerDose = 0;
        
        do {
            reqStandrdDosePerDose = reqStandrdDosePerDose + 1;
            Strength = Strength * reqStandrdDosePerDose;
        } while (Strength/Dosage < 1);
        
        return (noOfUnit * reqStandrdDosePerDose * ListPrice);
    }      

    private static Integer returnDaysFrmUnits(String Unit){
        Integer days = 0;
        if(Unit == 'Daily' || Unit == 'Days'){
           days = 1;
        }else if(Unit == 'Weekly' || Unit == 'Weeks'){
            days = 7;
        }else if(Unit == 'Monthly' || Unit == 'Months'){
            days = 30;
        }else if(Unit == 'Yearly' || Unit == 'Years'){
            days = 364;
        }
        return days;
    }    
}