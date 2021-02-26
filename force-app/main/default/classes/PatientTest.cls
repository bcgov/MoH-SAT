@isTest
public class PatientTest {
    @isTest
    public static void PatientTest() {
        Patient p = new Patient();
        p.names = new List<Patient.PersonName>();
        p.phn = '';
        p.dob = Date.today();
        p.verified = true;
        p.verifiedDate = DateTime.now();
    }
}