public without sharing class RequestDetails {
    @AuraEnabled(cacheable=true)
    public static List<Request_Detail__c> getRequestDetails(Id caseId){
        return [
            select
                Id, Question__c, Question_ID__c, 
                Boolean_Value__c, Date_Value__c, Datetime_Value__c, Decimal_Value__c, String_Value__c, String_Value_Label__c
            from Request_Detail__c
            where Case__c = :caseId
            order by Sort_Order__c asc
        ];
    }
 
    @AuraEnabled
    public static void postToCaseFeed(Request_Detail__c oldRecord, Request_Detail__c newRecord){
        Request_Detail__c rd = [select Id, Name, Question__c, Case__c from Request_Detail__c where Id = :oldRecord.Id];
        Case caseRecord = [select Id from Case where Id = :rd.Case__c];

        String post = buildMessage(rd.Question__c, rd.Name, oldRecord, newRecord);

        if (!Test.isRunningTest()) ConnectApi.ChatterFeeds.postFeedElement(null, caseRecord.Id, ConnectApi.FeedElementType.FeedItem, post);
    }

    @TestVisible
    private static String buildMessage(String rdQuestion, String rdName, Request_Detail__c oldRecord, Request_Detail__c newRecord) {
        return String.format(
            '{0} changed request detail response for "{1}" ({2}) from "{3}" to "{4}"', new String[] {
                UserInfo.getName(),
                rdQuestion,
                rdName,
                getValue(oldRecord),
                getValue(newRecord)
        });
    }

    private static String getValue(Request_Detail__c record) {
        if (String.isNotBlank(record.String_Value__c)) return record.String_Value__c;
        else if (record.Decimal_Value__c != null) return String.valueOf(record.Decimal_Value__c);
        else if (record.Datetime_Value__c != null) return String.valueOf(record.Datetime_Value__c); 
        else if (record.Date_Value__c != null) return String.valueOf(record.Date_Value__c); 
        else return String.valueOf(record.Boolean_Value__c); 
    

        // Test for sonar issue
        
    }
}
