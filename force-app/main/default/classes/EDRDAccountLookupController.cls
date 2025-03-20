/**********************************************************************************************
* @Author:      Accenture 
* @Date:        07 Dec 2023
* @Description: The purpose of this class is the controller of 
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]  
                16-Nov -  EDRD-104          -  Deepak      -  Changes related to EDRD EMPI Integration for getAccount
                16-Nov -  EDRD-104          -  Deepak      -  method to setup mockpatient
                16-Nov -  EDRD-104          -  Deepak      -  method to return patient Accounts information based on Patient Identifiers by SOQL
                16-Nov -  EDRD-104          -  Deepak      -  Validates if a patient record exists for the given Patient Identifier
                20-Jan -  EDRD-104          -  Deepak      -  method to return patient Accounts information based on Patient Identifiers by SOSL
***********************************************************************************************/
public with sharing class EDRDAccountLookupController{
    public static Id patientRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Patient').getRecordTypeId();

/** 
* @author: Deepak
* @date: 16 Nov 2024
* @description: The purpose of this method is to setup mockpatient
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/
@TestVisible
    private static Patient mockPatient;    
    
/** 
* @author: Suman
* @date: 07 Dec 2023
* @description: The purpose of this method is to populate patient Account information based on Patient Identifier
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
                     16-Nov -  EDRD-104          -  Deepak      -  Changes related to EDRD EMPI Integration
*/    
    @AuraEnabled(cacheable=false)
    public static String getAccount(string actPHN){
        Map<String, String> keyVsValueMap = new Map<String, string>{'ISPHNFOUND' => '', 'PHNDETAILS' => '', 'SFPHNDETAILS' => ''};
            
            try{ 
                Patient patientObj = Test.isRunningTest() ? mockPatient : EmpiIntegration.getPatient(actPHN);
                If(patientObj.names != NULL){
                    keyVsValueMap.put('ISPHNFOUND', 'YES');
                    keyVsValueMap.put('PHNDETAILS', JSON.Serialize(patientObj));
                }else If (!String.isBlank(actPHN) && patientObj.names == NULL){
                    string accountIdentificationNumber = actPHN ;
                    keyVsValueMap.put('ISPHNFOUND', 'NO');
                }
            } catch(exception ex){
                system.debug('An error occurred: ' + ex.getMessage());
            }        
        return JSON.Serialize(keyVsValueMap);
    }
/**
* @author: Suman
* @date: 07 Dec 2023
* @description: The purpose of this method is to populate provider Account information based on Provider Identifier
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/
    @AuraEnabled(cacheable=true)
    public static List<Account> getProviderAccount(string providerAct){
        List<Account> accountList = new List<Account>();
        if (!String.isBlank(providerAct)){
            string providerPHNumber = providerAct;
            accountList = [SELECT Id, Name,LastName, Provider_Identifier__pc, PersonContact.Provider_Identifier__c, PersonContact.Provider_Type__c, Provider_Type__pc from Account Where PersonContact.Provider_Type__c = 'Physician' AND PersonContact.Provider_Identifier__c LIKE :providerPHNumber ORDER BY createdDate DESC LIMIT 5];
        } 
        return accountList;
    }

/** 
* @author: Deepak
* @date: 16 Nov 2024
* @description: The purpose of this method is to return patient Accounts information based on Patient Identifiers by SOQL.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/    
    @AuraEnabled
    public static List<Account> searchPatients(Map<String, String> searchCriteria) {
        String patientIdentifier = searchCriteria.get('patientIdentifier');
        String firstName = searchCriteria.get('firstName');
        String lastName = searchCriteria.get('lastName');
        String birthDate = searchCriteria.get('birthDate');
        
        List<Account> patients = new List<Account>();
        String soql = 'SELECT Id, Name, FirstName, LastName, PersonBirthdate, PersonGender, Patient_Identifier__pc, Patient_is_Deceased__pc FROM Account WHERE RecordType.DeveloperName = \'Patient\'';
        
        if (String.isNotBlank(patientIdentifier)) {
            soql += ' AND Patient_Identifier__pc =:patientIdentifier';
        }else if (String.isNotBlank(firstName) && String.isNotBlank(lastName) && String.isNotBlank(birthDate)) {
            Date dOB = Date.valueOf(birthDate);
            soql += ' AND FirstName = :firstName AND LastName = :lastName AND PersonBirthdate = : dOB';
        }
        
        soql += ' ORDER BY CreatedDate Desc LIMIT 10';
        
        patients = Database.query(soql);
        return patients;
    }
    
/** 
* @author: Deepak
* @date: 20 Jan 2025
* @description: The purpose of this method is to return patient Accounts information based on Patient Identifiers by SOSL.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/    
    @AuraEnabled
    public static List<Account> searchPatients_SOSL(Map<String, String> searchCriteria) {
        String patientIdentifier = searchCriteria.get('patientIdentifier');
        String firstName = searchCriteria.get('firstName');
        String lastName = searchCriteria.get('lastName');
        String birthDate = searchCriteria.get('birthDate');
        
        List<Account> patients = new List<Account>();
        
        if (String.isNotBlank(patientIdentifier)) {
            List<List<SObject>> searchResults = [
                FIND :patientIdentifier IN ALL FIELDS
                RETURNING Account(Id, Name, FirstName, LastName, PersonBirthdate, PersonGender, Patient_Identifier__pc, Patient_is_Deceased__pc 
                                  WHERE RecordType.DeveloperName = 'Patient' AND Patient_Identifier__pc = :patientIdentifier
                                  ORDER BY CreatedDate DESC LIMIT 10)];
            if (!searchResults.isEmpty()) {
                patients = (List<Account>)searchResults[0];
            }
        } else if (String.isNotBlank(firstName) && String.isNotBlank(lastName) && String.isNotBlank(birthDate)) {
            String searchQuery = firstName + ' ' + lastName;
            List<List<SObject>> searchResults = [FIND :searchQuery IN ALL FIELDS
                                                 RETURNING Account(Id, Name, FirstName, LastName, PersonBirthdate, PersonGender, Patient_Identifier__pc, Patient_is_Deceased__pc 
                                                                   WHERE RecordType.DeveloperName = 'Patient'
                                                                   AND PersonBirthdate = :Date.valueOf(birthDate) ORDER BY CreatedDate DESC LIMIT 10)];
            if (!searchResults.isEmpty()) {
                patients = (List<Account>)searchResults[0];
            }
        }        
        return patients;
    }
    
/** 
* @author: Deepak
* @date: 16 Nov 2024
* @description: The purpose of this method is to Validates if a patient record exists for the given Patient Identifier.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/
    @AuraEnabled
    public static Boolean validatePatientIdentifier(String patientIdentifier) {
        if (String.isBlank(patientIdentifier)) {
            return false; 
        }        
        Integer recordCount = [SELECT COUNT() FROM Account WHERE RecordType.DeveloperName = 'Patient' AND Patient_Identifier__pc = :patientIdentifier];
        
        return recordCount > 0;
    }
}