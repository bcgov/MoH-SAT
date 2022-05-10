public with sharing class DrugHelper {
    @AuraEnabled(cacheable=true)
    public static List<Drug> getDrugList() {
        return [SELECT Id, Name, Brand_Drug_Name__c, PharmaNet_RDP_code__c,
        Strength__c, Criteria_Website__c, Tech_Sheet__c
            FROM Drug__c];
    }
}
