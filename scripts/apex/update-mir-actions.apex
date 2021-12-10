List<Step_Action__c> actions = [
    select id, adjudication_status__c 
    from step_action__c 
    where recordtype.name = 'Adjudication' 
    and adjudication_status__c = 'On Hold - MIR'];

for (Step_Action__c action : actions) {
    action.Adjudication_Status__c = 'MIR';
}

update actions;