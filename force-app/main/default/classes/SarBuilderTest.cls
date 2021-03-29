@isTest
public with sharing class SarBuilderTest {
    
    @testSetup
    static void test_setup() {
        Drug__c drug1 = TestFactory.newDrug('test-drug');
        insert new Drug__c[] {drug1};
    }

    @isTest
    static void test_build() {
        SpecialAuthorityRequest sar = SarBuilder.build(newBundleJson());
        
        system.assertEquals(queryDrug('test-drug').Id, sar.drug.Id);
        system.assertEquals('9878507098', sar.patient.Patient_Identifier__pc);
        system.assertEquals('10101', sar.provider.Provider_Identifier__pc);
        system.assertEquals(3, sar.requestDetails.size());
        system.assertEquals(2, sar.contentVersions.size());
    }

    private static Drug__c queryDrug(String drugName) {
        return [select Id, Drug_Code__c from Drug__c where Name=:drugName limit 1];
    }

    /**
     * bundle.json with the following resources:
     * - 1 Patient
     * - 1 Provider
     * - 1 QuestionnaireResponse
     * - 2 Binaries (1 application/pdf and 1 application/eform)
     */
    private static String newBundleJson() {
        // bundle.json with the following resources: 
        //Patient, Provider, QuestionnaireResponse, and a Binary.
        return '{' 
        + '"resourceType": "Bundle", "meta": { "lastUpdated": "2021-01-01T07:00:00.0000000+00:00", "tag": [ { "system": "https://ehealthbc.ca/NamingSystem/eforms/correlationId", "code": "test-code" } ] }, "type": "message",'
            + '"entry": ['
                + '{ "resource": { "resourceType": "Patient", "id": "Patient1", "identifier": [ { "type": { "text": "BC" }, "system": "https://fhir.infoway-inforoute.ca/NamingSystem/ca-bc-patient-healthcare-id", "value": "9878507098" } ], "active": true, "name": [ { "use": "official", "family": "Patient", "given": [ "Test" ] } ], "telecom": [ { "system": "phone", "value": "(250) 000-0000", "use": "work" }, { "system": "email", "value": "test@test.gov.bc.ca", "use": "work" } ], "gender": "female", "birthDate": "1990-01-01" } },'
                + '{ "resource": { "resourceType": "Practitioner", "id": "Submitter1", "identifier": [ { "system": "https://fhir.infoway-inforoute.ca/NamingSystem/ca-bc-msp-billing-id", "value": "10101" } ], "name": [ { "use": "official", "family": "Provider", "given": [ "Test" ] } ], "telecom": [ { "system": "phone", "value": "250-000-0000", "use": "home" } ], "address": [ { "use": "home", "line": [ "2 Two St", "2" ], "city": "Burnaby", "state": "BC", "postalCode": "B1B1B1", "period": { "start": "2021-03-29T14:15:59.5186868-07:00" } } ], "qualification": [ { "code": { "coding": [ { "system": "urn:role", "display": "OOP - Out Of Province" } ] } }, { "code": { "coding": [ { "system": "urn:specialty", "code": "cardiology" } ] } } ] } },'
                + '{ "resource": { "resourceType": "Binary", "id": "test-binary-id", "contentType": "application/eforms", "data": "" } },'
                + '{ "resource": { "resourceType": "QuestionnaireResponse", "id": "test-qr-id", "status": "completed", "authored": "2021-02-08T12:03:53+00:00", "item": [ { "linkId": "medication", "text": "Select medication:", "answer": [ { "valueString": "test-drug" } ] }, { "linkId": "level1", "text": "Level 1", "item": [ { "linkId": "level2", "text": "Level 2", "item": [ { "linkId": "level3a", "text": "Level 1.2.3a Question", "answer": [ { "valueString": "Level 1.2.3a string answer" } ] }, { "linkId": "level3b", "text": "Level 1.2.3b Question", "answer": [ { "valueString": "Level 1.2.3b string answer" } ] } ] } ] } ] } },'
                + '{ "resource": { "resourceType": "Binary", "id": "test-binary-id", "contentType": "application/pdf", "data": "testbinary" } }'
            + ']'
        + '}';
    }
}
