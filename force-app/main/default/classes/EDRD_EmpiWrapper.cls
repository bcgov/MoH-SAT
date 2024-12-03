public class EDRD_EmpiWrapper {
    public class InputWrapper 
    {
        public String phn {get;set;}
        public String firstName {get; set;}
        public String lastName {get; set;}
        public Date dateOfBirth {get; set;}
        public String reason {get; set;}
    }
    public class OutputWrapper
    {
        public Boolean isPatientFound {get; set;}
        public String firstName {get;set;}
        public String lastName {get;set;}
        public Date dateOfBirth {get;set;}
        public Boolean deceased {get;set;}
        public String responseMessage {get;set;}
        public String gender {get; set;}
        public Id patientId {get; set;}
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