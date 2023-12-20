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
}