/**********************************************************************************************
* @Author:      Deepak 
* @Date:        23 Feb 2023
* @Description: The purpose of this class is to create methods which can be used by different trigger event
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description] 
1 Dec23 -   EDRD-170         -   Rahul      -  Manage case assignment
4 Dec23 -   EDRD-332         -  Accenture   -  Change case status according to RPH, SC, AC Review Field
16 Dec23 -   EDRD-282         -  Accenture   -  Sync MR Fields values to Case Fields values
09 Jan -   EDRD-139         -  Accenture   -  calculate DrugForecast on Case
15 Jan -   EDRD-525         -  Accenture   -  Update AC Recommendation Review
19 Jan-    EDRD-338			- Accenture		-Update Funding Expiry Date
19 Jan-    EDRD-382			- Accenture		-Validate Eligibility Form Sign date and Eligibility form Attachment
***********************************************************************************************/

public with sharing class ESA_cls_caseTriggerHandler {    
    public static boolean firstrun= true;    
/**
* @author: Deepak
* @date: 23 Feb 2023
* @description: The purpose of this method is to populate termination date based on Approval time/time unit
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/    
    public static void populateTerminationDate(List<Case> newCases, Map<id,Case> oldCaseMap, Map<id,Case> newCaseMap){
        for(Case caseObj:newCases){
            Boolean isInputsChange = trigger.isUpdate && (oldCaseMap.get(caseObj.id).ESA_Approval_Time__c != newCaseMap.get(caseObj.id).ESA_Approval_Time__c ||
                                                          oldCaseMap.get(caseObj.id).ESA_Approval_Time_Unit__c != newCaseMap.get(caseObj.id).ESA_Approval_Time_Unit__c);
            if((trigger.isInsert && caseObj.Termination_Date__c == NULL) || isInputsChange){
                if(caseObj.ESA_Approval_Time__c != NULL && caseObj.ESA_Approval_Time_Unit__c != NULL){
                    caseObj.Termination_Date__c = ESA_cls_constants.CASE_APPROVAL_TIME_UNIT_WEEK.containsIgnoreCase(caseObj.ESA_Approval_Time_Unit__c) ? System.Today().addDays((Integer.valueOf(caseObj.ESA_Approval_Time__c)*7)+1)
                        : ESA_cls_constants.CASE_APPROVAL_TIME_UNIT_MONTH.containsIgnoreCase(caseObj.ESA_Approval_Time_Unit__c) ? System.Today().addMonths(Integer.valueOf(caseObj.ESA_Approval_Time__c)).addDays(1)
                            : ESA_cls_constants.CASE_APPROVAL_TIME_UNIT_DAYS.containsIgnoreCase(caseObj.ESA_Approval_Time_Unit__c) ? System.Today().addDays((Integer.valueOf(caseObj.ESA_Approval_Time__c))+1)
                                : NULL;
                    
                }
                else {
                    caseObj.Termination_Date__c = NULL;
                }
            }
            
        }
    }
    
/**
* @author: Rahul
* @date: 9 Dec 2023
* @description: The purpose of this method is to manage the case assignment in case of inline edit
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/  
    public static void manageAssignmentRule(List<Case> cases, Map<Id, Case> oldCaseMap){
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.useDefaultRule = true;
        List<Case> caseAssignment = new List<Case>();
        For(Case newCase :[Select Id,OwnerId, Status FROM Case WHERE Id in :cases]){
            if(newCase.OwnerId == oldCaseMap.get(newCase.Id).OwnerId && newCase.status != oldCaseMap.get(newCase.Id).Status){
                newCase.setOptions(dmlOpts);
                caseAssignment.add(newCase);
            }
        }
        update caseAssignment;
    }

/**
* @author: Deepak
* @date: 04 Dec 2023
* @description: The purpose of this method is to Change case status according to RPH, SC, AC Review Field
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/ 
    
    public static void assignStatus(Map<id,Case> oldCaseMap, Map<id,Case> newCaseMap){
        for(Case caseObj: newCaseMap.values()){
            Boolean isRPHReviewChanged = oldCaseMap.get(caseObj.id).EDRD_RPH_Review_Pathway__c != newCaseMap.get(caseObj.id).EDRD_RPH_Review_Pathway__c;
            Boolean isSCReviewChanged = oldCaseMap.get(caseObj.id).EDRD_SC_Review_Pathway__c != newCaseMap.get(caseObj.id).EDRD_SC_Review_Pathway__c;
            Boolean isACReviewChanged = oldCaseMap.get(caseObj.id).EDRD_AC_Review_Pathway__c != newCaseMap.get(caseObj.id).EDRD_AC_Review_Pathway__c;
            if((isRPHReviewChanged && isSCReviewChanged) || (isSCReviewChanged && isACReviewChanged) || (isRPHReviewChanged && isACReviewChanged)){
                caseobj.addError(Label.EDRD_label_pathwayValidationErrorMsg);
            }
            
            if(isRPHReviewChanged && !String.isEmpty(caseObj.EDRD_RPH_Review_Pathway__c)){
                caseObj.Status = returnStatus(caseObj.EDRD_RPH_Review_Pathway__c);
            }else if(isSCReviewChanged && !String.isEmpty(caseObj.EDRD_SC_Review_Pathway__c)){
                caseObj.Status = returnStatus(caseObj.EDRD_SC_Review_Pathway__c);
            }else if(isACReviewChanged && !String.isEmpty(caseObj.EDRD_AC_Review_Pathway__c)){
                caseObj.Status = returnStatus(caseObj.EDRD_AC_Review_Pathway__c);
            }
        }
    }
    
    private static String returnStatus(String reviewPathWay){
        String status = '';
        if(reviewPathWay == 'Sent to SC'){
            status = 'SC Review';
        }else if(reviewPathWay == 'Sent to AC'){
            status = 'AC Review';
        }else if(reviewPathWay == 'Sent to MOH'){
            status = 'MOH Review';
        }
        return status;
    }
    
/**
* @author: Deepak
* @date: 15 Dec 2023
* @description: The purpose of this method is to Sync case field values with Medication Request.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/ 
    public static void syncCaseToMR(Map<id,Case> oldCaseMap, Map<id,Case> newCaseMap){
        List<MedicationRequest> MRListToUpdate = new List<MedicationRequest>();
        Set<String> caseStatusValueSet = new Set<String>{'Received - Awaiting Verification', 'SC Review', 'AC Review', 'MOH Review'};
        Set<Id> caseIdSet = new Set<Id>();
        Id recordTypeCaseEDRD = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('EDRD').getRecordTypeId();
        for(Case caseObj: newCaseMap.values()){
            Boolean isStatusChanged = oldCaseMap.get(caseObj.id).Status != newCaseMap.get(caseObj.id).Status;
            Boolean isProrityChanged = oldCaseMap.get(caseObj.id).Priority != newCaseMap.get(caseObj.id).Priority;
            Boolean isTypeChanged = oldCaseMap.get(caseObj.id).Type != newCaseMap.get(caseObj.id).Type;
            if(caseObj.RecordTypeId == recordTypeCaseEDRD && (isStatusChanged || isProrityChanged || isTypeChanged)){
                caseIdSet.add(caseObj.Id);
            }
        }
        for(MedicationRequest MRObj:[SELECT Id, Case__r.Type, Case__r.Status, Case__r.Priority FROM MedicationRequest WHERE Case__c IN: caseIdSet]){
            MRObj.Status = caseStatusValueSet.Contains(MRObj.Case__r.Status) ? 'Active' : MRObj.Case__r.Status;
            MRObj.Type = MRObj.Case__r.Type;
            MRObj.Priority = MRObj.Case__r.Priority;
            MRListToUpdate.add(MRObj);
        }
        
        if(!MRListToUpdate.isEmpty()){
            Update MRListToUpdate;
        }
    }

/**
* @author: Deepak
* @date: 09 Jan 2024
* @description: The purpose of this method is to calculate DrugForecast on Case.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/    
    public static void calDrugForecast(Map<id,Case> oldCaseMap, Map<id,Case> newCaseMap){
        Map<Id, case> caseIdVsRec = new Map<Id, case>();
        for(Case caseObj: newCaseMap.values()){
            Boolean isInputFieldsChanged = (newCaseMap.get(caseObj.Id).EDRD_MOHApproved_Dosage__c != oldCaseMap.get(caseObj.Id).EDRD_MOHApproved_Dosage__c ||
                                            newCaseMap.get(caseObj.Id).EDRD_MOHApproved_Dosage_Unit__c != oldCaseMap.get(caseObj.Id).EDRD_MOHApproved_Dosage_Unit__c ||
                                            newCaseMap.get(caseObj.Id).EDRD_MOHApproved_Frequency__c != oldCaseMap.get(caseObj.Id).EDRD_MOHApproved_Frequency__c ||
                                            newCaseMap.get(caseObj.Id).EDRD_MOHApproved_Frequency_Unit__c != oldCaseMap.get(caseObj.Id).EDRD_MOHApproved_Frequency_Unit__c ||
                                            newCaseMap.get(caseObj.Id).EDRD_MOHApproved_Funding_Duration__c != oldCaseMap.get(caseObj.Id).EDRD_MOHApproved_Funding_Duration__c ||
                                            newCaseMap.get(caseObj.Id).EDRD_MOHApproved_Funding_Duration_Unit__c != oldCaseMap.get(caseObj.Id).EDRD_MOHApproved_Funding_Duration_Unit__c);
            caseIdVsRec.put(CaseObj.id, caseObj);
        }
        Map<Id, Decimal> caseIdVsForcastAmnt = medicationRequestTriggerHandler.calDrugForecastOnCase(caseIdVsRec.KeySet(), caseIdVsRec);
        if(!caseIdVsForcastAmnt.isEmpty()){
            for(Case caseObj: newCaseMap.values()){
                caseObj.EDRD_MOHDrug_Cost_Forecast__c = caseIdVsForcastAmnt.ContainsKey(caseObj.Id) ? caseIdVsForcastAmnt.get(caseObj.Id) : NULL;
            }  
        }
    } 
    
/**
* @author: Deepak
* @date: 15 Jan 2024
* @description: The purpose of this method is to Update AC Recommendation Review.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/  
    public static void assignACRecReview(Map<id,Case> oldCaseMap, Map<id,Case> newCaseMap){
        Set<String> caseSCReviewValueSet = new Set<String>{'Sent to MOH'};
        Id recordTypeCaseEDRD = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('EDRD').getRecordTypeId();
        for(Case caseObj: newCaseMap.values()){
            Boolean isSCReviewChanged = oldCaseMap.get(caseObj.id).EDRD_SC_Review_Pathway__c != newCaseMap.get(caseObj.id).EDRD_SC_Review_Pathway__c;
            
            if(recordTypeCaseEDRD == caseObj.RecordTypeId && isSCReviewChanged && caseSCReviewValueSet.Contains(caseObj.EDRD_SC_Review_Pathway__c)){
                caseObj.EDRD_AC_Recommendation_Review__c = 'Not Applicable';
            }else if(recordTypeCaseEDRD == caseObj.RecordTypeId && isSCReviewChanged && !String.isEmpty(caseObj.EDRD_SC_Review_Pathway__c)){
                caseObj.EDRD_AC_Recommendation_Review__c = NULL;
            }
        }
    }
    
/**
* @author: Rahul
* @date: 19 Jan 2024
* @description: The purpose to Update Funding Expiry and Extension dates
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/  
    public static void calculateFundingExpiryDate(List<Case> cases, Map<Id, Case> oldCaseMap){
        for(Case caseObj : cases){
            if(caseObj.EDRD_MOHFunding_Decision__c != null && caseObj.EDRD_MOHFunding_Decision__c != 'Denied'){
                Boolean updateExpiryDate = (caseObj.EDRD_MOHFunding_Start_Date__c != null || caseObj.EDRD_MOHFunding_Extension_Date__c!= null) && 
                    caseObj.EDRD_MOHApproved_Funding_Duration__c != null &&
                    caseObj.EDRD_MOHApproved_Funding_Duration_Unit__c!= null &&
                    (caseObj.EDRD_MOHFunding_Decision__c == 'Approved' || caseObj.EDRD_MOHFunding_Decision__c == 'Extended');
                Boolean isStartDateChanged = false;
                Boolean isEndDateChanged = false;
                if(trigger.isUpdate && updateExpiryDate){
                    isEndDateChanged = (caseObj.EDRD_MOHFunding_Expiry_Date__c != oldCaseMap.get(caseObj.id).EDRD_MOHFunding_Expiry_Date__c) ||
                        (caseObj.EDRD_MOHFunding_Extension_Date__c != oldCaseMap.get(caseObj.id).EDRD_MOHFunding_Extension_Date__c);
                    isStartDateChanged = (caseObj.EDRD_MOHFunding_Start_Date__c != oldCaseMap.get(caseObj.id).EDRD_MOHFunding_Start_Date__c);
                }
                if(trigger.isInsert && updateExpiryDate){
                    isEndDateChanged = caseObj.EDRD_MOHFunding_Expiry_Date__c != null || caseObj.EDRD_MOHFunding_Extension_Date__c != null;
                    isStartDateChanged = caseObj.EDRD_MOHFunding_Start_Date__c != null;
                }
                if(isStartDateChanged && !isEndDateChanged && caseObj.EDRD_MOHIndefinite_Funding__c != null && !caseObj.EDRD_MOHIndefinite_Funding__c){
                    if(caseObj.EDRD_MOHFunding_Decision__c == 'Approved'){
                        caseObj.EDRD_MOHFunding_Expiry_Date__c = populateExpiryDate(caseObj.EDRD_MOHFunding_Start_Date__c,caseObj.EDRD_MOHApproved_Funding_Duration__c,caseObj.EDRD_MOHApproved_Funding_Duration_Unit__c);
                    }else if(caseObj.EDRD_MOHFunding_Decision__c == 'Extended'){
                        caseObj.EDRD_MOHFunding_Extension_Date__c = populateExpiryDate(caseObj.EDRD_MOHFunding_Start_Date__c,Integer.valueOf(caseObj.EDRD_MOHApproved_Funding_Duration__c),caseObj.EDRD_MOHApproved_Funding_Duration_Unit__c);
                    }
                }
                if(caseObj.EDRD_MOHIndefinite_Funding__c){
                    caseObj.EDRD_MOHFunding_Expiry_Date__c = null;
                    caseObj.EDRD_MOHFunding_Extension_Date__c = null;
                }
            }
        }
    }
    public static Date populateExpiryDate(Date startDate, Decimal duration, String unit){
        Date expDate;
        Integer durationRound = Integer.valueOf(duration.round(System.RoundingMode.CEILING));
        if(unit == 'Days'){
            expDate = startDate.addDays(durationRound);
        }else if(unit == 'Weeks'){
            expDate = startDate.addDays(durationRound*7);
        }else if(unit == 'Months'){
            expDate = startDate.addMonths(durationRound);
        }else if(unit == 'Years'){
            expDate = startDate.addYears(durationRound);
        }
        return expDate;
    }
    
/**
* @author: Suman
* @date: 18 Jan 2024
* @description: The purpose of this method is to check Eligibility form signed date and to throw Validation.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/
    public static void validateAttachmentForMOHReview(List<Case> newCases, Map<Id, Case> oldCaseMap) {
        try{
            Set<Id> caseIds = new Set<Id>();
            for (Case caseObj : newCases){
                caseIds.add(caseObj.id);
            }
            Map<Id, Integer> caseIdToAttachmentCount = new Map<Id, Integer>();
            for (AggregateResult result : [
                SELECT LinkedEntityId, COUNT(Id) attachmentCount
                FROM ContentDocumentLink
                WHERE LinkedEntityId IN :caseIds
                GROUP BY LinkedEntityId
            ]) {
                caseIdToAttachmentCount.put((Id) result.get('LinkedEntityId'), (Integer) result.get('attachmentCount'));
            }
            for (Case caseObj : newCases) {
                if(!caseObj.EDRD_Bypass_Eligibility_Form__c){
                    Integer attachmentCount = caseIdToAttachmentCount.get(caseObj.Id) != null ? caseIdToAttachmentCount.get(caseObj.Id) : 0;
                    if (oldCaseMap.containsKey(caseObj.Id)){
                        Boolean isStatusChanging = (oldCaseMap.get(caseObj.Id).Status == 'Received - Awaiting Verification' || oldCaseMap.get(caseObj.Id).Status == 'SC Review'
                                                    || oldCaseMap.get(caseObj.Id).Status == 'AC Review' || oldCaseMap.get(caseObj.Id).Status == 'Received') &&
                            caseObj.Status == 'MOH Review';
                        Boolean isSignedDateInvalid = caseObj.EDRD_Eligibility_Form_Signed_Date__c == null ||
                            caseObj.EDRD_Eligibility_Form_Signed_Date__c < Date.newInstance(2022, 1, 1);
                        Boolean isNoAttachment = attachmentCount == 0;
                        if (isStatusChanging && isNoAttachment) {
                            caseObj.addError(Label.Validation_Error_AttachDocumentMOHReview);
                        }else if (isStatusChanging && isSignedDateInvalid) {
                            caseObj.addError(Label.Validation_Error_EDRDEligibilityFormSignedDate);
                        }
                    }
                }
            }
        }catch (Exception err) {
            System.debug('Exception caught: ' + err.getMessage());
        }
    }
}