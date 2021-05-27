public with sharing class AdjudicationStrategy {
    public class AdjudicationException extends Exception {}

    public SpecialAuthorityRequest sar { get; private set; }

    public Boolean autoValidatePatient { get; private set; }
    public Boolean autoValidateProvider { get; private set; }
    public Boolean autoPushToPharmanet { get; private set; }
    public Boolean assignOwner { get; private set; }
    public List<Step> steps { get; private set; }

    public AdjudicationStrategy(SpecialAuthorityRequest sar, Boolean assignOwner) {
        this.sar = sar;
        this.assignOwner = assignOwner;
        this.autoValidatePatient = sar.hasDrug() ? sar.drug.Auto_Validate_Patient__c : false;
        this.autoValidateProvider = sar.hasDrug() ? sar.drug.Auto_Validate_Provider__c : false;
        this.autoPushToPharmanet= sar.hasDrug() ? sar.drug.Auto_Push_to_Pharmanet__c : false;
        this.steps = new List<Step>();
    }

    public void runEvaluate() {
        if (!sar.hasDrug() || sar.saCase.isClosed) return;
        
        onBeforeEvaluate();
        evaluate();
        onAfterEvaluate();
        print();
    }

    public void onBeforeEvaluate() {
        run(StepBuilder.buildOwnerAssignmentStep(sar.getDefaultOwnerId()));
        
        if (this.autoValidatePatient) {
            run(StepBuilder.buildPatientValidatorStep());
        }

        if (this.autoValidateProvider) {
            run(StepBuilder.buildProviderValidationStep());
        }
    }

    public void evaluate() {
        if (!sar.hasDrug()) return;

        for (Step step : StepBuilder.build(querySteps(sar.drug.Id))) {
            run(step);
        }
    }

    public void onAfterEvaluate() {
        if (this.autoPushToPharmanet) {
            run(StepBuilder.buildPharmanetSubmissionStep());
        }
    }

    private void run(Step step) {
        steps.add(step);

        if (!step.executable(sar.saCase, sar.requestDetails)) return;

        for (StepAction action : step.actions) {
            if (action.isOwnerAssignment() && !this.assignOwner) continue;
            
            action.run(sar);
        }
    }
    
    public void print() {
        List<String> results = new List<String>();
        for (Step step : steps) {
            Boolean executed = step.alwaysRun || step.criteriaResult;
            List<String> actionResults = new List<String>();
            
            if (executed) {
                for (StepAction action : step.actions) {
                    actionResults.add(String.format(
                        '\tAction: {0}, Executed: {1}', new String[] {
                            action.actionType.name(),
                            String.valueOf(action.executed)
                    }));
                }
            }

            results.add(String.format(
                'Step: "{0}", Executed: {1}{2}', new String[] {
                    step.title,
                    String.valueOf(executed),
                    executed ? '\n' + String.join(actionResults, '\n') : ''
            }));
        }
        String printResult = '\n'+String.join(results, '\n');
        system.debug(LoggingLevel.INFO, printResult);
        
        if (!Test.isRunningTest()) ConnectApi.ChatterFeeds.postFeedElement(null, sar.saCase.Id, ConnectApi.FeedElementType.FeedItem, printResult);
    }
    
    private List<Step__c> querySteps(Id drugId) {
        return [
            select
                Id, Name, External_ID__c, Order__c, Always_Run__c, Criteria_Logic__c, 
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
