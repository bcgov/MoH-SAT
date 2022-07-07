public class SAApprovalUpdateRequest {

    public SAApprovalUpdateRequest() {
        this.saRecordId = new SARecordId();
        this.saRecordId.specialItem = new SpecialItem();
        this.saRevisedData = new SARevisedData();
        this.saRevisedData.justificationCodes = new List<String>();
        this.saRevisedData.excludedPlans = new List<String>();
        this.saRevisedData.specialItem = new SpecialItem();
        this.saRevisedData.saRequester = new SARequester();
    }

    public class SARevisedData {
        @AuraEnabled public SpecialItem specialItem {get;set;}
        @AuraEnabled public String specAuthType {get;set;}
        @AuraEnabled public List<String> justificationCodes {get;set;}
        @AuraEnabled public List<String> excludedPlans {get;set;}
        @AuraEnabled public SARequester saRequester {get;set;}
        @AuraEnabled public String effectiveDate {get;set;}
        @AuraEnabled public String terminationDate {get;set;}
        @AuraEnabled public Integer maxDaysSupply {get;set;}
        @AuraEnabled public Double maxPricePct {get;set;}
    }

    public class SARequester {
        @AuraEnabled public String practIdRef {get;set;}
        @AuraEnabled public String practId {get;set;}
        @AuraEnabled public String decCode {get;set;}
    }

    public class SpecialItem {
        @AuraEnabled public String rdp {get;set;}
        @AuraEnabled public String din {get;set;}
    }

    public class SARecordId {
        @AuraEnabled public String phn {get;set;}
        @AuraEnabled public SpecialItem specialItem {get;set;}
        @AuraEnabled public String specAuthType {get;set;}
        @AuraEnabled public String effectiveDate {get;set;}
    }

    @AuraEnabled public String requestUUID {get;set;}
    @AuraEnabled public String clientName {get;set;}
    @AuraEnabled public String userid {get;set;}
    @AuraEnabled public String updateType {get;set;}
    @AuraEnabled public SARecordId saRecordId {get;set;}
    @AuraEnabled public SARevisedData saRevisedData {get;set;}
}