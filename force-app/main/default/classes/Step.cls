public with sharing class Step {
    public Integer order { get; private set; }
    public Boolean alwaysRun { get; private set; }
    public String criteriaLogic { get; private set; }
    public String title { get; private set; }
    public List<StepCriteria> criteria { get; private set; }
    public List<StepAction> actions { get; private set; }
    public Map<Integer, StepCriteria> criteriaMap { get; private set; }
    
    public Boolean criteriaResult { get; private set; }

    public Step(
            Integer order,
            String title,
            Boolean alwaysRun,
            String criteriaLogic,
            List<StepCriteria> criteria,
            List<StepAction> actions) {
        this.order = order;
        this.title = title;
        this.alwaysRun = alwaysRun;
        this.criteriaLogic = criteriaLogic;
        this.criteria = criteria;
        this.actions = actions;
        initCriteriaMap();
    }

    public Step(String title) {
        this(
            null,
            title,
            true,
            null,
            new List<StepCriteria>(),
            new List<StepAction>()
        );
    }

    private void initCriteriaMap() {
        this.criteriaMap = new Map<Integer, StepCriteria>();
        for (StepCriteria c : criteria) {
            criteriaMap.put(c.order, c);
        }
    }

    public Boolean executable(Case caseRecord, List<Request_Detail__c> requestDetailRecords) {
     if(!this.alwaysRun && String.isBlank(this.criteriaLogic)) {
        return false;
    }
    
    Boolean result = this.alwaysRun || evaluateCriteria(caseRecord, requestDetailRecords);
    return result;
    }

    public Boolean evaluateCriteria(
        Case saCase, 
        List<Request_Detail__c> requestDetails
    ) {
        System.debug('### Step.evaluateCriteria - START');
        System.debug('### Step.evaluateCriteria - Step Title: ' + this.title);
        System.debug('### Step.evaluateCriteria - Criteria Logic: ' + this.criteriaLogic);
        System.debug('### Step.evaluateCriteria - Total Criteria: ' + this.criteria.size());
    
        // Build criteria map
        Map<Integer, StepCriteria> criteriaMap = new Map<Integer, StepCriteria>();
        for (StepCriteria c : this.criteria) {
            if (criteriaMap.containsKey(c.order)) {
                System.debug('### Step.evaluateCriteria - !!! DUPLICATE ORDER DETECTED: ' + c.order);
                System.debug('### Step.evaluateCriteria - Existing: ' + criteriaMap.get(c.order).fieldName);
                System.debug('### Step.evaluateCriteria - New (will overwrite): ' + c.fieldName);
            }
            criteriaMap.put(c.order, c);
            System.debug('### Step.evaluateCriteria - Added to map - Order: ' + c.order + 
                         ' | Object: ' + c.sobjectName + 
                         ' | Field: ' + c.fieldName +
                         ' | QID: ' + c.questionId);
        }
    
        System.debug('### Step.evaluateCriteria - criteriaMap size: ' + criteriaMap.size());
        System.debug('### Step.evaluateCriteria - criteriaMap keys: ' + criteriaMap.keySet());
    
        // Set records
        setRecords(saCase, requestDetails);
    
        // Parse logic
        System.debug('### Step.evaluateCriteria - Parsing logic: ' + this.criteriaLogic);
        Expression logicExpression = Parser.parse(this.criteriaLogic);
    
        // Evaluate each criteria
        for (Integer criteriaOrder : criteriaMap.keySet()) {
            StepCriteria criteria = criteriaMap.get(criteriaOrder);
            String orderKey = String.valueOf(criteriaOrder);
    
            System.debug('### Step.evaluateCriteria - Evaluating Order: ' + criteriaOrder + 
                         ' | orderKey: "' + orderKey + '"' +
                         ' | field: ' + criteria.fieldName +
                         ' | actualValue null?: ');
    
            try {
                Boolean evalResult = criteria.evaluate();
                System.debug('### Step.evaluateCriteria - Order: ' + criteriaOrder + 
                             ' | evalResult: ' + evalResult);
                logicExpression.set(orderKey, evalResult);
                System.debug('### Step.evaluateCriteria - Set "' + orderKey + '" = ' + evalResult);
            } catch (Exception e) {
                System.debug('### Step.evaluateCriteria - ERROR on Order: ' + criteriaOrder + 
                             ' | Error: ' + e.getMessage());
                throw e;
            }
        }
    
        Boolean result = logicExpression.evaluate();
        System.debug('### Step.evaluateCriteria - FINAL RESULT: ' + result);
        return result;
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