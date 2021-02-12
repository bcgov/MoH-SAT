@isTest
public class PatientTest {
    @isTest
    public static void PatientTest() {
        Patient p = new Patient();
        p.givenName = '';
        p.familyName = '';
        p.phn = '';
        p.dob = DateTime.now();
        p.verified = true;
        p.verifiedDate = DateTime.now();
    }
}