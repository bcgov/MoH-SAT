trigger CaseTrigger on Case (before insert, before update) {    
    
    if (Trigger.size == 1) {
        for (Case saCase : Trigger.new) {
            Boolean runEvaluate = !saCase.isClosed && saCase.Drug__c != null;
            
            if (runEvaluate) {
                Boolean setDefaultOwner = 
                    Trigger.isInsert || 
                    (Trigger.isUpdate && Trigger.oldMap.get(saCase.Id).Drug__c == null);

                AdjudicationService.evaluate(saCase, setDefaultOwner);
            }
        }
    }
}