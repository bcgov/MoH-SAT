@isTest
public with sharing class EmpiIntegrationTest {

    // Utility method for setting up mock configuration
    private static void setupMockSettings(Boolean useLRA) {
        LRA_API_Configuration__c mockSettings = new LRA_API_Configuration__c(
            Identifier_Namespace__c = 'TestNamespace',
            Name = 'LRA_API_Configuration',
            Use_LRA_API__c = useLRA,
            UserID__c = 'TestUser'
        );
        insert mockSettings;
    }

    // Mock HTTP response generator
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        private HttpResponse response;

        public MockHttpResponseGenerator(HttpResponse response) {
            this.response = response;
        }

        public HttpResponse respond(HttpRequest req) {
            return response;
        }
    }

    @isTest
    static void test_get_patient() {
        setupMockSettings(false);

        Test.startTest();
        EmpiIntegration.getPatient('test');
        Test.stopTest();
        // TODO:
        system.assert(true);

    }

    // Success Scenario-HTTP statuscode-200
    @isTest
    static void testFetchPatientDataLRA() {
        setupMockSettings(true);

        // Create a mock response
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('{' +
            '"entry": [' +
                '{ "resource": {' +
                    '"resourceType": "Patient",' +
                    '"name": [{"use": "official", "family": "Doe", "given": ["John"]}, {"use": "usual", "family": "Doe", "given": ["John"]}],' +
                    '"gender": "male",' +
                    '"birthDate": "1980-01-01",' +
                    '"active": true }},' +
                '{ "resource": {' +
                    '"resourceType": "OperationOutcome",' +
                    '"issue": [{"code": "error", "details": {"coding": [{"code": "12345", "display": "Error in data retrieval"}]}}]' +
                '}}]}');

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));

        Test.startTest();
        Patient result = EMPiIntegration.getPatient('9879450714');
        Test.stopTest();

        System.assertEquals('Doe', result.names[0].familyName);
        System.assertEquals('John', result.names[0].givenNames[0]);
        System.assertEquals('M', result.gender);
        System.assertEquals(Date.valueOf('1980-01-01'), result.dob);
        System.assertEquals(false, result.deceased);
    }


    // Error Scenario with Invalid data/Personal Health Number
    @isTest
    static void testFetchPatientDataErrorResponse() {
        setupMockSettings(true);

        // Create a mock response with error
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(400);
        mockResponse.setBody('{' +
            '"resourceType": "OperationOutcome",' +
            '"issue": [{' +
                '"severity": "error",' +
                '"code": "invalid",' +
                '"details": {"coding": [{"system": "http://lra.hlth.gov.bc.ca/fhir/client/bc-oo-codes",' +
                '"display": "An invalid PHN was supplied."}]}' +
            '}]}');

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));

        Test.startTest();
        Patient result = EMPiIntegration.getPatient('PHN123');
        Test.stopTest();

        // Verify the expected outcome.
        System.assertEquals('invalid', result.responseStatusValue);
        System.assertEquals(null, result.gender);
        System.assertEquals(null, result.dob);
        System.assertEquals(null, result.deceased);
        System.assertEquals( null, result.gender);
        
    }

    // Exception Scenario
    @isTest
    static void testFetchPatientDataExceptionResponse() {
        setupMockSettings(true);

        // Create a mock response
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('{' +
            '"entry": [' +
                '{ "resource": {' +
                    '"resourceType": "OperationOutcome",' +
                    '"issue": [{"code": "error", "details": {"coding": [{"code": "12345", "display": "Error in data retrieval"}]}}]' +
                '}}]}');

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));

        Test.startTest();
          // Call the method and expect it to fail due to exception
        try {
            EMPiIntegration.getPatient('9879450714');
            System.assert(false, 'Expected an exception to be thrown.');
        } catch (Exception e) {
            // Assert that an exception was thrown
            System.assert(true, 'Exception was expected and thrown.');
        }
        Test.stopTest();
    }
}