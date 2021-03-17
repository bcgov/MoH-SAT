public with sharing class RequestDetails {
    @AuraEnabled(cacheable=true)
    public static List<Request_Detail__c> getRequestDetails(Id caseId){
        return [
            select
                Id, Question__c, Question_ID__c, 
                Boolean_Value__c, Date_Value__c, Datetime_Value__c, Decimal_Value__c, String_Value__c
            from Request_Detail__c
            where Case__c = :caseId
            order by Sort_Order__c asc
        ];
    }
}
