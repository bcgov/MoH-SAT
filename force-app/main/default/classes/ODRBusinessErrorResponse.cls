public class ODRBusinessErrorResponse {
    @AuraEnabled public String requestUUID {get;set;}
    @AuraEnabled public String clientName {get;set;}
    @AuraEnabled public String status {get;set;}
    @AuraEnabled public List<String> statusMessage {get;set;}
}