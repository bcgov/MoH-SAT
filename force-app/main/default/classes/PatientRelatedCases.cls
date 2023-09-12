public without sharing class PatientRelatedCases {
    
    @AuraEnabled(cacheable=true)
    public static List<Case> query(Id caseId) {
        List<Case> caseList = new List<Case>();
        List<Case> caseRecords = [SELECT ContactId FROM Case WHERE Id = :caseId];
        
        if(!caseRecords.isEmpty()){
            caseList = [SELECT Id, CaseNumber, Subject, Status, ClosedDate, Drug_Name__c,Contact.Name, Provider__r.Name, Owner.Name
                        FROM Case
                        WHERE ContactId = :caseRecords[0].ContactId
                        AND Id != :caseId 
                        AND Status IN ('Approved', 'Not Approved', 'More Information Requested', 'Duplicate', 'Currently Approved', 'Cancelled')
                        ORDER BY ClosedDate DESC
                        LIMIT 20
                       ];
        }
        return caseList;
    }
}