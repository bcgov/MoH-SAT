public class Patient {
    @AuraEnabled public String familyName {get;set;}
    @AuraEnabled public String givenName {get;set;}
    @AuraEnabled public String phn {get;set;}
    @AuraEnabled public String gender {get;set;}
    @AuraEnabled public Datetime dob {get;set;}
    @AuraEnabled public Boolean deceased {get;set;}
    @AuraEnabled public Boolean verified {get;set;}
    @AuraEnabled public Datetime verifiedDate {get;set;}
}
