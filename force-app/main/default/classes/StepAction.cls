public with sharing class StepAction {
    public enum ActionType { ADJUDICATION, OWNER_ASSIGNMENT, PHARMANET_DEFAULTS }
    
    public ActionType actionType;
    Id ownerId;
    Integer order;
    Integer daysSupply;
    Integer duration;
    Double pricePercent;
    String adjudicationStatus;
    String durationUnit;
    String keyType;
    String saType;
    String pharmanetCode;
    List<String> excludedPlans;
    List<String> justificationCodes;

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
