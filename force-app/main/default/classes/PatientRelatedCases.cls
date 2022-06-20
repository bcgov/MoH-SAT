public without sharing class PatientRelatedCases {

    @AuraEnabled(cacheable=true)
    public static List<Case> query(Id caseId) {
        Case record = [select ContactId from Case where Id = :caseId];

        return [
            select 
                Id, CaseNumber, Subject, Status, ClosedDate, Drug_Name__c,
                Contact.Name, Provider__r.Name, Owner.Name
            from Case
            where ContactId = :record.ContactId
            and Id != :caseId
            order by CreatedDate asc
            limit 20
        ];
    }
}