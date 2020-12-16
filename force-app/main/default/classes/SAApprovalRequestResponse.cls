public with sharing class SAApprovalRequestResponse {
	@AuraEnabled public String requestUUID {get;set;}
	@AuraEnabled public String clientName {get;set;}
	@AuraEnabled public String status {get;set;}
	@AuraEnabled public String statusMessage {get;set;}
	@AuraEnabled public CalloutResponse error {get;set;}
}
