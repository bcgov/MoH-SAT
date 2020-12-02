trigger CaseTrigger on Case (before insert, before update) {    
    
    if (Trigger.new.size() == 1) {
        for (Case saCase : Trigger.new) {
            Boolean runEvaluate = !saCase.isClosed && saCase.Drug__c != null;
            
            if (runEvaluate) {
                AdjudicationService.evaluate(saCase);
            }
        }
    }
}