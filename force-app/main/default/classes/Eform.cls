global with sharing class Eform {
    global class Bundle {
        public List<EForm.BundleEntry> entry;
    }

    global class BundleEntry {
        public Eform.Resource resource;

        public BundleEntry(Resource resource) {
            this.resource = resource;
        }
    }

    public abstract class Resource { }

    global class Patient extends Resource {
        public String patientIdentifier;
        public Boolean active;
        public String lastName;
        public String firstName;
        public Date birthdate;
        public String primaryEmail;
        public String primaryEmailUse;
        public String alternateEmail;
        public String alternateEmailUse;
        public String primaryPhone;
        public String primaryPhoneUse;
        public String alternatePhone;
        public String alternatePhoneUse;
        public String gender;
        public String country;
        public String province;
        public String city;
        public String streetLine1;
        public String streetLine2;
        public String postalCode;
        public String addressUse;
    }

    global class Provider extends Resource {
        public String providerIdentifier;
        public String providerIdentifierType;
        public Boolean active;
        public String lastName;
        public String firstName;
        public Date birthdate;
        public String primaryPhone;
        public String primaryPhoneUse;
        public String alternatePhone;
        public String alternatePhoneUse;
        public String gender;
        public String country;
        public String province;
        public String city;
        public String streetLine1;
        public String streetLine2;
        public String postalCode;
        public String addressUse;
    }

    global class QuestionnaireResponse extends Resource {
        public String status;
        public Datetime authored;
        public List<QRItem> item;
    }

    global class QRItem {
        public String linkId;
        public String text;
        public List<QRAnswer> answer;
        public List<QRItem> item;
    }

    global class QRAnswer {
        public Boolean valueBoolean;
        public Decimal valueDecimal;
        public Integer valueInteger;
        public Date valueDate;
        public Datetime valueDatetime;
        public String valueString;
        public String valueUrl;
    }

    global class Binary extends Resource {
        public String id;
        public String contentType;
        public String data;
    }
}
