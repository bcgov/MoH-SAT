/**********************************************************************************************
* @Author:      Deepak 
* @Date:        29 Jul 2024
* @Description: The purpose of this class is to generate drug forecast records on Fiscal Year Forecasting records.
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]  
***********************************************************************************************/
public with sharing class EDRD_cls_FundingForecastController {
 
/**
* @author: Deepak
* @date: 29 July 2024
* @description: The purpose of this method is to generate the indiviual FY records for forecasted amount.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/    
    public static void generateForecastRecords(List<Case> appcaseList){
        List<MedicationDispense> forecastRecords = new List<MedicationDispense>();
        List<CaseDateWrapper> wrapperList = new List<CaseDateWrapper>();
        Integer daysInFunding;
        
        for(case caseObj : appcaseList){
            Date stDate = caseObj.EDRD_MOHFunding_Start_Date__c;
            Date endDate = caseObj.EDRD_MOHIndefinite_Funding__c ? caseObj.EDRD_MOHFunding_Start_Date__c.addMonths(120).addDays(-1) : (caseObj.EDRD_MOHFunding_Decision__c == 'Approved') ? caseObj.EDRD_MOHFunding_Expiry_Date__c : caseObj.EDRD_MOHFunding_Extension_Date__c;
            Date firstFYEnddate = Date.newInstance(stDate.year(), 3, 31);
            Decimal forecastAmount; 
            daysInFunding = endDate.daysBetween(stDate) + 1;
            
            if(stDate.Month() > 3){
                firstFYEnddate = Date.newInstance(stDate.year() + 1, 3, 31);  
            }
            
            if(endDate < firstFYEnddate){
                CaseDateWrapper cDWObj = new CaseDateWrapper(caseObj.Id, stDate, enddate, caseObj.EDRD_MOHApproved_Frequency__c, caseObj.EDRD_MOHApproved_Frequency_Unit__c, stDate, caseObj.EDRD_Cost_Per_Dose__c); 
                cDWObj = calculateTotalCost(cDWObj);
                wrapperList.add(cDWObj);
            }
            else if(endDate > firstFYEnddate && endDate < Date.newInstance(firstFYEnddate.year() + 1, 3, 31)) {
                CaseDateWrapper cDWObj = new CaseDateWrapper(caseObj.Id,stDate, firstFYEnddate, caseObj.EDRD_MOHApproved_Frequency__c, caseObj.EDRD_MOHApproved_Frequency_Unit__c, stDate, caseObj.EDRD_Cost_Per_Dose__c);
                cDWObj = calculateTotalCost(cDWObj);
                CaseDateWrapper cDWObjNext = new CaseDateWrapper(caseObj.Id,firstFYEnddate.addDays(1), endDate, caseObj.EDRD_MOHApproved_Frequency__c, caseObj.EDRD_MOHApproved_Frequency_Unit__c, cDWObj.lastDoseAt, caseObj.EDRD_Cost_Per_Dose__c);
                adjustFirstDoseAt(cDWObjNext);
                cDWObjNext = calculateTotalCost(cDWObjNext);
                wrapperList.add(cDWObj);
                wrapperList.add(cDWObjNext);
            }
            else {
                CaseDateWrapper cDWObj = new CaseDateWrapper(caseObj.Id,stDate, firstFYEnddate, caseObj.EDRD_MOHApproved_Frequency__c, caseObj.EDRD_MOHApproved_Frequency_Unit__c, stDate, caseObj.EDRD_Cost_Per_Dose__c);
                cDWObj = calculateTotalCost(cDWObj);
                wrapperList.add(cDWObj);
                Date lastDosageAt = cDWObj.lastDoseAt;
                do{
                    if(endDate > Date.newInstance(firstFYEnddate.year() + 1, 3, 31)){
                        CaseDateWrapper cDWObjNext = new CaseDateWrapper(caseObj.Id,firstFYEnddate.addDays(1), Date.newInstance(firstFYEnddate.year() + 1, 3, 31), caseObj.EDRD_MOHApproved_Frequency__c, caseObj.EDRD_MOHApproved_Frequency_Unit__c, lastDosageAt, caseObj.EDRD_Cost_Per_Dose__c);
                        adjustFirstDoseAt(cDWObjNext);
                        cDWObjNext = calculateTotalCost(cDWObjNext);
                        wrapperList.add(cDWObjNext);
                        lastDosageAt = cDWObjNext.lastDoseAt;
                    }
                    else{
                        CaseDateWrapper cDWObjNext = new CaseDateWrapper(caseObj.Id,firstFYEnddate.addDays(1), endDate, caseObj.EDRD_MOHApproved_Frequency__c, caseObj.EDRD_MOHApproved_Frequency_Unit__c, lastDosageAt, caseObj.EDRD_Cost_Per_Dose__c);
                        cDWObjNext = calculateTotalCost(cDWObjNext);
                        wrapperList.add(cDWObjNext);
                    }
                    firstFYEnddate = firstFYEnddate.addMonths(12);
                }
                while(firstFYEnddate < endDate);
            }
        }
        if(!wrapperList.isEmpty()){
            createForecastRecords(wrapperList);
        }
    }
    
    public static void createForecastRecords(List<CaseDateWrapper> wrapperList){
        Id recordTypeEDRDFY = Schema.SObjectType.MedicationDispense.getRecordTypeInfosByDeveloperName().get('EDRD_FY_Medication_Dispense').getRecordTypeId();
        List<MedicationDispense> fYForecastingList = new List<MedicationDispense>();
        Set<Id> caseIdSet = new Set<Id>();
        
        for(CaseDateWrapper wrapObj: wrapperList){
            caseIdSet.add(wrapObj.caseId);
        }
        
        Map<Id, Case> caseIdVsRec = new Map<Id, Case>([SELECT Id, Contact.AccountId, (SELECT Id, MedicationId FROM Medication_Requests__r)
                                                       FROM Case WHERE Id =: caseIdSet]);
        
        for(CaseDateWrapper wrapObj: wrapperList){
            if(wrapObj.startDate <= wrapObj.endDate){
                fYForecastingList.add(new MedicationDispense(
                    PatientId = caseIdVsRec?.get(wrapObj.CaseId)?.Contact?.AccountId,
                    MedicationId = caseIdVsRec?.get(wrapObj.CaseId)?.Medication_Requests__r[0]?.MedicationId,
                    Case__c = wrapObj.caseId,
                    EDRD_Start_Date__c = wrapObj.startDate,
                    EDRD_End_Date__c = wrapObj.endDate,
                    EDRD_Forecasted_Amount__c = wrapObj.totalCost,
                    EDRD_First_Dose_At__c = wrapObj.firstDoseAt,
                    EDRD_Last_Dose_At__c = wrapObj.lastDoseAt,
                    Quantity = wrapObj.noOfDosages,            
                    recordTypeId = recordTypeEDRDFY));
            }
        }
        
        if(!fYForecastingList.isEmpty()){
            database.insert(fYForecastingList, true);
            ESA_cls_caseTriggerHandler.FYOnce = false;
        }
    }
    
    public class CaseDateWrapper{
        public Id caseId;
        public Date startDate;
        public Date endDate;
        public Decimal costPerDose;
        public String frequency;
        public Date firstDoseAt;
        public Date lastDoseAt;
        public Decimal dosePerFrequency;
        public Decimal noOfDosages;
        public Decimal totalCost;
        
        public CaseDateWrapper(Id CaseId, Date startDate, Date endDate, Decimal dosePerFrequency, String frequency, Date firstDoseAt, Decimal costPerDose){
            this.caseId = caseId;
            this.startDate = startDate;
            this.endDate = endDate;
            this.costPerDose = costPerDose;
            this.frequency = frequency;
            this.firstDoseAt = firstDoseAt;
            this.dosePerFrequency = dosePerFrequency;
        }
    }
    
    public static CaseDateWrapper calculateTotalCost(CaseDateWrapper wrapperObj){
        CaseDateWrapper caseDateWrapperObj = wrapperObj.Clone();
        if(wrapperObj.frequency == 'Once'){
            caseDateWrapperObj.totalCost = wrapperObj.dosePerFrequency * wrapperObj.costPerDose * 1;
            caseDateWrapperObj.noOfDosages = wrapperObj.dosePerFrequency * 1;
        }
        else if(wrapperObj.frequency == 'Daily'){
            Boolean isOneTimeDose = (wrapperObj.firstDoseAt == wrapperObj.endDate);
            caseDateWrapperObj.totalCost = wrapperObj.dosePerFrequency * wrapperObj.costPerDose * (isOneTimeDose ? 1 : wrapperObj.firstDoseAt.daysBetween(wrapperObj.endDate));
            caseDateWrapperObj.noOfDosages = wrapperObj.dosePerFrequency * (isOneTimeDose ? 1 : wrapperObj.firstDoseAt.daysBetween(wrapperObj.endDate));
            caseDateWrapperObj.firstDoseAt = wrapperObj.startDate;
            caseDateWrapperObj.lastDoseAt = wrapperObj.endDate;
        }
        else if(wrapperObj.frequency == 'Weekly' && wrapperObj.dosePerFrequency != 0.5){
            if(wrapperObj.startDate > wrapperObj.firstDoseAt){
                wrapperObj.firstDoseAt = wrapperObj.firstDoseAt.addDays(7);
                caseDateWrapperObj.firstDoseAt = wrapperObj.firstDoseAt;
            }
            Integer noOfDosage = 0;
            do{
                noOfDosage = noOfDosage + 1;
                wrapperObj.firstDoseAt = wrapperObj.firstDoseAt.addDays(7);
            }
            while(wrapperObj.firstDoseAt <= wrapperObj.endDate);
            caseDateWrapperObj.lastDoseAt = (wrapperObj.firstDoseAt != wrapperObj.lastDoseAt) ? wrapperObj.firstDoseAt.addDays(-7) : wrapperObj.firstDoseAt;
            caseDateWrapperObj.totalCost = wrapperObj.dosePerFrequency * wrapperObj.costPerDose * noOfDosage;
            caseDateWrapperObj.noOfDosages = wrapperObj.dosePerFrequency * noOfDosage;
        }
        else if(wrapperObj.frequency == 'Weekly' && wrapperObj.dosePerFrequency == 0.5){
            if(wrapperObj.startDate > wrapperObj.firstDoseAt){
                wrapperObj.firstDoseAt = wrapperObj.firstDoseAt.addDays(14);
                caseDateWrapperObj.firstDoseAt = wrapperObj.firstDoseAt;
            }
            Integer noOfDosage = 0;
            do{
                noOfDosage = noOfDosage + 2;
                wrapperObj.firstDoseAt = wrapperObj.firstDoseAt.addDays(14);
            }
            while(wrapperObj.firstDoseAt <= wrapperObj.endDate);
            caseDateWrapperObj.lastDoseAt = (wrapperObj.firstDoseAt != wrapperObj.lastDoseAt) ? wrapperObj.firstDoseAt.addDays(-14) : wrapperObj.firstDoseAt;
            caseDateWrapperObj.totalCost = wrapperObj.dosePerFrequency * wrapperObj.costPerDose * noOfDosage;
            caseDateWrapperObj.noOfDosages = wrapperObj.dosePerFrequency * noOfDosage;
        }
        else if(wrapperObj.frequency == 'Monthly'){
            Integer noOfDosage = 0;
            if(wrapperObj.startDate > wrapperObj.firstDoseAt){
                wrapperObj.firstDoseAt = wrapperObj.firstDoseAt.addMonths(1);
                caseDateWrapperObj.firstDoseAt = wrapperObj.firstDoseAt;
            }
            do{
                noOfDosage = noOfDosage + 1;
                wrapperObj.firstDoseAt = wrapperObj.firstDoseAt.addMonths(1);
            }
            while(wrapperObj.firstDoseAt <= wrapperObj.endDate); 
            caseDateWrapperObj.lastDoseAt = (wrapperObj.firstDoseAt != wrapperObj.lastDoseAt) ? wrapperObj.firstDoseAt.addMonths(-1) : wrapperObj.firstDoseAt;
            caseDateWrapperObj.totalCost = wrapperObj.dosePerFrequency * wrapperObj.costPerDose * noOfDosage;
            caseDateWrapperObj.noOfDosages = wrapperObj.dosePerFrequency * noOfDosage;
        }
        else if(wrapperObj.frequency == 'Yearly'){
            Integer noOfDosage = 0;
            if(wrapperObj.startDate > wrapperObj.firstDoseAt){
                wrapperObj.firstDoseAt = wrapperObj.firstDoseAt.addMonths(12);
                caseDateWrapperObj.firstDoseAt = wrapperObj.firstDoseAt;
            }
            do{
                noOfDosage = noOfDosage + 1;
                wrapperObj.firstDoseAt = wrapperObj.firstDoseAt.addMonths(12);
            }
            while(wrapperObj.firstDoseAt <= wrapperObj.endDate);  
            caseDateWrapperObj.lastDoseAt = (wrapperObj.firstDoseAt != wrapperObj.lastDoseAt) ? wrapperObj.firstDoseAt.addMonths(-12) : wrapperObj.firstDoseAt;
            caseDateWrapperObj.totalCost = wrapperObj.dosePerFrequency * wrapperObj.costPerDose * noOfDosage;
            caseDateWrapperObj.noOfDosages = wrapperObj.dosePerFrequency * noOfDosage;
        }
        return caseDateWrapperObj;
    }
    
    private static void adjustFirstDoseAt(CaseDateWrapper wrapperObj){
        if(wrapperObj.frequency == 'Weekly' && wrapperObj.dosePerFrequency != 0.5){
            wrapperObj.firstDoseAt = wrapperObj.firstDoseAt.addDays(7);
        }
        else if(wrapperObj.frequency == 'Weekly' && wrapperObj.dosePerFrequency == 0.5){
            wrapperObj.firstDoseAt = wrapperObj.firstDoseAt.addDays(14);
        }
        else if(wrapperObj.frequency == 'Monthly'){
            wrapperObj.firstDoseAt = wrapperObj.firstDoseAt.addMonths(1);
        }
        else if(wrapperObj.frequency == 'Yearly'){
            wrapperObj.firstDoseAt = wrapperObj.firstDoseAt.addMonths(12);
        }
    }
}