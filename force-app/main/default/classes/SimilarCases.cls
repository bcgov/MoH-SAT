public with sharing class SimilarCases {

    @AuraEnabled(cacheable=true)
    public static List<Case> find(Id caseId) {
        Case record = [select Id, Drug_Name__c from Case where Id = :caseId];

        return [
            select 
                Id, CaseNumber, Subject, Status, ClosedDate, Drug_Name__c,
                Contact.Name, Provider__r.Name, Owner.Name
            from Case
            where Drug_Name__c = :record.Drug_Name__c
            and IsClosed=true
            and Id != :caseId
            order by ClosedDate desc
            limit 20
        ];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Case> getActiveSaRequests(Id contactId, Id drugId) {
        return [
            select Id, CaseNumber, Status, Drug__r.Name, Prescriber_Name_Template__c, Termination_Date__c, CreatedDate
            from Case
            where ContactId = :contactId
            and Drug__c = :drugId
            order by ClosedDate desc
        ];
    }
}