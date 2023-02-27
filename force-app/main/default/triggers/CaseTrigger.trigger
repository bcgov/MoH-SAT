trigger CaseTrigger on Case (before insert, before update, after insert) {    
    
    if (SaSettings.triggersEnabled() && Trigger.size == 1) {
        for (Case saCase : Trigger.new) {
            Boolean runEvaluate = !saCase.isClosed && saCase.Drug__c != null;
            
            if (runEvaluate) {
                AdjudicationService.evaluateFuture(saCase.Id, true);
            }
        }
    }
    
    if(trigger.isBefore){
        if(trigger.isInsert){
            ESA_cls_caseTriggerHandler.populateTerminationDate(trigger.new, NULL, NULL);
        }
        if(trigger.isUpdate){
            ESA_cls_caseTriggerHandler.populateTerminationDate(trigger.new, trigger.oldMap, trigger.newMap);
        }
    }
    
}