public with sharing class Step {
    Integer order;
    Boolean alwaysRun;
    String criteriaLogic;
    List<StepCriteria> criteria;
    List<StepAction> actions;

    public Step(
            Integer order,
            Boolean alwaysRun,
            String criteriaLogic,
            List<StepCriteria> criteria,
            List<StepAction> actions) {
        this.order = order;
        this.alwaysRun = alwaysRun;
        this.criteriaLogic = criteriaLogic;
        this.criteria = criteria;
        this.actions = actions;
    }
}
