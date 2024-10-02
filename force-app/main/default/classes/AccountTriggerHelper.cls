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
* @description: Update EDRD case records in system context on patient deceased.
* @param Set<Id> patientIdSet: Set of ID's records to process respective EDRD Cases.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/ 
    public static void processDeceasedPatientEDRDCases(Set<Id> patientIdSet) {        
        if(!patientIdSet.isEmpty()){
            List<Case> caseList = [SELECT Id, Status, Account.Patient_is_Deceased__pc, EDRD_Notes__c, EDRD_Case_closure_reasons__c, 
                                   EDRD_MOHFunding_Expiry_Date__c, EDRD_MOHFunding_Extension_Date__c, EDRD_MOHIndefinite_Funding__c,
                                   EDRD_MOHFunding_Decision__c, IsClosed 
                                   FROM Case 
                                   WHERE AccountID IN :patientIdSet 
                                   AND RecordType.DeveloperName = 'EDRD'
                                   AND (IsClosed = FALSE OR (IsClosed = TRUE 
                                                             AND Status = 'Funding Approved' 
                                                             AND (EDRD_MOHFunding_Expiry_Date__c > :System.Today() 
                                                                  OR EDRD_MOHFunding_Extension_Date__c > :System.Today() 
                                                                  OR EDRD_MOHIndefinite_Funding__c = TRUE)))
                                  ];
            
            List<CareProgramEnrollee> enrolleToUpdate = [SELECT Id, CareProgramId, Status, Inactive_Reason__c 
                                                         FROM CareProgramEnrollee 
                                                         WHERE CareProgram.Name = 'EDRD' 
                                                         AND AccountId IN :patientIdSet];
            
            List<Case> casesToUpdate = new List<Case>();
            List<Case> appCaseToChangeEndDate = new List<Case>();
            
            for (Case caseObj : caseList) {
                if (caseObj.Account.Patient_is_Deceased__pc) {
                    if (!caseObj.IsClosed) {
                        caseObj.EDRD_MOHFunding_Decision__c = ESA_cls_constants.EDRD_FUNDING_DECISION_DENIED;
                        caseObj.Status = ESA_cls_constants.EDRD_CASE_STATUS_CANCELLED;
                        caseObj.EDRD_Case_Closure_Reasons__c = ESA_cls_constants.EDRD_CASE_CLOSER_REASON_PATIENT_DECEASED;
                        String existingValue = String.isEmpty(caseObj.EDRD_Notes__c) ? '' : caseObj.EDRD_Notes__c;
                        caseObj.EDRD_Notes__c = existingValue + '\n' + Label.EDRD_label_Patient_deceased;
                        casesToUpdate.add(caseObj);
                    } else if (caseObj.IsClosed) {
                        String existingValue = String.isEmpty(caseObj.EDRD_Notes__c) ? '' : caseObj.EDRD_Notes__c;
                        
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
                }
            }
            
            for (CareProgramEnrollee careEnrolleeObj : enrolleToUpdate) {
                careEnrolleeObj.Status = 'Inactive';
                careEnrolleeObj.Inactive_Reason__c = 'Patient Deceased';
            }
            
            if (!casesToUpdate.isEmpty()) {
                Database.update(casesToUpdate, true);
            }
            
            if (!appCaseToChangeEndDate.isEmpty()) {
                Database.update(appCaseToChangeEndDate, true);
            }
            
            if (!enrolleToUpdate.isEmpty()) {
                Database.update(enrolleToUpdate, true);
            }
        }
    }
}