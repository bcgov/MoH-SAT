List<Step__c> steps = [select id, order__c from step__c where order__c not in (100, 200, 300)];

for (Step__c step : steps) {
    step.Order__c *= 100;
}

update steps;

Id urgentQueueId = [select Id from Group where DeveloperName = 'Urgent']?.Id;

Step__c stepUrgentTemplate = new Step__c();
stepUrgentTemplate.Order__c = 50;
stepUrgentTemplate.Name = 'Assign to Urgent if Phone';
stepUrgentTemplate.Criteria_Logic__c = 'AND(1)';
stepUrgentTemplate.Description__c = 'Assigns the case to the urgent queue if its origin is phone.';

Step_Criteria__c stepUrgentCriteriaTemplate = new Step_Criteria__c();
stepUrgentCriteriaTemplate.Order__c = 1;
stepUrgentCriteriaTemplate.Object_Name__c = 'Case';
stepUrgentCriteriaTemplate.Field_Name__c = 'Origin';
stepUrgentCriteriaTemplate.Operator__c = 'equals';
stepUrgentCriteriaTemplate.String_Value__c = 'Phone';

Step_Action__c stepUrgentActionTemplate = new Step_Action__c();
stepUrgentActionTemplate.Order__c = 100;
stepUrgentActionTemplate.RecordTypeId = SchemaUtil.getRecordTypeInfosByDeveloperName('Step_Action__c', 'Owner_Assignment').getRecordTypeId();
stepUrgentActionTemplate.OwnerId = urgentQueueId;

List<Step__c> newsteps = new List<Step__c>();
List<Step_Criteria__c> newcriteria = new List<Step_Criteria__c>();
List<Step_Action__c> newactions = new List<Step_Action__c>();

for (Drug__c drug : [select Id from Drug__c]) {
    Step__c step = stepUrgentTemplate.clone(false, true, false, false);
    step.Drug__c = drug.Id;
    newsteps.add( step );
}
insert newsteps;

for (Step__c step:newsteps) {
    Step_Criteria__c stepCriteria = stepUrgentCriteriaTemplate.clone(false, true, false, false);
    Step_Action__c stepAction = stepUrgentActionTemplate.clone(false, true, false, false);

    stepCriteria.Step__c = step.Id;
    stepAction.Step__c = step.Id;

    newcriteria.add(stepCriteria);
    newactions.add(stepAction);
}

insert newcriteria;
insert newactions;