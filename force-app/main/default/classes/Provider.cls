public class Provider {
    @AuraEnabled public String applicationUUID {get;set;}
    @AuraEnabled public String firstName {get;set;}
    @AuraEnabled public String middleInitial {get;set;}
    @AuraEnabled public String lastName {get;set;}
    @AuraEnabled public String dateofBirth {get;set;}
    @AuraEnabled public String status {get;set;}
    @AuraEnabled public String effectiveDate {get;set;}
    @AuraEnabled public Boolean verified {get;set;}
}
