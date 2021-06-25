public class SAApprovalHistoryResponse {

	public class SARequester {
		@AuraEnabled public String practIdRef {get;set;}
		@AuraEnabled public String practId {get;set;}
		@AuraEnabled public String decCode {get;set;}
		@AuraEnabled public String pharmacyID {get;set;}
	}

	public class SpecialItem {
		@AuraEnabled public String din {get;set;}
		@AuraEnabled public String rdp {get;set;}
		@AuraEnabled public String text {get;set;}
		@AuraEnabled public String itemDescription {get;set;}
	}

	public class SARecords {
		@AuraEnabled public SpecialItem specialItem {get;set;}
		@AuraEnabled public String specAuthType {get;set;}
    	@AuraEnabled public List<String> justificationCodes {get;set;}
		@AuraEnabled public SARequester saRequester {get;set;}
		@AuraEnabled public String effectiveDate {get;set;}
		@AuraEnabled public String terminationDate {get;set;}
    	@AuraEnabled public List<String> excludedPlans {get;set;}
		@AuraEnabled public Integer maxDaysSupply {get;set;}
		@AuraEnabled public Double maxPricePct {get;set;}
		@AuraEnabled public String createdBy {get;set;}
	}

	@AuraEnabled public String requestUUID {get;set;}
	@AuraEnabled public String clientName {get;set;}
	@AuraEnabled public Integer totalRecords {get;set;}
	@AuraEnabled public List<SARecords> saRecords {get;set;}
	@AuraEnabled public CalloutResponse error {get;set;}
}