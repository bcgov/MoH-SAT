public with sharing class DescriptionLookup {
    @AuraEnabled(cacheable=true)
    public static String getDescription(String code) {
        List<RDP_Code_Description__c> records = [select Description__c from RDP_Code_Description__c where Name = :code];   
        return records.isEmpty() ? null : records[0].Description__c; 
    }
}