/**********************************************************************************************
* @Author:      Vasanthi D 
* @Date:        11 Sep 2023
* @Description: The purpose of this class is to create methods which can be used by different trigger event
***********************************************************************************************/
public with sharing class ESA_cls_ExternalCommitteeTriggerHandler {
    public static boolean cloneOpenCases_runsOne = TRUE;
    public static void cloneOpenCases(List<External_Committee__c> newMeetings){
        cloneOpenCases_runsOne = FALSE;
        Map<id,id> sourceIdVsRecIds  = new Map<id,id>();
        Map<id,List<Case>> openCaseMap = new Map<id,List<Case>>();
        for(External_Committee__c ec : newMeetings){
            if(ec.isClone()){
                sourceIdVsRecIds.put(ec.getCloneSourceId(), ec.id);
            }
        }
        
        List<Case> caseList = new List<Case>([SELECT id,External_Committee__c,Status 
                                              FROM Case 
                                              WHERE External_Committee__c IN: sourceIdVsRecIds.keySet() 
                                              AND Status  IN ('Received' ,'Under Review') ]);
        //retrieve open cases and form the Map 
        for(Case openCase : caseList){
            openCase.External_Committee__c = sourceIdVsRecIds.get(opencase.External_Committee__c);
        }
        
        if(!caseList.isEmpty()){
            Update caseList;
        }
    }
    
    public static void validateBeforeClone(List<External_Committee__c> newMeetings){
        
        Set<id> parentIds  = new Set<id>();
        for(External_Committee__c ec : newMeetings){
            if(ec.isClone()){
                parentIds.add(ec.getCloneSourceId());
            }
        }
        
        Map<id,External_Committee__c> parentECMap = new Map<id,External_Committee__c>([SELECT id, External_Committee_Type__c 
                                                                                       FROM External_Committee__c 
                                                                                       WHERE id =: parentIds]);
        
        for(External_Committee__c ec : newMeetings){
            if(parentECMap != NULL && parentECMap.get(ec.getCloneSourceId()) != NULL && parentECMap.get(ec.getCloneSourceId()).External_Committee_Type__c != ec.External_Committee_Type__c){
                ec.addError( System.Label.ESA_CL_ExternalCommitteTypeError);
            }
        }
    } 
}