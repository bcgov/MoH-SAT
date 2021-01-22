trigger CaseTrigger on Case (after insert, after update) {    
    
    if (Trigger.size == 1) {
        for (Case saCase : Trigger.new) {
            Boolean runEvaluate = !saCase.isClosed && saCase.Drug__c != null;
            
            if (runEvaluate) {
                Boolean setDefaultOwner = 
                    Trigger.isInsert || 
                    (Trigger.isUpdate && Trigger.oldMap.get(saCase.Id).Drug__c == null);

                AdjudicationService.evaluateFuture(saCase.Id, setDefaultOwner);
            }
        }
    }
}