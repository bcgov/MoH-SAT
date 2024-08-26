/**********************************************************************************************
* @Author:      Deepak 
* @Date:        07 Jan 2024
* @Description: The purpose of this class is to calculate drug forecast on Medication Request/Case.
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]  
***********************************************************************************************/
public with sharing class EDRD_cls_DrugCostCalculator {

/**
* @author: Deepak
* @date: 07 Jan 2023
* @description: The purpose of this method is to calculate drug forecast on Medication Request.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/ 
    public static Decimal populateMRExpenditureEstimate(Decimal Dosage, String DosageUnits, Decimal RecFrequency, 
                                                     String RecFrequencyUnits, Decimal RecFundingDuration, 
                                                     String RecFundingDurationUnit, Decimal ListPrice, Decimal Strength){
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
        
        ESA_cls_caseTriggerHandler.costPerDose = reqStandrdDosePerDose * ListPrice;
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
            days = 365;
        }else if(Unit == 'Once'){
            days = 1;
        }
        return days;
    }    
}