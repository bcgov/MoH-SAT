/**********************************************************************************************
* @Author:      Deepak 
* @Date:        23 Feb 2023
* @Description: The purpose of this class is to create methods which can be used by different trigger event
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description] 
               1 Dec23 -   EDRD-170         -   Rahul      -  Manage case assignment
               4 Dec23 -   EDRD-332         -  Accenture   -  Change case status according to RPH, SC, AC Review Field
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
        AssignmentRule[] AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
        if(AR!= null && !AR.isEmpty()){
            Database.DMLOptions dmlOpts = new Database.DMLOptions();
            dmlOpts.assignmentRuleHeader.assignmentRuleId= AR[0].id;
            List<Case> caseAssignment = new List<Case>();
            For(Case c :[Select Id,OwnerId FROM Case WHERE Id in :cases]){
                if(c.OwnerId == oldCaseMap.get(c.Id).OwnerId){
                    c.setOptions(dmlOpts);
                    caseAssignment.add(c);
                }
            }
            update caseAssignment;
        }
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
}