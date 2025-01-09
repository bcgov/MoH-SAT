public class EDRD_EmpiWrapper {
    public class InputWrapper 
    {
        public String phn {get;set;}
        public String firstName {get; set;}
        public String lastName {get; set;}
        public Date dateOfBirth {get; set;}
        public String reason {get; set;}
        public String gender {get; set;}
        public String clickBy {get;set;}
        public Id patientAccId {get;set;}
        public Id providerConId {get;set;}
        public Id LoginUserAccountId {get;set;}
        public Id PatientContactId {get;set;}
        
    }
    public class OutputWrapper
    {   
        public String phn {get;set;}
        public Boolean isPatientFound {get; set;}
        public String firstName {get;set;}
        public String lastName {get;set;}
        public Date dateOfBirth {get;set;}
        public Boolean deceased {get;set;}
        public String responseMessage {get;set;}
        public String gender {get; set;}
        public Id patientId {get; set;}
        public Id patientaccountId {get; set;}
        public Id patientContactId {get; set;}
        public Boolean isValidatePHNClick {get;set;}
        public Boolean isClickEmpiSearch {get;set;}
        public Boolean isClickSFsearch {get;set;}
        public Boolean isClickManulRecord {get;set;}
        public Boolean isPatientInSF {get;set;}
        public Boolean isPatientInEMPI {get;set;}
  
        
      }

    public class Patient {
    public boolean deceased {get;set;}
    public String dob {get;set;}
    public String gender {get;set;}
    public List<PersonName> names {get;set;}
    public String phn {get;set;}
    public String verified {get;set;}
    public String verifiedDate {get;set;}
    public String notes {get;set;}
    }
    public class PersonName {
        public boolean declared;
        public String familyName;
        public List<String> givenNames;
        public String type;
    }

}