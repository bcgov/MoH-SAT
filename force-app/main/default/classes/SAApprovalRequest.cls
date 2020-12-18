public class SAApprovalRequest {

    public SAApprovalRequest() {
        this.saRecord = new SARecord();
        this.saRecord.specialItem = new SpecialItem();
        this.saRecord.saRequester = new SARequester();
        this.saRecord.justificationCodes = new List<String>();
        this.saRecord.excludedPlans = new List<String>();
    }

    public class SARequester {
        @AuraEnabled public String pracIdRef {get;set;}
        @AuraEnabled public String pracId {get;set;}
    }

    public class SpecialItem {
        @AuraEnabled public String rdp {get;set;}
        @AuraEnabled public String din {get;set;}
    }

    public class SARecord {
        @AuraEnabled public String phn {get;set;}
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

    @AuraEnabled public String requestUUID {get;set;}
    @AuraEnabled public String clientName {get;set;}
    @AuraEnabled public String userid {get;set;}
    @AuraEnabled public SARecord saRecord {get;set;}
}