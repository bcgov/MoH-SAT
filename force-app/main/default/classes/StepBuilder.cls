public with sharing class StepBuilder {
    public static List<Step> build(List<Step__c> records) {
        List<Step> objs = new List<Step>();
        for (Step__c record : records) {
            objs.add(build(record));
        }
        return objs;
    }

    public static Step build(Step__c record) {
        return new Step(
            record.Order__c.intValue(),
            record.Title__c,
            record.Always_Run__c,
            record.Criteria_Logic__c,
            build(record.Step_Criteria__r),
            build(record.Step_Actions__r)
        );
    }

    public static List<StepCriteria> build(List<Step_Criteria__c> records) {
        List<StepCriteria> objs = new List<StepCriteria>();
        for (Step_Criteria__c record : records) {
            objs.add(new StepCriteria(record));
        }
        return objs;
    }

    public static List<StepAction> build(List<Step_Action__c> records) {
        List<StepAction> objs = new List<StepAction>();
        for (Step_Action__c record : records) {
            objs.add(new StepAction(record));
        }
        return objs;
    }

    public static Step buildProviderValidationStep() {
        Step step = new Step('Auto Validate Provider');
        step.actions.add(new StepAction(StepAction.ActionType.PROVIDER_VALIDATION));
        return step;
    }

    public static Step buildPatientValidatorStep() {
        Step step = new Step('Auto Validate Patient');
        step.actions.add(new StepAction(StepAction.ActionType.PATIENT_VALIDATION));
        return step;
    }

    public static Step buildPharmanetSaPushStep() {
        Step step = new Step('Auto Push to Pharmanet');
        step.actions.add(new StepAction(StepAction.ActionType.PHARMANET_SA_PUSH));
        return step;
    }

    public static Step buildOwnerAssignmentStep(Id ownerId) {
        Step step = new Step('Default Owner Assignment');
        step.actions.add(new StepAction(ownerId));
        return step;
    }
}
