public with sharing class SimilarCases {

    @AuraEnabled
    public static List<Case> find(Id caseId) {
        system.debug(caseId);
        Case record = [select Id, Drug__c, Drug_Name__c, (select Question__c, Response__c from Request_Details__r) from Case where Id = :caseId];

        return [
            select Id, CaseNumber, Subject, Status, Drug__c, Drug__r.Name,
                (
                    select Id, Question__c, Response__c
                    from Request_Details__r    
                )
            from Case
            where Drug_Name__c = :record.Drug_Name__c
            and Id != :caseId
            limit 10
        ];
    }
}
