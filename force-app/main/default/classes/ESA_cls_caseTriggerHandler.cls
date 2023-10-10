/**********************************************************************************************
* @Author:      Deepak 
* @Date:        23 Feb 2023
* @Description: The purpose of this class is to create methods which can be used by different trigger event
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
***********************************************************************************************/

public with sharing class ESA_cls_caseTriggerHandler {
    
/**
* @author: Deepak
* @date: 23 Feb 2023
* @description: The purpose of this method is to populate termination date based on Approval time/time unit
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/    
    public static void populateTerminationDate(List<Case> newCases, Map<id,Case> oldCaseMap, Map<id,Case> newCaseMap){
        for(Case caseObj:newCases){
            Boolean isInputsChange = trigger.isUpdate && (oldCaseMap.get(caseObj.id).ESA_Approval_Time__c != newCaseMap.get(caseObj.id).ESA_Approval_Time__c ||
                                                          oldCaseMap.get(caseObj.id).ESA_Approval_Time_Unit__c != newCaseMap.get(caseObj.id).ESA_Approval_Time_Unit__c ||
                                                          oldCaseMap.get(caseObj.id).Effective_Date__c != newCaseMap.get(caseObj.id).Effective_Date__c);
            if((trigger.isInsert && caseObj.Termination_Date__c == NULL) || isInputsChange){
                 Date currentEffectiveDate = caseObj.Effective_Date__c!=NULL ? caseObj.Effective_Date__c :  System.Today() ;
                if(caseObj.ESA_Approval_Time__c != NULL && caseObj.ESA_Approval_Time_Unit__c != NULL){
                    caseObj.Termination_Date__c = ESA_cls_constants.CASE_APPROVAL_TIME_UNIT_WEEK.containsIgnoreCase(caseObj.ESA_Approval_Time_Unit__c) ?  currentEffectiveDate.addDays((Integer.valueOf(caseObj.ESA_Approval_Time__c)*7)+1)
                        : ESA_cls_constants.CASE_APPROVAL_TIME_UNIT_MONTH.containsIgnoreCase(caseObj.ESA_Approval_Time_Unit__c) ?  currentEffectiveDate.addMonths(Integer.valueOf(caseObj.ESA_Approval_Time__c)).addDays(1)
                            : ESA_cls_constants.CASE_APPROVAL_TIME_UNIT_DAYS.containsIgnoreCase(caseObj.ESA_Approval_Time_Unit__c) ?  currentEffectiveDate.addDays((Integer.valueOf(caseObj.ESA_Approval_Time__c))+1)
                                : ESA_cls_constants.CASE_APPROVAL_TIME_UNIT_YEARS.containsIgnoreCase(caseObj.ESA_Approval_Time_Unit__c) ? currentEffectiveDate.addYears(Integer.valueOf(caseObj.ESA_Approval_Time__c)).addDays(1)
                                : NULL;
                    
                }
                else {
                    caseObj.Termination_Date__c = NULL;
                }
            }
            
        }
    }
}