/**********************************************************************************************
* @Author:      Vasanthi D 
* @Date:        11 Sep 2023
* @Description: The purpose of this class is to create methods which can be used by different trigger event
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
***********************************************************************************************/
public with sharing class ESA_cls_ExternalCommitteeTriggerHandler {
    public static boolean cloneOpenCases_runsOne = TRUE;
    public static void cloneOpenCases(List<External_Committee__c> newMeetings){
        cloneOpenCases_runsOne = FALSE;
        set<id> parentIds  = new set<id>();
        Map<id,list<Case>> openCaseMap = new  Map<id,list<Case>>();
        for(External_Committee__c ec : newMeetings){
            if(ec.isClone()){
                parentIds.add(ec.getCloneSourceId());
            }
        }     
        List<Case> caseList = new List<Case>([select id,External_Committee__c,Status from Case where External_Committee__c IN:parentIds AND Status  IN ('Received' ,'Under Review') ]);
        //retrieve open cases and form the Map 
        for(Case openCase : caseList){
            if(openCaseMap.get(openCase.External_Committee__c)==null){
                openCaseMap.put(openCase.External_Committee__c,new List<Case>{openCase});
            }
            else{
                List<Case> eclist = openCaseMap.get(openCase.External_Committee__c) ;
                eclist.add(openCase);
                openCaseMap.put(openCase.External_Committee__c,eclist);   
            }
        }     
        List<Case> caselistToUpdate  = new List<Case>();
        for(External_Committee__c ec : newMeetings){
            if(ec.isClone()){
                //get cases related to parent 
                If(openCaseMap.containsKey(ec.getCloneSourceId()) && openCaseMap.get(ec.getCloneSourceId()) != NULL){
                    for(Case rec : openCaseMap.get(ec.getCloneSourceId())){
                        rec.External_Committee__c = ec.Id;
                        caselistToUpdate.add(rec);
                    } 
                }
            }
        }
        if(!caselistToUpdate.isEmpty()){
           Update caselistToUpdate;
        }
    }
    
    public static void validateBeforeClone(List<External_Committee__c> newMeetings){      
       set<id> parentIds  = new set<id>();
        for(External_Committee__c ec : newMeetings){
            if(ec.isClone()){
                parentIds.add(ec.getCloneSourceId());
            }
        }       
        Map<id,External_Committee__c> parentECMap = new Map<id,External_Committee__c>([Select id, External_Committee_Type__c from External_Committee__c Where id =: parentIds]);      
        for(External_Committee__c ec : newMeetings){
            if(parentECMap.get(ec.getCloneSourceId()) !=null && parentECMap.get(ec.getCloneSourceId()).External_Committee_Type__c != ec.External_Committee_Type__c){
               ec.addError( System.Label.ESA_CL_ExternalCommitteTypeError);
            }
        }       
    }    
}