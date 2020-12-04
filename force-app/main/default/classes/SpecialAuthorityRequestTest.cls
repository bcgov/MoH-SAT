@IsTest
public class SpecialAuthorityRequestTest {

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
        SpecialAuthorityRequest sar = SpecialAuthorityRequest.build(saCase.Id);        
        Test.stopTest();

        system.assertEquals(drug.Id, sar.drug.Id);
        system.assertEquals(patient.Id, sar.patient.Id);
        system.assertEquals(provider.Id, sar.provider.Id);
        system.assertEquals(saCase.Id, sar.saCase.Id);
        system.assertEquals(requestDetails.size(), sar.requestDetails.size());
    }

    @isTest
    static void test_build_from_case_obj() {
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
        SpecialAuthorityRequest sar = SpecialAuthorityRequest.build(saCase);        
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
        SpecialAuthorityRequest sar = SpecialAuthorityRequest.build(drug, patient, provider, saCase, requestDetails);        
        Test.stopTest();

        system.assertEquals(drug.Id, sar.drug.Id);
        system.assertEquals(patient.Id, sar.patient.Id);
        system.assertEquals(provider.Id, sar.provider.Id);
        system.assertEquals(saCase.Id, sar.saCase.Id);
        system.assertEquals(requestDetails.size(), sar.requestDetails.size());
    }

    @isTest
    static void test_get_adjudication_strategy() {
        Drug__c drug = new Drug__c();
        drug.Adjudication_Strategy__c = 'Manual';
        
        SpecialAuthorityRequest sar = SpecialAuthorityRequest.build(drug, null, null, null, null);
        system.assertEquals(drug.Adjudication_Strategy__c, sar.getAdjudicationStrategy());
        
        sar = SpecialAuthorityRequest.build(null, null, null, null, null);
        system.assertEquals(null, sar.getAdjudicationStrategy());
    }

    @isTest
    static void test_has_drug() {
        SpecialAuthorityRequest sar = SpecialAuthorityRequest.build(
            new Drug__c(), 
            new Account(), 
            new Account(), 
            new Case(), 
            new List<Request_Detail__c>()
        );
        
        system.assertEquals(true, sar.hasDrug());
        
        sar = SpecialAuthorityRequest.build(
            null,
            new Account(), 
            new Account(), 
            new Case(), 
            new List<Request_Detail__c>()
        );

        system.assertEquals(false, sar.hasDrug());
    }
}
