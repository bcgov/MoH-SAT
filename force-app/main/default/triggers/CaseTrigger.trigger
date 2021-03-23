trigger CaseTrigger on Case (after insert) {    
    
    if (SaSettings.triggersEnabled() && Trigger.size == 1) {
        for (Case saCase : Trigger.new) {
            Boolean runEvaluate = !saCase.isClosed && saCase.Drug__c != null;
            
            if (runEvaluate) {
                AdjudicationService.evaluateFuture(saCase.Id, true);
            }
        }
    }
}