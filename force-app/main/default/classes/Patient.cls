public class Patient {
    public class PersonName {
      @AuraEnabled public String familyName {get;set;}
      @AuraEnabled public String givenName {get;set;}
      @AuraEnabled public String type {get;set;}
      @AuraEnabled public Boolean declared {get;set;}
    }
    @auraEnabled public List<PersonName> names {get;set;}
    @AuraEnabled public String phn {get;set;}
    @AuraEnabled public String gender {get;set;}
    @AuraEnabled public Datetime dob {get;set;}
    @AuraEnabled public Boolean deceased {get;set;}
    @AuraEnabled public Boolean verified {get;set;}
    @AuraEnabled public Datetime verifiedDate {get;set;}
    @AuraEnabled public String notes {get;set;}
}
