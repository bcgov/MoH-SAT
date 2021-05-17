public virtual with sharing class AdjudicationStrategy {
    public class AdjudicationException extends Exception {}

    public SpecialAuthorityRequest sar { get; private set; }

    public Drug__c drug { get; private set; }
    public List<Step__c> steps { get; private set; }

    public AdjudicationStrategy(SpecialAuthorityRequest sar) {
        this.sar = sar;
        this.drug = sar.hasDrug() ? queryDrug(sar.drug.Id) : null;
        this.steps = sar.hasDrug() ? querySteps(sar.drug.Id) : new List<Step__c>();
    }

    public virtual void runEvaluate() {
        if (this.drug == null || sar.saCase.isClosed) return;
        
        handleBeforeEvaluation();
        evaluate();
        handleAfterEvaluation();
    }

    /**
     * Base handler for events that execute before adjudication evaluation. 
     */
    public virtual void handleBeforeEvaluation() {
        if (drug.Auto_Validate_Patient__c) {
            runAction(PatientValidator.class); 
        }

        if (drug.Auto_Validate_Provider__c) {
            runAction(ProviderValidator.class); 
        }

        onBeforeEvaluate();
    }

    /**
     * Base handler for events that execute after adjudication evaluation. 
     */
    public virtual void handleAfterEvaluation() {
        onAfterEvaluate();
        
        if (drug.Auto_Push_To_Pharmanet__c) {
            runAction(SAPush.class);
        }
    }

    public virtual void onBeforeEvaluate() {
        List<Step> steps = StepBuilder.build(this.steps);
        system.debug(steps);

        for (Step step : steps) {
            if (!(step.alwaysRun || step.evaluate(sar.saCase, sar.requestDetails))) break;
        
            for (StepAction action : step.actions) {
                Type apexType = null;
                if (action.actionType == StepAction.ActionType.OWNER_ASSIGNMENT) {
                    apexType = OwnerAssignment.class;
                } else if (action.actionType == StepAction.ActionType.ADJUDICATION) {
                    apexType = Adjudication.class;
                } else if (action.actionType == StepAction.ActionType.PHARMANET_DEFAULTS) {
                    apexType = PharmanetDefaults.class;
                }
                runAction(apexType.getName(), action);
            }
        }
    } 
    
    public virtual void onAfterEvaluate() {}

    public virtual void evaluate() {}

    private void runAction(System.Type apexType) {
        runAction(apexType.getName(), null);
    }

    private void runAction(String className, StepAction actionParams) {
        if (String.isBlank(className)) return;

        Type actionType = Type.forName(className);
        
        if (actionType != null) {
            ((AdjudicationAction) actionType.newInstance()).execute(sar, actionParams);
        }
    }

    private Drug__c queryDrug(Id drugId) {
        return [
            select 
                Id, Criteria_Logic__c, Auto_Validate_Patient__c, Auto_Validate_Provider__c, Auto_Push_to_Pharmanet__c,
                (
                    select 
                        Order__c, Object_Name__c, Field_Name__c, Question_ID__c, Operator__c,
                        String_Value__c, Boolean_Value__c, Decimal_Value__c, Date_Value__c, Datetime_Value__c
                    from Adjudication_Criteria__r
                    order by Order__c asc 
                )            
            from Drug__c 
            where Id = :drugId
        ];
    }

    private List<Step__c> querySteps(Id drugId) {
        return [
            select
                Id, Order__c, Always_Run__c, Criteria_Logic__c, 
                (
                    select 
                        Order__c, Object_Name__c, Field_Name__c, Question_ID__c, Operator__c,
                        String_Value__c, Boolean_Value__c, Decimal_Value__c, Date_Value__c, Datetime_Value__c
                    from Step_Criteria__r
                    order by Order__c asc
                ),
                (
                    select 
                        Order__c, OwnerId, RecordTypeId,
                        Adjudication_Status__c, Days_Supply__c, Excluded_Plans__c, Justification_Codes__c, 
                        Key_Type__c, Pharmanet_Code__c, Price_Percent__c, SA_Type__c,
                        Duration__c, Duration_Unit__c
                    from Step_Actions__r
                    order by Order__c asc
                )
            from Step__c
            where Drug__c = :drugId
            order by Order__c asc
        ];
    }
}
