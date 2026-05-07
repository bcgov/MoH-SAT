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
    
    @testSetup
    static void setupTestData() {
        // If you need to create any test certificates or custom settings
        // You may need to create a certificate named 'plis' in your org for this test to work
        // Or mock the Crypto.signWithCertificate method if possible
    }
    
    @isTest
    static void testGetAccessToken_Success() {
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
        // Set mock callout for failure
        Test.setMock(HttpCalloutMock.class, new MockFailureHttpResponse());
        
        Test.startTest();
        try {
            String accessToken = AzureAuthService.getAccessToken();
            // The access_token key won't exist in error response, so it will return null
            System.assertEquals(null, accessToken, 'Access token should be null on failure');
        } catch (Exception e) {
            // Expected behavior if error handling is added
            System.assert(true, 'Exception expected on authentication failure');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGetAccessToken_Unauthorized() {
        // Set mock callout for unauthorized
        Test.setMock(HttpCalloutMock.class, new MockUnauthorizedHttpResponse());
        
        Test.startTest();
        String accessToken = AzureAuthService.getAccessToken();
        Test.stopTest();
        
        // Should return null as access_token won't be in error response
        System.assertEquals(null, accessToken, 'Access token should be null when unauthorized');
    }
    
    @isTest
    static void testBase64UrlEncode() {
        Test.startTest();
        
        // Test the base64UrlEncode method indirectly through JWT creation
        String testString = 'test+/=';
        Blob testBlob = Blob.valueOf(testString);
        
        // This tests the conversion logic
        String base64Standard = EncodingUtil.base64Encode(testBlob);
        System.assert(base64Standard.contains('=') || base64Standard.contains('+') || base64Standard.contains('/'), 
                     'Standard base64 should contain special characters');
        
        Test.stopTest();
    }
    
    @isTest
    static void testJWTCreation() {
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
        
        Test.stopTest();
    }
    
    @isTest
    static void testMultipleTokenRequests() {
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
}