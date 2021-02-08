trigger RequestDetailTrigger on Request_Detail__c (after insert, after update) {
    
    Set<Id> caseIds = new Set<Id>();

    for (Request_Detail__c rd : trigger.new) {
        caseIds.add(rd.Case__c);
    }

    if (SaSettings.triggersEnabled() && caseIds.size() == 1) {
        for (Id caseId : caseIds) {
            AdjudicationService.evaluateFuture(caseId, false);
        }
    }
}