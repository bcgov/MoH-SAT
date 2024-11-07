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
    
    public static Account newAccount(String name) {
        Account account = new Account();
        account.RecordTypeId = getRecordTypeInfosByDeveloperName('Account', 'Business_Account').getRecordTypeId();
        account.Name = name;
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
    
    public static Case newCase(Drug__c drug, String subject, External_Committee__c ec) {
        Case saCase = new Case();
        saCase.RecordTypeId = getRecordTypeInfosByDeveloperName('Case', 'Special_Authority_Request').getRecordTypeId();
        saCase.Drug__c = drug.Id;
        saCase.Subject = subject;
        saCase.Effective_Date__c = Date.today();
        saCase.Termination_Date__c = Date.today().addYears(1);
        saCase.External_Committee__c = ec.Id;
        return saCase;
    }
    
/**
* @author: Deepak
* @date: 02 March 2023
* @description: The purpose of this method is to create Test case record.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/  
    public static case createCase(){
        case caseObj = new case();
        return caseObj;
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
    
    public static Integration_Log__c newIntegrationLog(String patientId, String type, String key){
        Integration_Log__c il = new Integration_Log__c();
        il.Code__c = 400;
        il.Type__c = type;
        il.Key__c = key;
        il.Timestamp__c = Datetime.now();
        il.Patient__c = patientId;
        return il;
    }
    
    public static Contact newContact(String name, String email, Id accountId){
        Contact c = new Contact();
        c.LastName = name;
        c.Email = email;
        c.AccountId = accountId;
        return c;
    }
    
    public static External_Committee__c newExternalCommittee(String name, String type, Id accountId){
        External_Committee__c ec = new External_Committee__c();
        ec.Name = name;
        ec.External_Committee_Type__c = type;
        ec.Start_Time__c = Datetime.now();
        ec.End_Time__c = Datetime.now();
        ec.EC_To_Account__c = accountId;
        return ec;
    }
    
    public static OrgWideEmailAddress newOrgWideEmailAddress(String address, String displayName){
        OrgWideEmailAddress owea = new OrgWideEmailAddress();
        owea.Address = address;
        owea.DisplayName = displayName;
        return owea;
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
            new Account(), 
            new Case(), 
            new List<Request_Detail__c>(),
            new List<ContentVersion>()
        ).build();
    }
    
     public static Step_Action__c newCaseUpdateStepAction(
        Step__c step,
        Integer Order,
        Integer daysSupply,
        Integer duration,
        String durationUnit,
      	String subject,
        String description,
        String rationale) {          
            Step_Action__c record = new Step_Action__c();
            record.Step__c = step.Id;
            record.RecordTypeId = getRecordTypeInfosByDeveloperName('Step_Action__c', 'ESA_RT_Case_Update').getRecordTypeId();
            record.Order__c = Order;
            record.Days_Supply__c = daysSupply;
            record.Duration__c = duration;
            record.Duration_Unit__c = durationUnit;
            record.ESA_Subject__c = subject;
            record.ESA_Description__c = description;
            record.ESA_Rationale__c = rationale;
            return record;          
        }
    
    public static List<Case> createEDRDCase(Integer noOfRecords, ID recordTypeId, ID accountId) {
        List<Case> caseList = new List<Case>();
        for(Integer i=0; i< noOfRecords; i++){
            Case EDRDCase = new Case();
            EDRDCase.AccountId = accountId;
            EDRDCase.RecordTypeId = recordTypeId;
            caseList.add(EDRDCase);
        }
        return caseList;
    }
    
     public static CareProgram createCareProgram(String Name){
        CareProgram CareProgramObj = new CareProgram();
         CareProgramObj.Name = Name;
         return CareProgramObj;
    }
    
    public static CareProgramEnrollee createCareProgramEnrollee(String Name, ID accountId, ID CareProgramId){
        CareProgramEnrollee CareProgramEnrolleeObj = new CareProgramEnrollee();
        CareProgramEnrolleeObj.Name = Name;
        CareProgramEnrolleeObj.AccountId = accountId;
        CareProgramEnrolleeObj.CareProgramId = CareProgramId;
        CareProgramEnrolleeObj.Status = 'Active';
        return CareProgramEnrolleeObj;
    }
    
    public static List<MedicationRequest> createMedicationRequest(Integer noOfRecord, Id MedicationId, Id CaseId, Id PrescriberId, Id PatientId){
        List<MedicationRequest> MRList = new List<MedicationRequest>();
        for(Integer i = 0; i < noOfRecord; i++){
            MedicationRequest medicationRequestObj = new MedicationRequest();
            medicationRequestObj.Case__c = CaseId;
            medicationRequestObj.MedicationId = MedicationId;
            medicationRequestObj.RequesterId = PrescriberId;
            medicationRequestObj.PatientId = PatientId;
            medicationRequestObj.Status = 'Active';
            medicationRequestObj.Type = 'New';
            MRList.add(medicationRequestObj);
        }
        return MRList; 
    }
    
    public static List<Medication> createMedication(Integer noOfRecord, String Name){
        List<Medication> MedList = new List<Medication>();
        for(Integer i=0; i< noOfRecord; i++){
            Medication medicationObj = new Medication();
            medicationObj.Name = Name;
            medicationObj.Status = 'Active';
            MedList.add(medicationObj);
        }
        return MedList;
    }
    
    private static User prepareUser(String roleId, String profId, String firstName, String lastName) {  
        String orgId = UserInfo.getOrganizationId();  
        String dateString =   
        String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');  
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));  
        String uniqueName = orgId + dateString + randomInt;  
        User tempUser = new User(  
            FirstName = firstName,  
            LastName = lastName,  
            email = uniqueName + '@sfdc' + orgId + '.org',  
            Username = uniqueName + '@sfdc' + orgId + '.org',  
            EmailEncodingKey = 'ISO-8859-1',  
            Alias = uniqueName.substring(18, 23),  
            TimeZoneSidKey = 'America/Los_Angeles',  
            LocaleSidKey = 'en_US',  
            LanguageLocaleKey = 'en_US',  
            ProfileId = profId
        );    
        if( String.isBlank(roleId) == false ){
            tempUser.UserRoleId = roleId;
        }
        return tempUser;  
    }

    public static User createCommunityUser(String contactId, String profId, String firstName, String lastName) {
        User tempUser = prepareUser('', profId, firstName, lastName);
        tempUser.ContactId = contactId;
        return tempUser;
    }
    
    public static UnitOfMeasure createUnitOfMeasure(){
        UnitOfMeasure UOMObj = new UnitOfMeasure();
        UOMObj.Name = 'Milligrams';
        UOMObj.UnitCode = 'mg';
        return UOMObj;
    }
    
    public static List<MedicinalIngredient> createMedicinalIngredient(Integer noOfRecords, Id MedicationId, Id UnitOfMeasureId){
        List<MedicinalIngredient> MIList = new List<MedicinalIngredient>();
        for(Integer i=0; i<noOfRecords; i++){
            MedicinalIngredient MIObj = new MedicinalIngredient();
            MIObj.DIN__c = '12345678';
            MIObj.StrengthNumerator = 300;
            MIObj.StrengthNumeratorUnitId = UnitOfMeasureId;
            MIObj.Unit_Price__c = 100;
            MIObj.Formulation__c = 'Vial';
            MIObj.ParentRecordId = MedicationId;
            MIObj.IngredientId = MedicationId;
            MIList.add(MIObj);
        }
        return MIList;
    }
    
    public static ContentDocumentLink createContentDocumentLinkOnCase(Id CaseId){
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'testdocument.txt',
            VersionData = Blob.valueOf('Test Content')
        );
        insert contentVersion;
        
        ContentDocumentLink cDL = new ContentDocumentLink(
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion 
                                 WHERE Id = :contentVersion.Id].ContentDocumentId,
            LinkedEntityId = caseId,
            ShareType = 'V'
        );
        return cDL;
    }
}