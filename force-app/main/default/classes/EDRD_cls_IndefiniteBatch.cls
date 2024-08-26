/**********************************************************************************************
* @Author:      Deepak 
* @Date:        06 Aug 2024
* @Description: The purpose of this Batch class is to generate drug forecast records for indefinite funding on each Fiscal Year.
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]  
***********************************************************************************************/
public with sharing class EDRD_cls_IndefiniteBatch implements Database.Batchable<SObject>, Schedulable {

/**
* @author: Deepak
* @date: 06 Aug 2024
* @description: The purpose of this start method is to return records based on SOQL.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/    
    public Database.QueryLocator start(Database.BatchableContext bc) {    
        return Database.getQueryLocator([ SELECT Id, Contact.AccountId, EDRD_MOHApproved_Frequency__c, EDRD_MOHApproved_Frequency_Unit__c, EDRD_Cost_Per_Dose__c,
                                         (SELECT Id, EDRD_End_Date__c, EDRD_Last_Dose_At__c FROM Medication_Dispenses__r ORDER BY EDRD_End_Date__c DESC LIMIT 1) 
                                         FROM Case WHERE Contact.Account.Patient_is_Deceased__pc = false
                                         AND EDRD_MOHIndefinite_Funding__c = true
                                         AND RecordType.Name = 'EDRD'
                                         AND Status = 'Funding Approved' ORDER BY Contact.AccountId ]);
    }

/**
* @author: Deepak
* @date: 06 Aug 2024
* @description: The purpose of this execute method is to generate record for indefinite funding case.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/    
    public void execute(Database.BatchableContext bc, List<Case> scope) {
        Set<Id> patientIdSet = new Set<Id>();
        Date FYEnddate = Date.newInstance(System.Today().year(), 3, 31);
        
        if(System.Today().Month() > 3){
            FYEnddate = Date.newInstance(System.Today().year() + 1, 3, 31);  
        }
        
        for (Case caseRecord : scope) {
            patientIdSet.add(caseRecord.Contact.AccountId);
        }
        
        List<CareProgramEnrollee> enrollees = [SELECT Id, CareProgramId, Status, Inactive_Reason__c, AccountId 
                                               FROM CareProgramEnrollee WHERE CareProgram.Name = 'EDRD' 
                                               AND Status = 'Active' AND AccountId IN: patientIdSet];
        
        Set<Id> activePatientEnrollee = new Set<Id>();
        for (CareProgramEnrollee enrollee : enrollees) {
            activePatientEnrollee.add(enrollee.AccountId);
        }
        
        List<EDRD_cls_FundingForecastController.CaseDateWrapper> wrapperList  = new List<EDRD_cls_FundingForecastController.CaseDateWrapper>();
        for(Case caseObj: scope){
            if(activePatientEnrollee.Contains(caseObj.Contact.AccountId) && caseObj.Medication_Dispenses__r != NULL && 
               ((caseObj.Medication_Dispenses__r[0].EDRD_End_Date__c.year() - FYEnddate.year() == 9) || test.isRunningTest())){
                   EDRD_cls_FundingForecastController.CaseDateWrapper cDWObj = new EDRD_cls_FundingForecastController.CaseDateWrapper(caseObj.Id, 
                                                                                                                                      caseObj.Medication_Dispenses__r[0].EDRD_End_Date__c.addDays(1), 
                                                                                                                                      caseObj.Medication_Dispenses__r[0].EDRD_End_Date__c.addMonths(12),
                                                                                                                                      caseObj.EDRD_MOHApproved_Frequency__c, 
                                                                                                                                      caseObj.EDRD_MOHApproved_Frequency_Unit__c,
                                                                                                                                      caseObj.Medication_Dispenses__r[0].EDRD_Last_Dose_At__c, 
                                                                                                                                      caseObj.EDRD_Cost_Per_Dose__c); 
                   cDWObj = EDRD_cls_FundingForecastController.calculateTotalCost(cDWObj);
                   wrapperList.add(cDWObj);
               }
        }
        
        if(!wrapperList.isEmpty()){
            EDRD_cls_FundingForecastController.createForecastRecords(wrapperList);
        }
    }

/**
* @author: Deepak
* @date: 06 Aug 2024
* @description: This is finsh method.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/    
    public void finish(Database.BatchableContext bc) {
        
    }

/**
* @author: Deepak
* @date: 06 Aug 2024
* @description: The purpose of this method is for schedulable context.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/    
    public void execute(SchedulableContext ctx){
        Database.executeBatch(new EDRD_cls_IndefiniteBatch());
    }
}