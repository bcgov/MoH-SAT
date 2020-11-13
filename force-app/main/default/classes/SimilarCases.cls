public with sharing class SimilarCases {

    @AuraEnabled(cacheable=true)
    public static List<Case> find(Id caseId) {
        Case record = [select Id, Drug__c, Drug_Name__c, (select Question__c, Response__c from Request_Details__r) from Case where Id = :caseId];

        return [
            select Id, CaseNumber, Subject, Status, Contact.Name, Provider__r.Name, Owner.Name, ClosedDate,
                (
                    select Id, Question__c, Response__c
                    from Request_Details__r
                    order by Sort_Order__c asc
                )
            from Case
            where Drug_Name__c = :record.Drug_Name__c
            and IsClosed=true
            and Id != :caseId
            limit 10
        ];
    }
}
