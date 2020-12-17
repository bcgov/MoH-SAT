public class PatientInformation {
    @AuraEnabled public String name {get;set;}
    @AuraEnabled public String phn {get;set;}
    @AuraEnabled public Datetime dob {get;set;}
    @AuraEnabled public Boolean verified {get;set;}
    @AuraEnabled public Datetime verifiedDate {get;set;}
}
