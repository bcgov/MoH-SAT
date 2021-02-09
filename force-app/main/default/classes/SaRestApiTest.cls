@isTest
public with sharing class SaRestApiTest {
    
    @TestSetup
    static void test_setup(){
        Drug__c drug = TestFactory.newDrug('Drug 1');
        insert drug;

        Account patient = TestFactory.newPatient('Patient 1');
        patient.Patient_Identifier__pc = '123456789';
        Account provider = TestFactory.newProvider('Provider 1');
        insert new Account[] { patient, provider };
        
        Case saCase = TestFactory.newCase(drug, patient, provider, 'Test case 1');
        insert saCase;
    }

    @isTest
    static void test_get() {
        RestRequest req = new RestRequest(); 
    	req.httpMethod = 'GET';
        req.requestURI = '/services/apexrest/SA/';  
        req.addParameter('phn', '123456789');
        RestContext.request = req;
        
    	RestResponse res = new RestResponse();
        RestContext.response = res;
        
        Test.startTest();
        HealthGateway.SaList saList = SaRestApi.doGet();
        Test.stopTest();
        
        system.assertEquals(1, saList.items.size());
    }

    @isTest
    static void test_post() {
        // TODO
    }
}
