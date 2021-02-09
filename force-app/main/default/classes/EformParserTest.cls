@isTest
public with sharing class EformParserTest {

    @isTest
    static void test_parse() 
    {
        Eform.Bundle bundle = EformParser.parse(newBundleJson());

        Eform.Patient patient;
        Eform.Provider provider;
        List<Eform.QuestionnaireResponse> questionnaires = new List<Eform.QuestionnaireResponse>();
        List<Eform.Binary> binaries = new List<Eform.Binary>();

        for (Eform.BundleEntry bundleEntry : bundle.entry) {
            if (bundleEntry.resource instanceof Eform.Patient) {
                patient = (Eform.Patient) bundleEntry.resource;
            } else if (bundleEntry.resource instanceof Eform.Provider) {
                provider = (Eform.Provider) bundleEntry.resource;
            } else if (bundleEntry.resource instanceof Eform.Binary) {
                binaries.add((Eform.Binary) bundleEntry.resource);                
            } else if (bundleEntry.resource instanceof Eform.QuestionnaireResponse) {
                questionnaires.add((Eform.QuestionnaireResponse) bundleEntry.resource);
            }
        }

        system.assertEquals('9878507098', patient.patientIdentifier);
        system.assertEquals('10101', provider.providerIdentifier);
        system.assertEquals(1, binaries.size());
        system.assertEquals(false, questionnaires.isEmpty());
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
                + '{ "resource": { "resourceType": "Practitioner", "id": "Submitter1", "identifier": [ { "system": "https://fhir.infoway-inforoute.ca/NamingSystem/ca-bc-msp-billing-id", "value": "10101" } ], "name": [ { "use": "official", "family": "Provider", "given": [ "Test" ] } ], "telecom": [ { "system": "phone", "value": "250-000-0000", "use": "home" } ] } },'
                + '{ "resource": { "resourceType": "Binary", "id": "test-binary-id", "contentType": "application/eforms", "data": "" } },'
                + '{ "resource": { "resourceType": "QuestionnaireResponse", "id": "test-qr-id", "status": "completed", "authored": "2021-02-08T12:03:53+00:00", "item": [ { "linkId": "select", "text": "Select medication:", "answer": [ { "valueString": "test-drug" } ] }, { "linkId": "level1", "text": "Level 1", "item": [ { "linkId": "level2", "text": "Level 2", "item": [ { "linkId": "level3a", "text": "Level 1.2.3a Question", "answer": [ { "valueString": "Level 1.2.3a string answer" } ] }, { "linkId": "level3b", "text": "Level 1.2.3b Question", "answer": [ { "valueString": "Level 1.2.3b string answer" } ] } ] } ] } ] } },'
                + '{ "resource": { "resourceType": "Binary", "id": "test-binary-id", "contentType": "application/pdf", "data": "testbinary" } }'
            + ']'
        + '}';
    }
}
