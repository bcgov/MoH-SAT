@isTest
public with sharing class PHNCaseLookupTest {
    @isTest
    public static void testLookup() {
      Drug__c drug = TestFactory.newDrug('Drug 1');
      insert drug;

      Account patient = TestFactory.newPatient('Patient 1');
      patient.Patient_Identifier__pc = '123456789';
      Account provider = TestFactory.newProvider('Provider 1');
      insert new Account[] { patient, provider };

      Case saCase = TestFactory.newCase(drug, patient, provider, 'Test case 1');
      insert saCase;

      List<Case> cases = PHNCaseLookup.lookup(patient.Patient_Identifier__pc);
      system.debug(cases);
      system.assertEquals(1, cases.size());
    }
}