public virtual with sharing class AdjudicationStrategy {
    public class AdjudicationException extends Exception {}

    public SpecialAuthorityRequest sar { get; private set; }

    public Drug__c drug { get; private set; }

    public AdjudicationStrategy(SpecialAuthorityRequest sar) {
        this.sar = sar;
        this.drug = sar.hasDrug() ? queryDrug(sar.drug.Id) : null;
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
        runAction(drug.Pre_Adjudication_Apex__c);

        onBeforeEvaluate();
    }
    
    private void runAction(String className) {
        if (String.isBlank(className)) return;

        Type actionType = Type.forName(className);
        
        if (actionType != null) {
            ((AdjudicationAction) actionType.newInstance()).execute(sar);
        }
    }

    /**
     * Base handler for events that execute after adjudication evaluation. 
     */
    public virtual void handleAfterEvaluation() {
        runAction(drug.Post_Adjudication_Apex__c);

        onAfterEvaluate();
    }

    public virtual void onBeforeEvaluate() {} 
    
    public virtual void onAfterEvaluate() {}

    public virtual void evaluate() {}

    private Drug__c queryDrug(Id drugId) {
        return [
            select Id, Pre_Adjudication_Apex__c, Post_Adjudication_Apex__c, Criteria_Logic__c, (
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
}
