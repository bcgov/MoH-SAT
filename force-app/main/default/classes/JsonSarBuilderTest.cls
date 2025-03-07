@isTest
public with sharing class JsonSarBuilderTest {
    
    @testSetup
    static void test_setup() {
        Drug__c drug1 = TestFactory.newDrug('test-drug');
        Drug__c drug2 = TestFactory.newDrug('100extrabgts');
        insert new Drug__c[] {drug1, drug2};
    }

    @isTest
    static void test_build() {
        SpecialAuthorityRequest sar = new JsonSarBuilder(newBundleJson()).build();
        
        system.assertEquals(queryDrug('test-drug').Id, sar.drug.Id);
        system.assertEquals('9878507098', sar.patient.Patient_Identifier__pc);
        system.assertEquals('10101', sar.provider.Provider_Identifier__pc);
        system.assertEquals(3, sar.requestDetails.size());
        system.assertEquals(2, sar.contentVersions.size());
    }

    @isTest
    static void test_build_dec() {
        SpecialAuthorityRequest sar = new JsonSarBuilder(newBundleJsonForDec()).build();
        
        system.assertEquals(queryDrug('100extrabgts').Id, sar.drug.Id);
        system.assertEquals('9878507098', sar.patient.Patient_Identifier__pc);
        system.assertEquals('FH9999', sar.dec.DEC__c);
        system.assertEquals(null, sar.provider);
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
                + '{ "resource": { "resourceType": "Practitioner", "id": "Submitter1", "identifier": [ { "system": "https://fhir.infoway-inforoute.ca/NamingSystem/ca-bc-license-physician", "value": "10101" } ], "name": [ { "use": "official", "family": "Provider", "given": [ "Test" ] } ], "telecom": [ { "system": "phone", "value": "250-000-0000", "use": "home" } ], "address": [ { "use": "home", "line": [ "2 Two St", "2" ], "city": "Burnaby", "state": "BC", "postalCode": "B1B1B1", "period": { "start": "2021-03-29T14:15:59.5186868-07:00" } } ], "qualification": [ { "code": { "coding": [ { "system": "http://fhir.infoway-inforoute.ca/CodeSystem/scpqual", "display": "OOP - Out Of Province" } ] } }, { "code": { "coding": [ { "system": "http://hl7.org/fhir/practitioner-specialty", "code": "cardiology" } ] } } ] } },'
                + '{ "resource": { "resourceType": "Binary", "id": "test-binary-id", "contentType": "application/eforms", "data": "" } },'
                + '{ "resource": { "resourceType": "QuestionnaireResponse", "id": "test-qr-id", "status": "completed", "authored": "2021-02-08T12:03:53+00:00", "item": [ { "linkId": "medication", "text": "Select medication:", "answer": [ { "valueString": "test-drug" } ] }, { "linkId": "level1", "text": "Level 1", "item": [ { "linkId": "level2", "text": "Level 2", "item": [ { "linkId": "level3a", "text": "Level 1.2.3a Question", "answer": [ { "valueString": "Level 1.2.3a string answer" } ] }, { "linkId": "level3b", "text": "Level 1.2.3b Question", "answer": [ { "valueString": "Level 1.2.3b string answer" } ] } ] } ] } ] } },'
                + '{ "resource": { "resourceType": "Binary", "id": "test-binary-id", "contentType": "application/pdf", "data": "testbinary" } }'
            + ']'
        + '}';
    }
    
    /**
     * bundle.json for a DEC submission:
     * - 1 Patient
     * - 1 QuestionnaireResponse
     */
    private static String newBundleJsonForDec() {
        // bundle.json with the following resources: 
        //Patient, Provider, QuestionnaireResponse, and a Binary.
        return '{' 
        + '"resourceType": "Bundle", "meta": { "lastUpdated": "2021-01-01T07:00:00.0000000+00:00", "tag": [ { "system": "https://ehealthbc.ca/NamingSystem/eforms/correlationId", "code": "test-code" } ] }, "type": "message",'
            + '"entry": ['
                + '{ "resource": { "resourceType": "Patient", "id": "Patient1", "identifier": [ { "type": { "text": "BC" }, "system": "https://fhir.infoway-inforoute.ca/NamingSystem/ca-bc-patient-healthcare-id", "value": "9878507098" } ], "active": true, "name": [ { "use": "official", "family": "Patient", "given": [ "Test" ] } ], "telecom": [ { "system": "phone", "value": "(250) 000-0000", "use": "work" }, { "system": "email", "value": "test@test.gov.bc.ca", "use": "work" } ], "gender": "female", "birthDate": "1990-01-01" } },'
                + '{ "resource": { "resourceType": "QuestionnaireResponse", "id": "091a8e34-c63e-4af2-8e89-50191166f2a5", "status": "completed", "authored": "2021-09-07T17:08:31-07:00", "source": { "reference": "Patient/Patient1" }, "item": [ { "linkId": "iAmA", "text": "I am a:", "answer": [ { "valueString": "DEC" } ] }, { "linkId": "panelDECinfo", "text": "Diabetes Education Centre Information", "item": [ { "linkId": "dec", "text": "DEC#", "answer": [ { "valueString": "FH9999" } ] }, { "linkId": "decAddress", "text": "Address", "item": [ { "linkId": "providerFaxNumber1", "text": "Fax Number", "answer": [ { "valueString": "2505551212" } ] }, { "linkId": "decStreetAddressLine1", "text": "Street Address 1", "answer": [ { "valueString": "1952 Bay Street" } ] }, { "linkId": "decAddressCity", "text": "City", "answer": [ { "valueString": "Victoria" } ] }, { "linkId": "decaddressProvince", "text": "Province", "answer": [ { "valueString": "BC" } ] }, { "linkId": "decAddressPostalCode", "text": "Postal Code", "answer": [ { "valueString": "V8R1J8" } ] } ] } ] }, { "linkId": "medication", "text": "Select medication:", "answer": [ { "valueString": "100extrabgts" } ] } ] } }'
            + ']'
        + '}';
    }
}
