@isTest
public class PatientTest {
    @isTest
    public static void PatientTest() {
        Patient p = new Patient();
        p.phn = '';
        p.dob = Date.today();
        p.verified = true;
        p.verifiedDate = DateTime.now();
        p.gender = 'gender';
        p.deceased = false;
        p.notes = 'notes';
        p.names = new List<Patient.PersonName>();
        Patient.PersonName name = new Patient.PersonName();
        name.familyName = 'family';
        name.type = 'type';
        name.declared = true;
        name.givenNames = new String[] {'fname1', 'fname2'};
        p.names.add(name);
    }
}