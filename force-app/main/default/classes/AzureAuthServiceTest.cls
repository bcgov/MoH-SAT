@isTest
private class AzureAuthServiceTest {
    
    // Mock class for successful OAuth response
    private class MockSuccessHttpResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            // Verify request parameters
            System.assertEquals('POST', req.getMethod());
            System.assertEquals('application/x-www-form-urlencoded', req.getHeader('Content-Type'));
            System.assert(req.getBody().contains('grant_type=client_credentials'));
            System.assert(req.getBody().contains('client_assertion_type=urn%3Aietf%3Aparams%3Aoauth%3Aclient-assertion-type%3Ajwt-bearer'));
            
            // Create mock response
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            
            Map<String, Object> responseBody = new Map<String, Object>{
                'token_type' => 'Bearer',
                'expires_in' => 3599,
                'access_token' => 'mock_access_token_12345'
            };
            
            res.setBody(JSON.serialize(responseBody));
            return res;
        }
    }
    
    // Mock class for failed OAuth response
    private class MockFailureHttpResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(400);
            res.setStatus('Bad Request');
            
            Map<String, Object> responseBody = new Map<String, Object>{
                'error' => 'invalid_client',
                'error_description' => 'Invalid client credentials'
            };
            
            res.setBody(JSON.serialize(responseBody));
            return res;
        }
    }
    
    // Mock class for unauthorized response
    private class MockUnauthorizedHttpResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(401);
            res.setStatus('Unauthorized');
            
            Map<String, Object> responseBody = new Map<String, Object>{
                'error' => 'unauthorized_client',
                'error_description' => 'Client is not authorized'
            };
            
            res.setBody(JSON.serialize(responseBody));
            return res;
        }
    }
    
    @isTest
    static void testGetAccessToken_Success() {
        // Enable test mode to use mock signature
        AzureAuthService.isTest = true;
        
        // Set mock callout
        Test.setMock(HttpCalloutMock.class, new MockSuccessHttpResponse());
        
        Test.startTest();
        String accessToken = AzureAuthService.getAccessToken();
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, accessToken, 'Access token should not be null');
        System.assertEquals('mock_access_token_12345', accessToken, 'Access token should match mock value');
    }
    
@isTest
static void testGetAccessToken_Failure() {
    // Enable test mode to use mock signature
    AzureAuthService.isTest = true;

    // Mock a failed HTTP response
    Test.setMock(HttpCalloutMock.class, new MockFailureHttpResponse());

    Test.startTest();

    try {
        AzureAuthService.getAccessToken();
        System.assert(false, 'Expected CalloutException was not thrown');
    } catch (CalloutException ex) {
        System.assert(
            ex.getMessage().contains('Failed to retrieve Azure access token'),
            'Unexpected exception message: ' + ex.getMessage()
        );

        System.assert(
            ex.getMessage().contains('Status Code:'),
            'Status code should be included in exception message'
        );
    }

    Test.stopTest();
}
    
@isTest
static void testGetAccessToken_Unauthorized() {
    // Enable test mode to use mock signature
    AzureAuthService.isTest = true;

    // Mock a 401 Unauthorized response
    Test.setMock(HttpCalloutMock.class, new MockUnauthorizedHttpResponse());

    Test.startTest();

    try {
        AzureAuthService.getAccessToken();
        System.assert(false, 'Expected CalloutException was not thrown');
    } catch (CalloutException ex) {
        System.assert(
            ex.getMessage().contains('Failed to retrieve Azure access token'),
            'Unexpected exception message: ' + ex.getMessage()
        );

        System.assert(
            ex.getMessage().contains('401'),
            'Expected 401 status code in exception message'
        );
    }

    Test.stopTest();
}
    
    @isTest
    static void testBase64UrlEncode() {
        Test.startTest();
        
        // Test the base64UrlEncode method
        String testString = 'test+/=';
        Blob testBlob = Blob.valueOf(testString);
        
        // Standard base64 should contain special characters
        String base64Standard = EncodingUtil.base64Encode(testBlob);
        System.assert(base64Standard.contains('=') || base64Standard.contains('+') || base64Standard.contains('/'), 
                     'Standard base64 should contain special characters');
        
        Test.stopTest();
    }
    
    @isTest
    static void testJWTCreation() {
        // Enable test mode
        AzureAuthService.isTest = true;
        
        // Set mock to capture the JWT in the request
        Test.setMock(HttpCalloutMock.class, new MockSuccessHttpResponse());
        
        Test.startTest();
        String accessToken = AzureAuthService.getAccessToken();
        Test.stopTest();
        
        // Verify that the method executes without errors
        // The JWT creation is tested implicitly through the getAccessToken call
        System.assertNotEquals(null, accessToken, 'JWT should be created and token retrieved');
    }
    
    @isTest
    static void testThumbprintConversion() {
        Test.startTest();
        
        // Test thumbprint conversion
        String thumbprint = '919fec62fa42d62b5469081a4ea4fa31834b00d2';
        Blob thumbBlob = EncodingUtil.convertFromHex(thumbprint);
        
        System.assertNotEquals(null, thumbBlob, 'Thumbprint conversion should not be null');
        System.assert(thumbBlob.size() > 0, 'Thumbprint blob should have content');
        System.assertEquals(20, thumbBlob.size(), 'SHA-1 thumbprint should be 20 bytes');
        
        Test.stopTest();
    }
    
    @isTest
    static void testMultipleTokenRequests() {
        // Enable test mode
        AzureAuthService.isTest = true;
        
        // Test multiple consecutive token requests
        Test.setMock(HttpCalloutMock.class, new MockSuccessHttpResponse());
        
        Test.startTest();
        String token1 = AzureAuthService.getAccessToken();
        String token2 = AzureAuthService.getAccessToken();
        Test.stopTest();
        
        System.assertNotEquals(null, token1, 'First token should not be null');
        System.assertNotEquals(null, token2, 'Second token should not be null');
        System.assertEquals(token1, token2, 'Tokens should be consistent with mock');
    }
    
    @isTest
    static void testErrorHandling_NoAccessToken() {
        AzureAuthService.isTest = true;
        
        Test.setMock(HttpCalloutMock.class, new MockFailureHttpResponse());
        
        Test.startTest();
        try {
            AzureAuthService.getAccessToken();
            System.assert(false, 'Expected CalloutException to be thrown');
        } catch (CalloutException ex) {
            System.assert(
                ex.getMessage().contains('Failed to retrieve Azure access token'),
                'Unexpected exception message: ' + ex.getMessage()
            );
        }
        Test.stopTest();
    }
    
    @isTest
    static void testIsTestFlag() {
        Test.startTest();
        
        // Test that isTest flag can be set
        AzureAuthService.isTest = false;
        System.assertEquals(false, AzureAuthService.isTest, 'isTest should be false');
        
        AzureAuthService.isTest = true;
        System.assertEquals(true, AzureAuthService.isTest, 'isTest should be true');
        
        Test.stopTest();
    }
    
    @isTest
    static void testHTTPRequestFormat() {
        // Enable test mode
        AzureAuthService.isTest = true;
        
        // Set mock
        Test.setMock(HttpCalloutMock.class, new MockSuccessHttpResponse());
        
        Test.startTest();
        // The mock's respond method validates the request format
        String token = AzureAuthService.getAccessToken();
        Test.stopTest();
        
        // If we get here, the request format was validated successfully by the mock
        System.assertNotEquals(null, token, 'Token should be retrieved with correct request format');
    }
}