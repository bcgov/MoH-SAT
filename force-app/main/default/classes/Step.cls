public with sharing class Step {
    public Integer order { get; private set; }
    public Boolean alwaysRun { get; private set; }
    public String criteriaLogic { get; private set; }
    public List<StepCriteria> criteria { get; private set; }
    public List<StepAction> actions { get; private set; }
    public Map<Integer, StepCriteria> criteriaMap { get; private set; }
    
    private Boolean criteriaResult;

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
        initCriteriaMap();
    }

    private void initCriteriaMap() {
        this.criteriaMap = new Map<Integer, StepCriteria>();
        for (StepCriteria c : criteria) {
            criteriaMap.put(c.order, c);
        }
    }

    public Boolean evaluate(Case caseRecord, List<Request_Detail__c> requestDetailRecords) {
        setRecords(caseRecord, requestDetailRecords);
        
        Expression logicExpression = Parser.parse(this.criteriaLogic);

        for (Integer criteriaOrder : this.criteriaMap.keySet()) {
            StepCriteria criteria = this.criteriaMap.get(criteriaOrder);

            String orderStr = String.valueOf(criteriaOrder);
            Boolean criteriaResult = criteria.evaluate();

            logicExpression.set(orderStr, criteriaResult);
        }

        this.criteriaResult = logicExpression.evaluate();

        return this.criteriaResult;
    }

    private void setRecords(Case caseRecord, List<Request_Detail__c> requestDetailRecords) {
        List<SObject> records = new List<SObject>();
        records.add(caseRecord);
        records.addAll(requestDetailRecords);

        for (StepCriteria sc : this.criteria) {
            for (SObject record : records) {
                sc.set(record);
            }
        }
    }
}
