trigger CaseTrigger on Case (before insert, before update) {    
    
    if (Trigger.new.size() == 1) {
        Case saCase = Trigger.new[0];
        Boolean runEvaluate = !saCase.isClosed && saCase.Drug__c != null;
        
        if (runEvaluate) {
            AdjudicationService.evaluate(saCase);
        }
    }
}