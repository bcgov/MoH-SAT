public with sharing class StepAction {
    
    public enum ActionType { 
        ADJUDICATION, 
        OWNER_ASSIGNMENT, 
        PHARMANET_PAYLOAD, 
        PROVIDER_VALIDATION,
        PATIENT_VALIDATION,
        PHARMANET_SA_PUSH
    }
    
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
    public Boolean executed { get; private set; }

    public StepAction(StepAction.ActionType actionType) {
        this.actionType = actionType;
        this.executed = false;
    }

    public StepAction(Id ownerId) {
        this(StepAction.ActionType.Owner_ASSIGNMENT);
        this.ownerId = ownerId;
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
        this(actionType);
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

    public Boolean isOwnerAssignment() {
        return this.actionType == StepAction.ActionType.OWNER_ASSIGNMENT;
    }

    public static StepAction.ActionType toEnum(Id recordTypeId) {
        if (recordTypeId == SchemaUtil.getRecordTypeInfosByDeveloperName('Step_Action__c', 'Adjudication').getRecordTypeId()) {
            return StepAction.ActionType.ADJUDICATION;
        } else if (recordTypeId == SchemaUtil.getRecordTypeInfosByDeveloperName('Step_Action__c', 'Owner_Assignment').getRecordTypeId()) {
            return StepAction.ActionType.OWNER_ASSIGNMENT;
        } else if (recordTypeId == SchemaUtil.getRecordTypeInfosByDeveloperName('Step_Action__c', 'Pharmanet_Payload').getRecordTypeId()) {
            return StepAction.ActionType.PHARMANET_PAYLOAD;
        } else {
            return null;
        }
    }

    public void run(SpecialAuthorityRequest sar) {
        if (this.actionType == null) return;

        Type apexClass = Type.forName(getApexClass().getName());

        if (apexClass != null) {
            ((Action) apexClass.newInstance()).execute(sar, this);
            this.executed = true;
        }
    }

    private Type getApexClass() {
        Type apexClass;

        if (this.actionType == StepAction.ActionType.OWNER_ASSIGNMENT) {
            apexClass = OwnerAssignment.class;
        } else if (this.actionType == StepAction.ActionType.ADJUDICATION) {
            apexClass = Adjudication.class;
        } else if (this.actionType == StepAction.ActionType.PHARMANET_PAYLOAD) {
            apexClass = PharmanetDefaults.class;
        } else if (this.actionType == StepAction.ActionType.PATIENT_VALIDATION) {
            apexClass = PatientValidator.class;
        } else if (this.actionType == StepAction.ActionType.PROVIDER_VALIDATION) {
            apexClass = ProviderValidator.class;
        } else if (this.actionType == StepAction.ActionType.PHARMANET_SA_PUSH) {
            apexClass = SAPush.class;
        } else {
            apexClass = null;
        }

        return apexClass;
    }
}
