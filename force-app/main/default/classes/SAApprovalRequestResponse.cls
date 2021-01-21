public with sharing class SAApprovalRequestResponse {
	@AuraEnabled public String requestUUID {get;set;}
	@AuraEnabled public String clientName {get;set;}
	@AuraEnabled public Integer status {get;set;}
	@AuraEnabled public List<String> statusMessage {get;set;}
	@AuraEnabled public CalloutResponse error {get;set;}
}