public without sharing class PatientRelatedCases {

    @AuraEnabled(cacheable=true)
    public static List<Case> query(Id caseId) {
        Case record = [select ContactId from Case where Id = :caseId];

        return [
            Select 
                Id, CaseNumber, Subject, Status, ClosedDate, Drug_Name__c,
                Contact.Name, Provider__r.Name, Owner.Name
            From Case
            Where ContactId = :record.ContactId
            AND Id != :caseId 
            AND Status IN ('Approved', 'Not Approved', 'More Information Requested', 'Duplicate', 'Currently Approved', 'Cancelled')
            order BY ClosedDate desc
            limit 20
        ];
    }
}