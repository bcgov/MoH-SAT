/**********************************************************************************************
* @Author:       
* @Date:        
* @Description: The purpose of this Trigger is to trigger on particular events
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
                23 Feb -  ESA- 1835         -  Accenture   -  Populate Termination Date on Case
                04 Dec -  EDRD-332          -  Accenture   -  Change Case Status on EDRD
***********************************************************************************************/
trigger CaseTrigger on Case (before insert, before update, after insert, after update) {    
    
    if (Trigger.isAfter && Trigger.isInsert){
        if (SaSettings.triggersEnabled() && Trigger.size == 1) {
            for (Case saCase : Trigger.new) {
                Boolean runEvaluate = !saCase.isClosed && saCase.Drug__c != null;
                
                if (runEvaluate) {
                    System.debug('!!!saCase.Id'+ saCase.Id);
                    AdjudicationService.evaluateFuture(saCase.Id, true);
                }
            }
        }
    }
    
    if(trigger.isBefore){
        if(trigger.isInsert){
             ESA_cls_caseTriggerHandler.populateTerminationDate(trigger.new, NULL, NULL);
        }
        if(trigger.isUpdate){
             ESA_cls_caseTriggerHandler.populateTerminationDate(trigger.new, trigger.oldMap, trigger.newMap);
             ESA_cls_caseTriggerHandler.assignStatus(trigger.oldMap, trigger.newMap);            
        }
    }
    
}