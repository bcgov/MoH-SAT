/**********************************************************************************************
* @Author:      Deepak 
* @Date:        07 Jan 2024
* @Description: The purpose of this class is to calculate drug forecast on Medication Request/Case.
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]  
                27-Aug     EDRD-679            Deepak         Adding returnDaysFrmUnitsNDuration method 
***********************************************************************************************/
public with sharing class EDRD_cls_DrugCostCalculator {

/**
* @author: Deepak
* @date: 07 Jan 2023
* @description: The purpose of this method is to calculate drug forecast on Medication Request.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
                     27-Aug     EDRD-679            Deepak         Adding returnDaysFrmUnitsNDuration method
*/ 
    public static Decimal populateMRExpenditureEstimate(Decimal Dosage, String DosageUnits, Decimal RecFrequency, 
                                                     String RecFrequencyUnits, Decimal RecFundingDuration, 
                                                     String RecFundingDurationUnit, Decimal ListPrice, Decimal Strength){
        Decimal noOfUnit = 0;
        Integer RecFrequencyUnitsDays = returnDaysFrmUnits(RecFrequencyUnits);
        Integer RecFundingDurationUnitDays = returnDaysFrmUnitsNDuration(RecFundingDuration, RecFundingDurationUnit);
        
        noOfUnit = Math.ceil((RecFundingDurationUnitDays)/(RecFrequencyUnitsDays));
        noOfUnit = noOfUnit * RecFrequency ;
        Integer reqStandrdDosePerDose = 0;
        Decimal originalStrength = Strength;
        Decimal accumulatedStrength = 0;
        
        do {
            reqStandrdDosePerDose = reqStandrdDosePerDose + 1;
            accumulatedStrength = originalStrength * reqStandrdDosePerDose;
        } while (accumulatedStrength/Dosage < 1);
        
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
    
    private static Integer returnDaysFrmUnitsNDuration(Decimal duration, String unit) {
        Integer days = 0;
        Date startDate = System.today();
        Date expDate;
        Integer durationRound = Integer.valueOf(duration.round(System.RoundingMode.CEILING));
        
        if (unit == 'Days') {
            expDate = startDate.addDays(durationRound).addDays(-1);
            days = startDate.daysBetween(expDate) + 1;
        } else if (unit == 'Weeks') {
            expDate = startDate.addDays(durationRound * 7).addDays(-1);
            days = startDate.daysBetween(expDate) + 1;
        } else if (unit == 'Months') {
            expDate = startDate.addMonths(durationRound).addDays(-1);
            days = startDate.daysBetween(expDate) + 1;
        } else if (unit == 'Years') {
            expDate = startDate.addYears(durationRound).addDays(-1);
            days = startDate.daysBetween(expDate) + 1;
        } else if (unit == 'Once') {
            expDate = startDate;
            days = startDate.daysBetween(expDate) + 1;
        }        
        return days;
    }
}