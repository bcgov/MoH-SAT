trigger CaseTrigger on Case (before insert, before update, after insert) {    
    
    if (Trigger.isAfter && Trigger.isInsert){
        if (SaSettings.triggersEnabled() && Trigger.size == 1) {
            for (Case saCase : Trigger.new) {
                System.debug('!!!saCase.RecordType.Name'+saCase.Record_Type_Name__c);
                Boolean runEvaluate = !saCase.isClosed && saCase.Drug__c != null;
                
                if (runEvaluate && saCase.Record_Type_Name__c == 'Special_Authority_Request') {
                    System.debug('!!!saCase.Id'+ saCase.Id);
                    System.debug('!!!saCase.RecordType.Name'+saCase.RecordType.Name);
                    AdjudicationService.evaluateFuture(saCase.Id, true);
                }
            }
        }
    }
    
    if(trigger.isBefore){
                
        if(trigger.isInsert){
            List<Case> newSaCaseList = new List<Case>();
            for (Case saCase : Trigger.new) {
                if(saCase.Record_Type_Name__c == 'Special_Authority_Request'){
                    newSaCaseList.add(saCase);
                }
            }
            if(newSaCaseList.size()>0){
                ESA_cls_caseTriggerHandler.populateTerminationDate(newSaCaseList, NULL, NULL);
            }
        }
        if(trigger.isUpdate){
            List<Case> newSaCaseList = new List<Case>();
            Map<Id,Case> newSaCaseMap = new Map<Id,Case>();
            Map<Id,Case> oldSaCaseMap = new Map<Id,Case>();
            for (Case saCase : Trigger.new) {
                if(saCase.Record_Type_Name__c == 'Special_Authority_Request'){
                    newSaCaseList.add(saCase);
                    newSaCaseMap.put(saCase.Id,trigger.newMap.get(saCase.Id));
                    oldSaCAseMap.put(saCase.Id,trigger.oldMap.get(saCase.Id));
                }
            }
            if(newSaCaseList.size()>0){
                ESA_cls_caseTriggerHandler.populateTerminationDate(newSaCaseList, oldSaCaseMap, newSaCaseMap);
            }
        }
    }
    
}