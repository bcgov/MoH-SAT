@IsTest
public with sharing class TestFactory {

    private static Integer fakeIdcount = 0;
	private static final String ID_PATTERN = '000000000000';

    /**
	* credit: https://github.com/financialforcedev/fflib-apex-mocks/blob/master/src/classes/fflib_IDGenerator.cls
	*/
	public static Id newId(Schema.SobjectType sobjectType)
	{
		String keyPrefix = sobjectType.getDescribe().getKeyPrefix();
		fakeIdCount++;

		String fakeIdPrefix = ID_PATTERN.substring(0, 12 - fakeIdCount.format().length());

		return Id.valueOf(keyPrefix + fakeIdPrefix + fakeIdCount);
	}

    public static Account newPatient(String firstName) {
        Account account = new Account();
        account.RecordTypeId = getRecordTypeInfosByDeveloperName('Account', 'Patient').getRecordTypeId();
        account.Patient_Identifier__pc = '222333444';
        account.FirstName = firstName;
        account.LastName = 'TestPatient';
        account.PersonBirthdate = Date.parse('1990-01-01');
        return account;
    }
    
    public static Account newProvider(String firstName) {
        Account account = new Account();
        account.RecordTypeId = getRecordTypeInfosByDeveloperName('Account', 'Provider').getRecordTypeId();
        account.FirstName = firstName;
        account.LastName = 'TestProvider';
        account.Provider_Identifier__pc = '111222333';
        account.Provider_Type__pc = 'Pharmacist';
        return account;
    }
    
    public static Drug__c newDrug(String name) {
        Drug__c drug = new Drug__c();
        drug.Name = name;
        drug.Drug_Code__c = name;
        return drug;
    }

    public static Drug_Template__c newDrugTemplate(Drug__c drug, String name) {
        Drug_Template__c drugTemplate = new Drug_Template__c();
        drugTemplate.Drug__c = drug.Id;
        return drugTemplate;
    }
    
    public static Case newCase(Drug__c drug, Account patient, Account provider, String subject) {
        Case saCase = newCase(drug, subject);
        saCase.ContactId = queryPersonContact(patient.Id).Id;
        saCase.Provider__c = queryPersonContact(provider.Id).Id;
        saCase.Provider_Fax__c = '12505555555;';
        return saCase;
    }

    public static Case newCase(Drug__c drug, String subject) {
        Case saCase = new Case();
        saCase.RecordTypeId = getRecordTypeInfosByDeveloperName('Case', 'Special_Authority_Request').getRecordTypeId();
        saCase.Drug__c = drug.Id;
        saCase.Subject = subject;
        saCase.Effective_Date__c = Date.today();
        saCase.Termination_Date__c = Date.today().addYears(1);
        return saCase;
    }

    private static Contact queryPersonContact(Id accountId) {
        return [select Id from Contact where AccountId = :accountId];
    }

    public static Request_Detail__c newRequestDetail(Case saCase, String questionId, String stringValue) {
        Request_Detail__c rd = newRequestDetail(saCase, questionId);
        rd.String_Value__c = stringValue;
        return rd;
    }

    public static Request_Detail__c newRequestDetail(Case saCase, String questionId, Date dateValue) {
        Request_Detail__c rd = newRequestDetail(saCase, questionId);
        rd.Date_Value__c = dateValue;
        return rd;
    }

    public static Request_Detail__c newRequestDetail(Case saCase, String questionId, Datetime datetimeValue) {
        Request_Detail__c rd = newRequestDetail(saCase, questionId);
        rd.Datetime_Value__c = datetimeValue;
        return rd;
    }

    public static Request_Detail__c newRequestDetail(Case saCase, String questionId, Decimal decimalValue) {
        Request_Detail__c rd = newRequestDetail(saCase, questionId);
        rd.Decimal_Value__c = decimalValue;
        return rd;
    }

    public static Request_Detail__c newRequestDetail(Case saCase, String questionId, Boolean booleanValue) {
        Request_Detail__c rd = newRequestDetail(saCase, questionId);
        rd.Boolean_Value__c = booleanValue;
        return rd;
    }

    public static Request_Detail__c newRequestDetail(Case saCase, String questionId) {
        Request_Detail__c rd = new Request_Detail__c();
        rd.Case__c = saCase.Id;
        rd.Sort_Order__c = 1;
        rd.Question__c = 'Test Question?';
        rd.Question_ID__c = questionId;
        return rd;
    }

    public static Step__c newStep(Drug__c drug, Integer order, String criteriaLogic) {
        Step__c step = newStep(drug, order, false);
        step.Criteria_Logic__c = criteriaLogic;
        return step;
    }

    public static Step__c newStep(Drug__c drug, Integer order, Boolean alwaysRun) {
        Step__c step = new Step__c();
        step.Drug__c = drug.Id;
        step.Order__c = order;
        step.Always_Run__c = alwaysRun;
        step.Name = 'Test Step ' + String.valueOf(order);
        step.External_ID__c = Steps.formatExternalId(drug.Id, order, step.Name);
        step.Criteria_Logic__c = null;
        return step;
    }

    public static Step_Criteria__c newCriteria(Step__c step, Integer order, String objectName, String fieldName, String questionId, String operator, String stringValue) {
        return newCriteria(step, order, objectName,fieldName,questionId,operator,stringValue,null,null,null,null);
    }

    public static Step_Criteria__c newCriteria(Step__c step, Integer order, String objectName, String fieldName, String questionId, String operator, Boolean booleanValue) {
        return newCriteria(step, order, objectName,fieldName,questionId,operator,null,booleanValue,null,null,null);
    }

    public static Step_Criteria__c newCriteria(Step__c step, Integer order, String objectName, String fieldName, String questionId, String operator, Decimal decimalValue) {
        return newCriteria(step, order, objectName,fieldName,questionId,operator,null,null,decimalValue,null,null);
    }

    public static Step_Criteria__c newCriteria(Step__c step, Integer order, String objectName, String fieldName, String questionId, String operator, Date dateValue) {
        return newCriteria(step, order, objectName,fieldName,questionId,operator,null,null,null,dateValue,null);
    }

    public static Step_Criteria__c newCriteria(Step__c step, Integer order, String objectName, String fieldName, String questionId, String operator, Datetime datetimeValue) {
        return newCriteria(step, order, objectName,fieldName,questionId,operator,null,null,null,null,datetimeValue);
    }

    public static Step_Criteria__c newCriteria(String objectName, String fieldName, String questionId, String operator, String stringValue) {
        return newCriteria(null, null, objectName,fieldName,questionId,operator,stringValue,null,null,null,null);
    }

    public static Step_Criteria__c newCriteria(String objectName, String fieldName, String questionId, String operator, Boolean booleanValue) {
        return newCriteria(null, null, objectName,fieldName,questionId,operator,null,booleanValue,null,null,null);
    }

    public static Step_Criteria__c newCriteria(String objectName, String fieldName, String questionId, String operator, Decimal decimalValue) {
        return newCriteria(null, null, objectName,fieldName,questionId,operator,null,null,decimalValue,null,null);
    }

    public static Step_Criteria__c newCriteria(String objectName, String fieldName, String questionId, String operator, Date dateValue) {
        return newCriteria(null, null, objectName,fieldName,questionId,operator,null,null,null,dateValue,null);
    }

    public static Step_Criteria__c newCriteria(String objectName, String fieldName, String questionId, String operator, Datetime datetimeValue) {
        return newCriteria(null, null, objectName,fieldName,questionId,operator,null,null,null,null,datetimeValue);
    }

    public static Step_Criteria__c newCriteria(
            Step__c step,
            Integer order,
            String objectName, 
            String fieldName, 
            String questionId, 
            String operator, 
            String stringValue,
            Boolean booleanValue,
            Decimal decimalValue,
            Date dateValue,
            Datetime datetimeValue) {
        Step_Criteria__c sc = new Step_Criteria__c();
        sc.Step__c = step == null ? null : step.Id;
        sc.Order__c = order == null ? 0 : order;
        sc.Object_Name__c = objectName;
        sc.Field_Name__c = fieldName;
        sc.Question_ID__c = questionId;
        sc.Operator__c = operator;
        sc.String_Value__c = stringValue;
        sc.Boolean_Value__c = booleanValue == null ? false : booleanValue;
        sc.Decimal_Value__c = decimalValue;
        sc.Date_Value__c = dateValue;
        sc.Datetime_Value__c = datetimeValue;
        return sc;
    }

    public static Step_Action__c newStepAction(Step__c step, Integer order, Id ownerId) {
        return newStepAction(
            step,
            getRecordTypeInfosByDeveloperName('Step_Action__c', 'Owner_Assignment').getRecordTypeId(),
            order,
            ownerId,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null
        );
    }

    public static Step_Action__c newStepAction(Step__c step, Integer order, String adjudicationStatus) {
        return newStepAction(
            step,
            getRecordTypeInfosByDeveloperName('Step_Action__c', 'Adjudication').getRecordTypeId(),
            order,
            null,
            adjudicationStatus,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null
        );
    }

    public static Step_Action__c newStepAction(
            Step__c step,
            Integer order,
            String pharmanetCode,
            String keyType,
            String saType,
            Double pricePercent,
            Integer daysSupply,
            Integer duration,
            String durationUnit,
            String excludedPlans,
            String justificationCodes) {
        return newStepAction(
            step,
            getRecordTypeInfosByDeveloperName('Step_Action__c', 'Pharmanet_Payload').getRecordTypeId(),
            order,
            null,
            null,
            pharmanetCode,
            keyType,
            saType,
            pricePercent,
            daysSupply,
            duration,
            durationUnit,
            excludedPlans,
            justificationCodes
        );
    }

    public static Step_Action__c newStepAction(
            Step__c step,
            Id recordTypeId,
            Integer order, 
            Id ownerId,
            String adjudicationStatus,
            String pharmanetCode,
            String keyType,
            String saType,
            Double pricePercent,
            Integer daysSupply,
            Integer duration,
            String durationUnit,
            String excludedPlans,
            String justificationCodes) {
        Step_Action__c record = new Step_Action__c();
        record.Step__c = step.Id;
        record.RecordTypeId = recordTypeId;
        record.Order__c = order;
        record.OwnerId = ownerId;
        record.Adjudication_Status__c = adjudicationStatus;
        record.Pharmanet_Code__c = pharmanetCode;
        record.Key_Type__c = keyType;
        record.SA_Type__c = saType;
        record.Price_Percent__c = pricePercent;
        record.Days_Supply__c = daysSupply;
        record.Duration__c = duration;
        record.Duration_Unit__c = durationUnit;
        record.Excluded_Plans__c = excludedPlans;
        record.Justification_Codes__c = justificationCodes;
        return record;
    }

    public static Product_Health_Category__c newProductHealthCategory(String name, String DINs) {
      Product_Health_Category__c c = new Product_Health_Category__c();
      c.Name = name;
      c.DINs__c = DINs;
      return c;
    }

    public static RecordTypeInfo getRecordTypeInfosByDeveloperName(String sObjectName, String recordTypeName) {
        return getDescribe(sObjectName).getRecordTypeInfosByDeveloperName().get(recordTypeName);
    }

    public static RecordTypeInfo getRecordTypeInfoById(String sObjectName, Id recordTypeId) {
        return getDescribe(sObjectName).getRecordTypeInfosById().get(recordTypeId);
    }

    public static DescribeSObjectResult getDescribe(String sObjectName) {
        return getSObjectType(sObjectName).getDescribe();
    }

    public static SObjectType getSObjectType(String sObjectName) {
        return Schema.getGlobalDescribe().get(sObjectName);
    }

    public static SpecialAuthorityRequest newSpecialAuthorityRequest() {
        return new SobjectSarBuilder(
            new Drug__c(), 
            new Account(), 
            new Account(), 
            new Case(), 
            new List<Request_Detail__c>(),
            new List<ContentVersion>()
        ).build();
    }
}
