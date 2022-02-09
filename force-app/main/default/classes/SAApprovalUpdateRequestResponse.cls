public with sharing class SAApprovalUpdateRequestResponse {
    @AuraEnabled public String requestUUID {get;set;}
	@AuraEnabled public String clientName {get;set;}
	@AuraEnabled public Integer status {get;set;}
	@AuraEnabled public List<String> statusMessage {get;set;}
	@AuraEnabled public CalloutResponse error {get;set;}
}
