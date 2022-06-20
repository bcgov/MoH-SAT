@isTest
public with sharing class EmpiIntegrationTest {

    @isTest
    static void test_get_patient() {
        EmpiIntegration.getPatient('test');

        // TODO:
        system.assert(true);
    }
}