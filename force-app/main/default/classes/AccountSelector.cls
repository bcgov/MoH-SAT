/**********************************************************************************************
* @Author:      Accenture 
* @Date:        03 Oct 2024
* @Description: The purpose of this helper class is to modify the account related child records.
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]
***********************************************************************************************/
public with sharing class AccountSelector {
    
/**
* @author: Deepak
* @date: 03 Oct 2024
* @description: Get EDRD case records in system context on patient deceased.
* @param Set<Id> patientIdSet: Set of ID's records to process respective EDRD Cases.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/ 
    public static List<Case> getDeceasedPatientEDRDCases(Set<Id> patientIdSet) {        
        List<Case> eDRDCaseList = new List<Case>();
        
        for(Case caseObj: [SELECT Id, Status, Account.Patient_is_Deceased__pc, EDRD_Notes__c, EDRD_Case_closure_reasons__c, 
                           EDRD_MOHFunding_Expiry_Date__c, EDRD_MOHFunding_Extension_Date__c, EDRD_MOHIndefinite_Funding__c,
                           EDRD_MOHFunding_Decision__c, IsClosed 
                           FROM Case 
                           WHERE AccountID IN :patientIdSet 
                           AND RecordType.DeveloperName = 'EDRD'
                           AND (IsClosed = FALSE OR (IsClosed = TRUE 
                                                     AND Status = 'Funding Approved' 
                                                     AND (EDRD_MOHFunding_Expiry_Date__c > :System.Today() 
                                                          OR EDRD_MOHFunding_Extension_Date__c > :System.Today() 
                                                          OR EDRD_MOHIndefinite_Funding__c = TRUE)))]) {
                                                              eDRDCaseList.add(caseObj);
                                                          }
        
        return eDRDCaseList;
    }
    
/**
* @author: Deepak
* @date: 03 Oct 2024
* @description: Get EDRD CPE records in system context on patient deceased.
* @param Set<Id> patientIdSet: Set of ID's records to process respective EDRD Cases.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/ 
    public static List<CareProgramEnrollee> getDeceasedPatientEDRDCPE(Set<Id> patientIdSet) {    
        List<CareProgramEnrollee> eDRDCPEList = new List<CareProgramEnrollee>();
        
        for(CareProgramEnrollee cPEObj: [SELECT Id, CareProgramId, Status, Inactive_Reason__c 
                                         FROM CareProgramEnrollee 
                                         WHERE CareProgram.Name = 'EDRD' 
                                         AND AccountId IN :patientIdSet]) {
                                             eDRDCPEList.add(cPEObj) ; 
                                         }
        return eDRDCPEList;
    }
}