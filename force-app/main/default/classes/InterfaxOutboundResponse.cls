public class InterfaxOutboundResponse {
  @AuraEnabled public String submitTime {get;set;}
  @AuraEnabled public Integer status {get;set;}
  @AuraEnabled public String error {get;set;}
}