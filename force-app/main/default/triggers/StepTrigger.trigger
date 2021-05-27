trigger StepTrigger on Step__c (before insert, before update) {
    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isBefore)) {
        new Steps(Trigger.new).setExternalIds();
    }
}