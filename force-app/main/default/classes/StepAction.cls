public with sharing class StepAction {
    public enum ActionType { ADJUDICATION, OWNER_ASSIGNMENT, PHARMANET_DEFAULTS }
    
    public ActionType actionType { get; private set; }
    public Id ownerId { get; private set; }
    public Integer order { get; private set; }
    public Integer daysSupply { get; private set; }
    public Integer duration { get; private set; }
    public Double pricePercent { get; private set; }
    public String adjudicationStatus { get; private set; }
    public String durationUnit { get; private set; }
    public String keyType { get; private set; }
    public String saType { get; private set; }
    public String pharmanetCode { get; private set; }
    public List<String> excludedPlans { get; private set; }
    public List<String> justificationCodes { get; private set; }

    public StepAction(Integer order, Id ownerId) {
        this.actionType = StepAction.ActionType.OWNER_ASSIGNMENT;
        this.order = order;
        this.ownerId = ownerId;
    }

    public StepAction(Integer order, String adjudicationStatus) {
        this.actionType = StepAction.ActionType.ADJUDICATION;
        this.adjudicationStatus = adjudicationStatus;
    }

    public StepAction(
            Integer order, 
            String pharmanetCode,
            String keyType,
            String saType,
            Integer daysSupply,
            Integer duration,
            String durationUnit,
            String excludedPlansStr,
            String justificationCodesStr) {
        this.actionType = StepAction.ActionType.PHARMANET_DEFAULTS;
        this.order = order;
        this.pharmanetCode = pharmanetCode;
        this.keyType = keyType;
        this.saType = saType;
        this.daysSupply = daysSupply;
        this.duration = duration;
        this.durationUnit = durationUnit;
        this.excludedPlans = excludedPlansStr?.split(';');
        this.justificationCodes = justificationCodesStr?.split(';');
    }

    public StepAction(
            StepAction.ActionType actionType,
            Integer order, 
            Id ownerId,
            String adjudicationStatus,
            String pharmanetCode,
            String keyType,
            String saType,
            Integer daysSupply,
            Integer duration,
            String durationUnit,
            String excludedPlansStr,
            String justificationCodesStr
    ) {
        this.actionType = actionType;
        this.order = order;
        this.ownerId = ownerId;
        this.adjudicationStatus = adjudicationStatus;
        this.pharmanetCode = pharmanetCode;
        this.keyType = keyType;
        this.saType = saType;
        this.daysSupply = daysSupply;
        this.duration = duration;
        this.durationUnit = durationUnit;
        this.excludedPlans = excludedPlansStr?.split(';');
        this.justificationCodes = justificationCodesStr?.split(';');
    }

    public StepAction(Step_Action__c record) {
        this(
            toEnum(record.RecordTypeId),
            record.Order__c?.intValue(),
            record.OwnerId,
            record.Adjudication_Status__c,
            record.Pharmanet_Code__c,
            record.Key_Type__c,
            record.SA_Type__c,
            record.Days_Supply__c?.intValue(),
            record.Duration__c?.intValue(),
            record.Duration_Unit__c,
            record.Excluded_Plans__c,
            record.Justification_Codes__c
        );
    }

    public static StepAction.ActionType toEnum(Id recordTypeId) {
        if (recordTypeId == SchemaUtil.getRecordTypeInfosByDeveloperName('Step_Action__c', 'Adjudication').getRecordTypeId()) {
            return StepAction.ActionType.ADJUDICATION;
        } else if (recordTypeId == SchemaUtil.getRecordTypeInfosByDeveloperName('Step_Action__c', 'Owner_Assignment').getRecordTypeId()) {
            return StepAction.ActionType.OWNER_ASSIGNMENT;
        } else if (recordTypeId == SchemaUtil.getRecordTypeInfosByDeveloperName('Step_Action__c', 'Pharmanet_Defaults').getRecordTypeId()) {
            return StepAction.ActionType.PHARMANET_DEFAULTS;
        } else {
            return null;
        }
    }
}
