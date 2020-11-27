@isTest
public class ODRIntegrationTest {
    @isTest static void verifyPHNInformationTest() {
        Contact myContact = new Contact(Firstname='Test', Lastname='Contact');
        insert myContact;

        Case myCase = new Case(ContactId=myContact.Id, Status='Received', Origin='Test', patient_validated__c=false);
        insert myCase;

        String formData = '{"example":"test"}';
        String odrData = '{"example":"test"}';

        // bres = (BenefitsResponse) JSON.serialize(formData, BenefitsResponse.class);
        
        Boolean isValidated = ODRIntegration.verifyPHNData(odrData, formData);
        System.assertEquals(true, isValidated);
    }
}