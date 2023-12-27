Public with sharing class EDRDAccountLookupController{
             

    @AuraEnabled(cacheable=true)
     public static List<Account> getAccount(string actPHN){

     List<Account> accList = new List<Account>();

     if (actPHN !=''){
     string accountIdentificationNumber = actPHN ;
     accList = [SELECT Id, Name,PersonContact.Birthdate,
     PersonContact.Patient_Identifier__c, Patient_Identifier__pc from Account Where PersonContact.Patient_Identifier__c LIKE :accountIdentificationNumber ORDER BY createdDate DESC LIMIT 5];

    } 
    return accList;
}

@AuraEnabled(cacheable=true)
public static List<Account> getProviderAccount(string providerAct){

List<Account> accountList = new List<Account>();

if (providerAct !=''){
string providerPHNumber = providerAct;
accountList = [SELECT Id, Name, Provider_Identifier__pc, PersonContact.Provider_Identifier__c, Provider_Type__pc from Account Where PersonContact.Provider_Identifier__c LIKE :providerPHNumber ORDER BY createdDate DESC LIMIT 5];

} 
return accountList;
}
}