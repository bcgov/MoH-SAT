trigger CaseTrigger on Case (before insert, before update, after insert) {    
    
    if (Trigger.isAfter && Trigger.isInsert){
        if (SaSettings.triggersEnabled() && Trigger.size == 1) {
            for (Case saCase : Trigger.new) {
                Boolean runEvaluate = !saCase.isClosed && saCase.Drug__c != null;

                //Filtering the case based on record type for SA Request
                if (runEvaluate && saCase.Record_Type_Name__c == 'Special_Authority_Request') {
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
        }
    }
    
}