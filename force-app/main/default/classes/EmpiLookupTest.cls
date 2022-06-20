@isTest
public with sharing class EmpiLookupTest {
    
    @isTest
    static void test_find_patient() {
        Patient mockPatient = new Patient();
        mockPatient.phn = '12345';

        EmpiLookup.mockPatient = mockPatient;

        Test.startTest();
        Patient resultPatient = EmpiLookup.findPatient('12345');
        Test.stopTest();

        system.assertEquals(mockPatient.phn, resultPatient.phn);
    }
}