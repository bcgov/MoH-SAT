/**********************************************************************************************
* @Author:      Accenture 
* @Date:        19/01/2024
* @Description: The purpose of this class is to return list of patients to LWC edrd_myPatients
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description] 
                19 Jan -  EDRD-1112         -  Accenture   - method is to display List of EDRD patients for Providers on portal
                23 May -  EDRD-1407         -  Deepak      - method is to display List of EDRD Providers Team in EDRD Portal
                23 May -  EDRD-1407         -  Deepak      - method is to display List of related EDRD Providers Team in EDRD Portal
                23 May -  EDRD-1407         -  Deepak      - method is to display List of EDRD Providers Team in EDRD Portal
***********************************************************************************************/
public without sharing class EDRD_myPatientsController {
/**
* @author: Accenture
* @date: 19/01/2024
* @description: The purpose of this method is to display List of EDRD patients for Providers on portal
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/  
    @AuraEnabled(cacheable=true)
    public static List<Contact> getPatientList() {
        List<Contact> contactList = new List<Contact>();
        List<user> users = new List<User>();
        if(User.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible() &&
           Schema.SObjectType.User.fields.AccountId.isAccessible()){
               users = [SELECT Id, AccountId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
           }
        if(users!= null && users[0].AccountId != null &&
           Contact.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible() &&
           Schema.SObjectType.Contact.fields.Name.isAccessible() &&
           Schema.SObjectType.Contact.fields.Birthdate.isAccessible() &&
           Schema.SObjectType.Contact.fields.Patient_Identifier__c.isAccessible() &&
           AccountContactRelation.SObjectType.getDescribe().isAccessible() &&
           AccountContactRelation.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible() 
          ){
              contactList = [SELECT Id,Name, Birthdate, Patient_Identifier__c, EDRD_Ref_No__c 
                             FROM Contact
                             WHERE Id IN
                             (SELECT ContactId 
                              FROM AccountContactRelation 
                              WHERE AccountId = :users[0].AccountId AND IsActive = true AND Roles includes ('Physician'))
                             LIMIT 50000];
          }
        return contactList;
    }
    
/**
* @author: Deepak
* @date: 23/05/2025
* @description: The purpose of this method is to display List of EDRD Providers Team in EDRD Portal
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/
    @AuraEnabled(cacheable=true)
    public static List<Wrapper> getAlliedStaffList(){
        List<Wrapper> results = new List<Wrapper>();
        Id accountId = [SELECT AccountId FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1].AccountId;
        
        List<AccountContactRelation> aCRList = [SELECT Id, Roles, ContactId, Contact.Name, Contact.Account.Provider_Type__pc, Contact.Account.Provider_Identifier__pc 
                                                FROM AccountContactRelation
                                                WHERE AccountId = :accountId AND IsActive = true AND Roles includes ('Allied Staff')];
                
        for (AccountContactRelation acr : aCRList){
            results.add(new Wrapper(acr.ContactId, acr.Contact.Name, acr.Contact.Account.Provider_Type__pc, acr.Contact.Account.Provider_Identifier__pc, acr.Roles));
        }
        return results;
    }
    
/**
* @author: Deepak
* @date: 23/05/2025
* @description: The purpose of this method is to display List of related EDRD Providers Team in EDRD Portal
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/    
    @AuraEnabled(cacheable=true)
    public static List<Wrapper> getRelatedPhysiciansList(){
        List<Wrapper> results = new List<Wrapper>();
        Id contactId = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].ContactId;
        
        List<AccountContactRelation> aCRList = [SELECT Id, Roles, AccountId, Account.Name, Account.Provider_Type__pc, Account.Provider_Identifier__pc
                                                FROM AccountContactRelation WHERE ContactId =: contactId AND IsActive = true AND Roles includes ('Allied Staff')];
        
        for (AccountContactRelation acr : aCRList) {
            results.add(new Wrapper(acr.AccountId, acr.Account.Name, acr.Account.Provider_Type__pc, acr.Account.Provider_Identifier__pc, acr.Roles));
        }
        return results;
    }
    
/**
* @author: Deepak
* @date: 23/05/2025
* @description: The purpose of this method is to display List of EDRD Providers Team in EDRD Portal
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/
    public class Wrapper {
        @AuraEnabled public Id Id;
        @AuraEnabled public String Name;
        @AuraEnabled public String ProviderType;
        @AuraEnabled public String ProviderIdentifier;
        @AuraEnabled public String Role;
        
        public Wrapper(Id Id, String Name, String ProviderType, String ProviderIdentifier, String Role) {
            this.Id = Id;
            this.Name = Name;
            this.ProviderType = ProviderType;
            this.ProviderIdentifier = ProviderIdentifier;
            this.Role = Role;
        }
    }
}