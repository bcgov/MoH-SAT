@isTest
public with sharing class SobjectSarBuilderTest {
    @isTest
    static void test_build_from_case_id() {
        Drug__c drug = TestFactory.newDrug('Drug 1');
        insert drug;

        Account patient = TestFactory.newPatient('Patient 1');
        Account provider = TestFactory.newProvider('Provider 1');
        insert new Account[] { patient, provider };
        

        Case saCase = TestFactory.newCase(drug, patient, provider, 'Test case 1');
        insert saCase;
        
        List<Request_Detail__c> requestDetails = new List<Request_Detail__c>();
        requestDetails.add(TestFactory.newRequestDetail(saCase, 'question1', 'response1'));
        requestDetails.add(TestFactory.newRequestDetail(saCase, 'question2', 'response2'));
        insert requestDetails;

        Test.startTest();
        SpecialAuthorityRequest sar = new SobjectSarBuilder(saCase.Id).build();     
        Test.stopTest();

        system.assertEquals(drug.Id, sar.drug.Id);
        system.assertEquals(patient.Id, sar.patient.Id);
        system.assertEquals(provider.Id, sar.provider.Id);
        system.assertEquals(saCase.Id, sar.saCase.Id);
        system.assertEquals(requestDetails.size(), sar.requestDetails.size());
    }

    @isTest
    static void test_build_from_all_objs() {
        Drug__c drug = TestFactory.newDrug('Drug 1');
        insert drug;

        Account patient = TestFactory.newPatient('Patient 1');
        Account provider = TestFactory.newProvider('Provider 1');
        insert new Account[] { patient, provider };
        
        Case saCase = TestFactory.newCase(drug, patient, provider, 'Test case 1');
        insert saCase;
        
        List<Request_Detail__c> requestDetails = new List<Request_Detail__c>();
        requestDetails.add(TestFactory.newRequestDetail(saCase, 'question1', 'response1'));
        requestDetails.add(TestFactory.newRequestDetail(saCase, 'question2', 'response2'));
        insert requestDetails;

        Test.startTest();
        SpecialAuthorityRequest sar = new SobjectSarBuilder(drug, patient, provider, null, saCase, requestDetails, new List<ContentVersion>()).build();
        Test.stopTest();

        system.assertEquals(drug.Id, sar.drug.Id);
        system.assertEquals(patient.Id, sar.patient.Id);
        system.assertEquals(provider.Id, sar.provider.Id);
        system.assertEquals(saCase.Id, sar.saCase.Id);
        system.assertEquals(requestDetails.size(), sar.requestDetails.size());
    }
}