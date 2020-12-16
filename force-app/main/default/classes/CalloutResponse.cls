public class CalloutResponse {
    @AuraEnabled public Integer errorCode {get;set;}
    @AuraEnabled public String errorMessage {get;set;}
    @AuraEnabled public String response {get;set;}
}
