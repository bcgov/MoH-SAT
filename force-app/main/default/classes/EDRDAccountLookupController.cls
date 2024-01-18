/**********************************************************************************************
* @Author:      Suman 
* @Date:        07 Dec 2023
* @Description: The purpose of this class is to create methods which can be used by different trigger event
***********************************************************************************************/
public with sharing class EDRDAccountLookupController{
/** 
* @author: Suman
* @date: 07 Dec 2023
* @description: The purpose of this method is to populate patient Account information based on Patient Identifier
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/    
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccount(string actPHN){
        List<Account> accList = new List<Account>();
        if (!String.isBlank(actPHN)){
            string accountIdentificationNumber = actPHN ;
            accList = [SELECT Id, Name,LastName,PersonContact.Birthdate,PersonBirthdate,
                       PersonContact.Patient_Identifier__c, Patient_Identifier__pc from Account Where PersonContact.Patient_Identifier__c LIKE :accountIdentificationNumber ORDER BY createdDate DESC LIMIT 5];
        } 
        return accList;
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
            accountList = [SELECT Id, Name,LastName, Provider_Identifier__pc, PersonContact.Provider_Identifier__c, Provider_Type__pc from Account Where PersonContact.Provider_Identifier__c LIKE :providerPHNumber ORDER BY createdDate DESC LIMIT 5];
        } 
        return accountList;
    }
}