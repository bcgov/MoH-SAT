delete [select id from Step_Action__c];
delete [select id from Step__c];

List<Drug__c> drugs = [
    select 
        Id, Criteria_Logic__c, Drug_Code__c,
        (
            select
                Drug__r.Drug_Code__c,Object_Name__c,Field_Name__c,Operator__c,Order__c,Question_ID__c,String_Value__c,Boolean_Value__c
            from Adjudication_Criteria__r
            order by Drug__r.Drug_Code__c, Order__c
        )
    from Drug__c 
    where Id in (select Drug__c from Adjudication_Criteria__c)
];

Map<String, Step__c> steps = new Map<String, Step__c>();

for (Drug__c drug : drugs) {
    Step__c step = new Step__c();
    step.Drug__c = drug.Id;
    step.Order__c = 100;
    step.Title__c = 'Approve Case';
    step.Criteria_Logic__c = drug.Criteria_Logic__c;
    steps.put(drug.Drug_Code__c, step);
}

insert steps.values();

List<Step_Criteria__c> criterias = new List<Step_Criteria__c>();
List<Step_Action__c> actions = new List<Step_Action__c>();

for (Drug__c drug : drugs){
    
    for (Adjudication_Criteria__c ac : drug.Adjudication_Criteria__r) {
        Step_Criteria__c sc = new Step_Criteria__c();
        sc.Step__c = steps.get(drug.Drug_Code__c).Id;
        sc.Order__c = ac.Order__c;
        sc.Object_Name__c = ac.Object_Name__c;
        sc.Field_Name__c = ac.Field_Name__c;
        sc.Operator__c = ac.Operator__c;
        sc.Question_ID__c = ac.Question_ID__c;
        sc.String_Value__c = ac.String_Value__c;
        criterias.add(sc);
    }

    Step_Action__c action = new Step_Action__c();
    action.Step__c = steps.get(drug.Drug_Code__c).Id;
    action.RecordTypeId = SchemaUtil.getRecordTypeInfosByDeveloperName('Step_Action__c', 'Adjudication').getRecordTypeId();
    action.Order__c = 100;
    action.Adjudication_Status__c = 'Approved';
    actions.add(action);
}

insert actions;
insert criterias;