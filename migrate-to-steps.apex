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
        ),
        (
            select
                Days_Supply__c, Excluded_Plans__c, Justification_Codes__c, 
                Key_Type__c, Pharmanet_Code__c, Price_Percent__c, SA_Type__c,
                Duration__c, Duration_Unit__c 
            from Drug_Templates__r
        )
    from Drug__c 
    where Id in (select Drug__c from Adjudication_Criteria__c)
];

Map<String, Step__c> stepsMap = new Map<String, Step__c>();
for (Drug__c drug : drugs) {
    Step__c step = new Step__c();
    step.Drug__c = drug.Id;
    step.Order__c = 100;
    step.Name = 'Approve Case';
    step.External_ID__c = Steps.formatExternalId(drug.Drug_Code__c, step.Order__c.intValue(), step.Name);
    step.Criteria_Logic__c = drug.Criteria_Logic__c;
    stepsMap.put(drug.Drug_Code__c, step);
}
insert stepsMap.values();

List<Step_Criteria__c> criterias = new List<Step_Criteria__c>();
List<Step_Action__c> actions = new List<Step_Action__c>();
for (Drug__c drug : drugs){    
    for (Adjudication_Criteria__c ac : drug.Adjudication_Criteria__r) {
        Step_Criteria__c sc = new Step_Criteria__c();
        sc.Step__c = stepsMap.get(drug.Drug_Code__c).Id;
        sc.Order__c = ac.Order__c;
        sc.Object_Name__c = ac.Object_Name__c;
        sc.Field_Name__c = ac.Field_Name__c;
        sc.Operator__c = ac.Operator__c;
        sc.Question_ID__c = ac.Question_ID__c;
        sc.String_Value__c = ac.String_Value__c;
        criterias.add(sc);
    }

    Step_Action__c action = new Step_Action__c();
    action.Step__c = stepsMap.get(drug.Drug_Code__c).Id;
    action.RecordTypeId = SchemaUtil.getRecordTypeInfosByDeveloperName('Step_Action__c', 'Adjudication').getRecordTypeId();
    action.Order__c = 100;
    action.Adjudication_Status__c = 'Approved';
    actions.add(action);
}

insert actions;
insert criterias;

stepsMap = new Map<String, Step__c>();
for (Drug__c drug : drugs) {
    Step__c step = new Step__c();
    step.Drug__c = drug.Id;
    step.Order__c = 200;
    step.Name = 'Pharmanet Payload if Approved';
    step.External_ID__c = Steps.formatExternalId(drug.Drug_Code__c, step.Order__c.intValue(), step.Name);
    step.Criteria_Logic__c = 'AND(1)';
    stepsMap.put(drug.Drug_Code__c, step);
}
insert stepsMap.values();

criterias = new List<Step_Criteria__c>();
actions = new List<Step_Action__c>();

for (Drug__c drug : drugs){  
    Step__c step = stepsMap.get(drug.Drug_Code__c);

    Step_Criteria__c sc = new Step_Criteria__c();
    sc.Step__c = step.Id;
    sc.Order__c = 1;
    sc.Object_Name__c = 'Case';
    sc.Field_Name__c = 'Status';
    sc.Operator__c = 'equals';
    sc.Question_ID__c = null;
    sc.String_Value__c = 'Approved';
    criterias.add(sc);

    Integer i = 1;
    for (Drug_Template__c dt : drug.Drug_Templates__r) { 
        Step_Action__c action = new Step_Action__c();
        action.Step__c = step.Id;
        action.Order__c = 100*(i++);
        action.RecordTypeId = SchemaUtil.getRecordTypeInfosByDeveloperName('Step_Action__c', 'Pharmanet_Payload').getRecordTypeId();
        action.Days_Supply__c = dt.Days_Supply__c;
        action.Excluded_Plans__c = dt.Excluded_Plans__c;
        action.Justification_Codes__c = dt.Justification_Codes__c;
        action.Key_Type__c = dt.Key_Type__c;
        action.Pharmanet_Code__c = dt.Pharmanet_Code__c;
        action.Price_Percent__c = dt.Price_Percent__c;
        action.SA_Type__c = dt.SA_Type__c;
        action.Duration__c = dt.Duration__c;
        action.Duration_Unit__c = dt.Duration_Unit__c;
        actions.add(action);  
    }    
}

insert actions;
insert criterias;