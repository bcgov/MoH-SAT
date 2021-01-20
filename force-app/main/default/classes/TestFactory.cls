@IsTest
public with sharing class TestFactory {

    public static Account newPatient(String firstName) {
        Account account = new Account();
        account.RecordTypeId = getRecordTypeInfosByDeveloperName('Account', 'Patient').getRecordTypeId();
        account.Patient_Identifier__pc = '222333444';
        account.FirstName = firstName;
        account.LastName = 'TestPatient';
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
        return saCase;
    }

    public static Case newCase(Drug__c drug, String subject) {
        Case saCase = new Case();
        saCase.RecordTypeId = getRecordTypeInfosByDeveloperName('Case', 'Special_Authority_Request').getRecordTypeId();
        saCase.Drug__c = drug.Id;
        saCase.Subject = subject;
        return saCase;
    }

    private static Contact queryPersonContact(Id accountId) {
        return [select Id from Contact where AccountId = :accountId];
    }

    public static Request_Detail__c newRequestDetail(Case saCase, String questionId, String stringValue) {
        Request_Detail__c rd = new Request_Detail__c();
        rd.Case__c = saCase.Id;
        rd.Sort_Order__c = 1;
        rd.Question__c = 'Test Question?';
        rd.Question_ID__c = questionId;
        rd.String_Value__c = stringValue;
        return rd;
    }

    public static Adjudication_Criteria__c newCriteria(Drug__c drug, Integer order, String objectName, String fieldName, String questionId, String operator, String stringValue) {
        return newCriteria(drug, order, objectName,fieldName,questionId,operator,stringValue,null,null,null,null);
    }

    public static Adjudication_Criteria__c newCriteria(Drug__c drug, Integer order, String objectName, String fieldName, String questionId, String operator, Boolean booleanValue) {
        return newCriteria(drug, order, objectName,fieldName,questionId,operator,null,booleanValue,null,null,null);
    }

    public static Adjudication_Criteria__c newCriteria(Drug__c drug, Integer order, String objectName, String fieldName, String questionId, String operator, Decimal decimalValue) {
        return newCriteria(drug, order, objectName,fieldName,questionId,operator,null,null,decimalValue,null,null);
    }

    public static Adjudication_Criteria__c newCriteria(Drug__c drug, Integer order, String objectName, String fieldName, String questionId, String operator, Date dateValue) {
        return newCriteria(drug, order, objectName,fieldName,questionId,operator,null,null,null,dateValue,null);
    }

    public static Adjudication_Criteria__c newCriteria(Drug__c drug, Integer order, String objectName, String fieldName, String questionId, String operator, Datetime datetimeValue) {
        return newCriteria(drug, order, objectName,fieldName,questionId,operator,null,null,null,null,datetimeValue);
    }

    public static Adjudication_Criteria__c newCriteria(String objectName, String fieldName, String questionId, String operator, String stringValue) {
        return newCriteria(null, null, objectName,fieldName,questionId,operator,stringValue,null,null,null,null);
    }

    public static Adjudication_Criteria__c newCriteria(String objectName, String fieldName, String questionId, String operator, Boolean booleanValue) {
        return newCriteria(null, null, objectName,fieldName,questionId,operator,null,booleanValue,null,null,null);
    }

    public static Adjudication_Criteria__c newCriteria(String objectName, String fieldName, String questionId, String operator, Decimal decimalValue) {
        return newCriteria(null, null, objectName,fieldName,questionId,operator,null,null,decimalValue,null,null);
    }

    public static Adjudication_Criteria__c newCriteria(String objectName, String fieldName, String questionId, String operator, Date dateValue) {
        return newCriteria(null, null, objectName,fieldName,questionId,operator,null,null,null,dateValue,null);
    }

    public static Adjudication_Criteria__c newCriteria(String objectName, String fieldName, String questionId, String operator, Datetime datetimeValue) {
        return newCriteria(null, null, objectName,fieldName,questionId,operator,null,null,null,null,datetimeValue);
    }

    public static Adjudication_Criteria__c newCriteria(
            Drug__c drug,
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
        Adjudication_Criteria__c ac = new Adjudication_Criteria__c();
        ac.Drug__c = drug == null ? null : drug.Id;
        ac.Order__c = order;
        ac.Object_Name__c = objectName;
        ac.Field_Name__c = fieldName;
        ac.Question_ID__c = questionId;
        ac.Operator__c = operator;
        ac.String_Value__c = stringValue;
        ac.Boolean_Value__c = booleanValue == null ? false : booleanValue;
        ac.Decimal_Value__c = decimalValue;
        ac.Date_Value__c = dateValue;
        ac.Datetime_Value__c = datetimeValue;
        return ac;
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
}
