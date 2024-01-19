/**********************************************************************************************
* @Author:      Accenture 
* @Date:        19/01/2024
* @Description: The purpose of this class is to return list of patients to LWC edrd_myPatients
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description] 
***********************************************************************************************/
public with sharing class EDRD_myPatientsController {
    /**
* @author: Accenture
* @date: 19/01/2024
* @description: The purpose of this method is to populate termination date based on Approval time/time unit
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/  
    @AuraEnabled(cacheable=true)
    public static List<Contact> getPatientList() {
        List<Contact> contactList = new List<Contact>();
        List<user> users = [SELECT Id, AccountId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        if(users[0].AccountId != null){
            contactList = [SELECT Id,Name, Birthdate, Patient_Identifier__c 
                           FROM Contact
                           WHERE Id IN
                           (SELECT ContactId 
                            FROM AccountContactRelation 
                            WHERE AccountId = :users[0].AccountId and IsActive = true)
                           LIMIT 50000];
        }
        return contactList;
    }
}