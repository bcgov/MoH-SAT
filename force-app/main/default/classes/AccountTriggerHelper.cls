/**********************************************************************************************
* @Author:      Accenture 
* @Date:        02 Oct 2024
* @Description: The purpose of this helper class is to modify the account related child records.
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]
***********************************************************************************************/
public without sharing class AccountTriggerHelper {
    
/**
* @author: Deepak
* @date: 02 Oct 2024
* @description: Update EDRD CPE records in system context on patient deceased.
* @param Set<Id> patientIdSet: Set of ID's records to process respective EDRD Cases.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/ 
    public static void processDeceasedPatientEDRDCPE(Set<Id> patientIdSet) {        
        try{
            List<CareProgramEnrollee> enrolleToUpdate = AccountSelector.getDeceasedPatientEDRDCPE(patientIdSet);
            
            for (CareProgramEnrollee careEnrolleeObj : enrolleToUpdate) {
                careEnrolleeObj.Status = 'Inactive';
                careEnrolleeObj.Inactive_Reason__c = 'Patient Deceased';
            }
            
            if (!enrolleToUpdate.isEmpty()) {
                Database.update(enrolleToUpdate, true);
            }
        } catch(Exception ex){
            System.debug('Error updating EDRD CPE records: ' + ex.getMessage());
        }
    }
    
/**
* @author: Deepak
* @date: 02 Oct 2024
* @description: Update EDRD case records in system context on patient deceased.
* @param Set<Id> patientIdSet: Set of ID's records to process respective EDRD Cases.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/ 
    public static void processDeceasedPatientEDRDCases(Set<Id> patientIdSet) {
        try {
            List<Case> caseList = AccountSelector.getDeceasedPatientEDRDCases(patientIdSet);
            List<Case> casesToUpdate = new List<Case>();
            List<Case> appCaseToChangeEndDate = new List<Case>();
            
            for (Case caseObj : caseList) {
                if (caseObj.Account.Patient_is_Deceased__pc) {
                    handleEDRDCaseUpdates(caseObj, casesToUpdate, appCaseToChangeEndDate);
                }
            }
            
            if (!casesToUpdate.isEmpty()) {
                updateEDRDCaseRecords(casesToUpdate);
            }
            if (!appCaseToChangeEndDate.isEmpty()) {
                updateEDRDCaseRecords(appCaseToChangeEndDate);
            }
            
        } catch (Exception ex) {
            System.debug('Error updating EDRD Case records: ' + ex.getMessage());
        }
    }
    
/**
* @author: Deepak
* @date: 02 Oct 2024
* @description: Private method to handle EDRD case records in system context on patient deceased.
* @param caseObj: Case object to process for updates based on patient's deceased status.
* @param casesToUpdate: List of cases that need to be updated (e.g., closed or denied cases).
* @param appCaseToChangeEndDate: List of approved funding cases where the end date or funding status needs to be updated.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/ 
    private static void handleEDRDCaseUpdates(Case caseObj, List<Case> casesToUpdate, List<Case> appCaseToChangeEndDate) {
        try {
            String existingValue = String.isEmpty(caseObj.EDRD_Notes__c) ? '' : caseObj.EDRD_Notes__c;
            
            if (!caseObj.IsClosed) {
                caseObj.Status = ESA_cls_constants.EDRD_CASE_STATUS_CANCELLED;
                caseObj.EDRD_Case_Closure_Reasons__c = ESA_cls_constants.EDRD_CASE_CLOSER_REASON_PATIENT_DECEASED;
                caseObj.EDRD_Notes__c = existingValue + '\n' + Label.EDRD_label_Patient_deceased;
                casesToUpdate.add(caseObj);
            } else {
                if (caseObj.Status == 'Funding Approved') {
                    if (caseObj.EDRD_MOHFunding_Decision__c == 'Approved' || caseObj.EDRD_MOHIndefinite_Funding__c) {
                        caseObj.EDRD_Notes__c = existingValue + '\n' + Label.EDRD_label_Patient_Dscd_UpdateEndDate;
                        caseObj.EDRD_MOHIndefinite_Funding__c = FALSE;
                        caseObj.EDRD_MOHFunding_Expiry_Date__c = Date.today();
                    } else if (caseObj.EDRD_MOHFunding_Decision__c == 'Extended' || caseObj.EDRD_MOHIndefinite_Funding__c) {
                        caseObj.EDRD_Notes__c = existingValue + '\n' + Label.EDRD_label_Patient_Dscd_UpdateEndExtDate;
                        caseObj.EDRD_MOHIndefinite_Funding__c = FALSE;
                        caseObj.EDRD_MOHFunding_Extension_Date__c = Date.today();
                    }
                    appCaseToChangeEndDate.add(caseObj);
                }
            }
        } catch (Exception ex) {
            System.debug('Error handling EDRD Case updates: ' + ex.getMessage());
        }
    }
    
/**
* @author: Deepak
* @date: 02 Oct 2024
* @description: Private method to update EDRD case records in system context on patient deceased.
* @param recordsToUpdate: List of EDRD case records to be updated in the database.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/     
    private static void updateEDRDCaseRecords(List<Case> recordsToUpdate) {
        try {
            if (!recordsToUpdate.isEmpty()) {
                Database.update(recordsToUpdate, true);
            }
        } catch (DmlException e) {
            System.debug('Error updating EDRD Case records: ' + e.getMessage());
        }
    }
}