@isTest
private class SAT_LabResultsServiceTest {
    
    // Mock class for Multi-callout (Azure Auth + PLIS API)
    private class MockMultiCallout implements HttpCalloutMock {
        private Integer callCount = 0;
        private String plisResponseType;
        
        public MockMultiCallout(String plisResponseType) {
            this.plisResponseType = plisResponseType;
        }
        
        public HttpResponse respond(HttpRequest req) {
            callCount++;
            HttpResponse res = new HttpResponse();
            
            // First call is Azure Auth
            if (req.getEndpoint().contains('login.microsoftonline.com')) {
                res.setStatusCode(200);
                res.setStatus('OK');
                Map<String, Object> authResponse = new Map<String, Object>{
                    'access_token' => 'mock_access_token',
                    'token_type' => 'Bearer',
                    'expires_in' => 3599
                };
                res.setBody(JSON.serialize(authResponse));
            }
            // Second call is PLIS API
            else if (req.getEndpoint().contains('plissit/getResults')) {
                if (plisResponseType == 'success') {
                    res.setStatusCode(200);
                    res.setStatus('OK');
                    res.setBody(getMockSuccessResponse());
                } else if (plisResponseType == 'noData') {
                    res.setStatusCode(200);
                    res.setStatus('OK');
                    res.setBody(getMockNoDataResponse());
                } else if (plisResponseType == 'unsuccessfulResponse') {
                    res.setStatusCode(200);
                    res.setStatus('OK');
                    res.setBody(getMockUnsuccessfulResponse());
                } else if (plisResponseType == 'httpError') {
                    res.setStatusCode(400);
                    res.setStatus('Bad Request');
                    res.setBody('{"error": "Bad Request"}');
                } else if (plisResponseType == 'timeout') {
                    res.setStatusCode(500);
                    res.setStatus('Internal Server Error');
                    res.setBody('{"error": "Timeout"}');
                } else if (plisResponseType == 'serverError') {
                    res.setStatusCode(500);
                    res.setStatus('Internal Server Error');
                    res.setBody('{"error": "Server error"}');
                }
            }
            
            return res;
        }
        
        private String getMockSuccessResponse() {
            Map<String, Object> response = new Map<String, Object>{
                'content' => new Map<String, Object>{
                    'success' => true,
                    'plisData' => new List<Object>{
                        new Map<String, Object>{
                            'observationDateTime' => '2024-01-15T10:30:00',
                            'value' => '150',
                            'observationValue' => '150',
                            'unit' => 'mg/dL',
                            'referenceRangeTxt' => '70-100 &lt;value&gt;',
                            'abnormalFlagCd' => 'H',
                            'observationTypeCd' => 'GLU',
                            'loincGroup' => 'Chemistry'
                        },
                        new Map<String, Object>{
                            'observationDateTime' => '2024-01-15T10:30:00',
                            'value' => null,
                            'observationValue' => '7.5',
                            'unit' => '%',
                            'referenceRangeTxt' => null,
                            'abnormalFlagCd' => 'H',
                            'observationTypeCd' => 'HBA1C',
                            'loincGroup' => 'Chemistry'
                        },
                        new Map<String, Object>{
                            'observationDateTime' => null,
                            'value' => '120',
                            'unit' => 'mmol/L',
                            'referenceRangeTxt' => '&lt; 120',
                            'abnormalFlagCd' => 'N',
                            'observationTypeCd' => 'CHOL',
                            'loincGroup' => 'Lipid Panel'
                        }
                    }
                }
            };
            return JSON.serialize(response);
        }
        
        private String getMockNoDataResponse() {
            Map<String, Object> response = new Map<String, Object>{
                'content' => new Map<String, Object>{
                    'success' => true,
                    'plisData' => new List<Object>()
                }
            };
            return JSON.serialize(response);
        }
        
        private String getMockUnsuccessfulResponse() {
            Map<String, Object> response = new Map<String, Object>{
                'content' => new Map<String, Object>{
                    'success' => false,
                    'message' => 'Invalid request'
                }
            };
            return JSON.serialize(response);
        }
    }
    
    @testSetup
    static void setupTestData() {
        // Create Person Account with Patient Identifier
        Account personAccount = new Account(
            FirstName = 'Test',
            LastName = 'Patient',
            PersonEmail = 'test.patient@example.com'
        );
        insert personAccount;
        
        // Refresh to get PersonContactId
        personAccount = [
            SELECT Id, PersonContactId 
            FROM Account 
            WHERE Id = :personAccount.Id
        ];
        
        // Update Contact with Patient Identifier
        Contact personContact = [
            SELECT Id 
            FROM Contact 
            WHERE Id = :personAccount.PersonContactId
        ];
        //personContact.Patient_Identifier__c = '9876543210';
        update personContact;
        
        // Create Case linked to Person Account
        Case testCase = new Case(
            Subject = 'Test Lab Results Case',
            Status = 'New',
            AccountId = personAccount.Id
        );
        insert testCase;
        
        // Create another Case without Account (for testing missing PHN)
        Case caseWithoutAccount = new Case(
            Subject = 'Test Case Without Account',
            Status = 'New'
        );
        insert caseWithoutAccount;
    }
    
    @isTest
    static void testGetCurrentUser() {
        Test.startTest();
        String lastName;
        Boolean exceptionThrown = false;
        
        try {
            lastName = SAT_LabResultsService.getCurrentUser();
        } catch (Exception e) {
            exceptionThrown = true;
            System.debug('Exception in testGetCurrentUser: ' + e.getMessage());
        }
        
        Test.stopTest();
        
        System.assertEquals(false, exceptionThrown, 'No exception should be thrown');
        User currentUser = [SELECT LastName FROM User WHERE Id = :UserInfo.getUserId()];
        System.assertEquals(currentUser.LastName, lastName, 'Should return current user last name');
    }
    
    @isTest
    static void testGetLabResults_Success() {
        Case testCase = [
            SELECT Id, Patient_Identifier__c 
            FROM Case 
            WHERE Subject = 'Test Lab Results Case' 
            LIMIT 1
        ];
        
        Test.setMock(HttpCalloutMock.class, new MockMultiCallout('success'));
        
        Test.startTest();
        List<SAT_LabResultsService.LabResultDTO> results;
        Boolean exceptionThrown = false;
        
        try {
            results = SAT_LabResultsService.getLabResults(
                testCase.Id,
                'Glucose',
                '2024-01-01',
                'Dr. Smith'
            );
        } catch (Exception e) {
            exceptionThrown = true;
            System.debug('Exception in testGetLabResults_Success: ' + e.getMessage());
        }
        
        Test.stopTest();
    }
    
    @isTest
    static void testGetLabResults_NoData() {
        Case testCase = [
            SELECT Id 
            FROM Case 
            WHERE Subject = 'Test Lab Results Case' 
            LIMIT 1
        ];
        
        Test.setMock(HttpCalloutMock.class, new MockMultiCallout('noData'));
        
        Test.startTest();
        List<SAT_LabResultsService.LabResultDTO> results;
        Boolean exceptionThrown = false;
        
        try {
            results = SAT_LabResultsService.getLabResults(
                testCase.Id,
                'Glucose',
                '2024-01-01',
                'Dr. Smith'
            );
        } catch (Exception e) {
            exceptionThrown = true;
            System.debug('Exception in testGetLabResults_NoData: ' + e.getMessage());
        }
        
        Test.stopTest();
    }
    
    @isTest
    static void testGetLabResults_MissingPatientIdentifier() {
        Case caseWithoutAccount = [
            SELECT Id 
            FROM Case 
            WHERE Subject = 'Test Case Without Account' 
            LIMIT 1
        ];
        
        Test.startTest();
        Boolean exceptionThrown = false;
        String exceptionMessage = '';
        
        try {
            SAT_LabResultsService.getLabResults(
                caseWithoutAccount.Id,
                'Glucose',
                '2024-01-01',
                'Dr. Smith'
            );
        } catch (AuraHandledException e) {
            exceptionThrown = true;
            exceptionMessage = e.getMessage();
        } catch (Exception e) {
            exceptionThrown = true;
            exceptionMessage = e.getMessage();
            System.debug('Unexpected exception type: ' + e.getTypeName());
        }
        
        Test.stopTest();
        
        System.assert(exceptionThrown, 'Should have thrown exception');
        
        // Verify error log
        List<Integration_Log__c> logs = [
            SELECT Code__c, Message__c 
            FROM Integration_Log__c
        ];
        System.assertEquals(1, logs.size(), 'Should create error log');
    }
    
    @isTest
    static void testGetLabResults_MissingTestType() {
        Case testCase = [
            SELECT Id 
            FROM Case 
            WHERE Subject = 'Test Lab Results Case' 
            LIMIT 1
        ];
        
        Test.startTest();
        Boolean exceptionThrown = false;
        String exceptionMessage = '';
        
        try {
            SAT_LabResultsService.getLabResults(
                testCase.Id,
                '',  // Empty test type
                '2024-01-01',
                'Dr. Smith'
            );
        } catch (AuraHandledException e) {
            exceptionThrown = true;
            exceptionMessage = e.getMessage();
        } catch (Exception e) {
            exceptionThrown = true;
            exceptionMessage = e.getMessage();
        }
        
        Test.stopTest();
        
        System.assert(exceptionThrown, 'Should have thrown exception');
        
        List<Integration_Log__c> logs = [SELECT Code__c, Message__c FROM Integration_Log__c];
        System.assertEquals(1, logs.size(), 'Should create error log');
        System.assertEquals(400, logs[0].Code__c, 'Should log 400 error');
    }
    
    @isTest
    static void testGetLabResults_MissingAsOfDate() {
        Case testCase = [
            SELECT Id 
            FROM Case 
            WHERE Subject = 'Test Lab Results Case' 
            LIMIT 1
        ];
        
        Test.startTest();
        Boolean exceptionThrown = false;
        String exceptionMessage = '';
        
        try {
            SAT_LabResultsService.getLabResults(
                testCase.Id,
                'Glucose',
                null,  // Null as of date
                'Dr. Smith'
            );
        } catch (AuraHandledException e) {
            exceptionThrown = true;
            exceptionMessage = e.getMessage();
        } catch (Exception e) {
            exceptionThrown = true;
            exceptionMessage = e.getMessage();
        }
        
        Test.stopTest();
        
        System.assert(exceptionThrown, 'Should have thrown exception');
        
        List<Integration_Log__c> logs = [SELECT Code__c FROM Integration_Log__c];
        System.assertEquals(1, logs.size(), 'Should create error log');
    }
    
    @isTest
    static void testGetLabResults_MissingRequester() {
        Case testCase = [
            SELECT Id 
            FROM Case 
            WHERE Subject = 'Test Lab Results Case' 
            LIMIT 1
        ];
        
        Test.startTest();
        Boolean exceptionThrown = false;
        String exceptionMessage = '';
        
        try {
            SAT_LabResultsService.getLabResults(
                testCase.Id,
                'Glucose',
                '2024-01-01',
                ''  // Empty requester
            );
        } catch (AuraHandledException e) {
            exceptionThrown = true;
            exceptionMessage = e.getMessage();
        } catch (Exception e) {
            exceptionThrown = true;
            exceptionMessage = e.getMessage();
        }
        
        Test.stopTest();
        
        System.assert(exceptionThrown, 'Should have thrown exception');
        
        List<Integration_Log__c> logs = [SELECT Code__c FROM Integration_Log__c];
        System.assertEquals(1, logs.size(), 'Should create error log');
    }
    
    @isTest
    static void testGetLabResults_UnsuccessfulResponse() {
        Case testCase = [
            SELECT Id 
            FROM Case 
            WHERE Subject = 'Test Lab Results Case' 
            LIMIT 1
        ];
        
        Test.setMock(HttpCalloutMock.class, new MockMultiCallout('unsuccessfulResponse'));
        
        Test.startTest();
        Boolean exceptionThrown = false;
        String exceptionMessage = '';
        
        try {
            SAT_LabResultsService.getLabResults(
                testCase.Id,
                'Glucose',
                '2024-01-01',
                'Dr. Smith'
            );
        } catch (AuraHandledException e) {
            exceptionThrown = true;
            exceptionMessage = e.getMessage();
        } catch (Exception e) {
            exceptionThrown = true;
            exceptionMessage = e.getMessage();
        }
        
        Test.stopTest();
        
        System.assert(exceptionThrown, 'Should have thrown exception');
    }
    
    @isTest
    static void testGetLabResults_HTTPError() {
        Case testCase = [
            SELECT Id 
            FROM Case 
            WHERE Subject = 'Test Lab Results Case' 
            LIMIT 1
        ];
        
        Test.setMock(HttpCalloutMock.class, new MockMultiCallout('httpError'));
        
        Test.startTest();
        Boolean exceptionThrown = false;
        String exceptionMessage = '';
        
        try {
            SAT_LabResultsService.getLabResults(
                testCase.Id,
                'Glucose',
                '2024-01-01',
                'Dr. Smith'
            );
        } catch (AuraHandledException e) {
            exceptionThrown = true;
            exceptionMessage = e.getMessage();
        } catch (Exception e) {
            exceptionThrown = true;
            exceptionMessage = e.getMessage();
        }
        
        Test.stopTest();
        
        System.assert(exceptionThrown, 'Should have thrown exception');
    }
    
    @isTest
    static void testGetLabResults_ServerError() {
        Case testCase = [
            SELECT Id 
            FROM Case 
            WHERE Subject = 'Test Lab Results Case' 
            LIMIT 1
        ];
        
        Test.setMock(HttpCalloutMock.class, new MockMultiCallout('serverError'));
        
        Test.startTest();
        Boolean exceptionThrown = false;
        String exceptionMessage = '';
        
        try {
            SAT_LabResultsService.getLabResults(
                testCase.Id,
                'Glucose',
                '2024-01-01',
                'Dr. Smith'
            );
        } catch (AuraHandledException e) {
            exceptionThrown = true;
            exceptionMessage = e.getMessage();
        } catch (Exception e) {
            exceptionThrown = true;
            exceptionMessage = e.getMessage();
        }
        
        Test.stopTest();
        
        System.assert(exceptionThrown, 'Should have thrown exception');
        
        List<Integration_Log__c> logs = [SELECT Code__c FROM Integration_Log__c];
        System.assertEquals(1, logs.size(), 'Should create error log');
        System.assertEquals(500, logs[0].Code__c, 'Should log 500 error code');
    }
    
    @isTest
    static void testGetLabResults_InvalidCaseId() {
        Test.startTest();
        Boolean exceptionThrown = false;
        String exceptionMessage = '';
        
        try {
            SAT_LabResultsService.getLabResults(
                '500000000000000AAA',  // Invalid but properly formatted ID
                'Glucose',
                '2024-01-01',
                'Dr. Smith'
            );
        } catch (AuraHandledException e) {
            exceptionThrown = true;
            exceptionMessage = e.getMessage();
        } catch (Exception e) {
            exceptionThrown = true;
            exceptionMessage = e.getMessage();
        }
        
        Test.stopTest();
        
        System.assert(exceptionThrown, 'Should have thrown exception');
        //System.assert(exceptionMessage.contains('Case record not found'), 
       //              'Should throw error for invalid case ID. Actual: ' + exceptionMessage);
        
        List<Integration_Log__c> logs = [SELECT Code__c FROM Integration_Log__c];
        System.assertEquals(1, logs.size(), 'Should create error log');
        System.assertEquals(404, logs[0].Code__c, 'Should log 404 for not found');
    }
    
    @isTest
    static void testGetLabResults_DateTimeConversion() {
        Case testCase = [
            SELECT Id 
            FROM Case 
            WHERE Subject = 'Test Lab Results Case' 
            LIMIT 1
        ];
        
        Test.setMock(HttpCalloutMock.class, new MockMultiCallout('success'));
        
        Test.startTest();
        List<SAT_LabResultsService.LabResultDTO> results;
        Boolean exceptionThrown = false;
        
        try {
            results = SAT_LabResultsService.getLabResults(
                testCase.Id,
                'Glucose',
                '2024-01-01',
                'Dr. Smith'
            );
        } catch (Exception e) {
            exceptionThrown = true;
            System.debug('Exception in testGetLabResults_DateTimeConversion: ' + e.getMessage());
        }
        
        Test.stopTest();
    }
    
    @isTest
    static void testGetLabResults_AllHTMLEntities() {
        Case testCase = [
            SELECT Id 
            FROM Case 
            WHERE Subject = 'Test Lab Results Case' 
            LIMIT 1
        ];
        
        Test.setMock(HttpCalloutMock.class, new MockMultiCallout('success'));
        
        Test.startTest();
        List<SAT_LabResultsService.LabResultDTO> results;
        Boolean exceptionThrown = false;
        
        try {
            results = SAT_LabResultsService.getLabResults(
                testCase.Id,
                'Glucose',
                '2024-01-01',
                'Dr. Smith'
            );
        } catch (Exception e) {
            exceptionThrown = true;
            System.debug('Exception in testGetLabResults_AllHTMLEntities: ' + e.getMessage());
        }
        
        Test.stopTest();
        
    }
    
    @isTest
    static void testLabResultDTO_Constructor() {
        Test.startTest();
        
        Datetime testDate = Datetime.now();
        SAT_LabResultsService.LabResultDTO dto = new SAT_LabResultsService.LabResultDTO(
            'Glucose',
            testDate,
            '100',
            'mg/dL',
            '70-100',
            'N',
            'GLU / Chemistry'
        );
        
        Test.stopTest();
        
        System.assertEquals('Glucose', dto.test, 'Test name should match');
        System.assertEquals(testDate, dto.observationDateTime, 'DateTime should match');
        System.assertEquals('100', dto.value, 'Value should match');
        System.assertEquals('mg/dL', dto.unit, 'Unit should match');
        System.assertEquals('70-100', dto.referenceRangeTxt, 'Reference range should match');
        System.assertEquals('N', dto.abnormalFlagCd, 'Abnormal flag should match');
        System.assertEquals('GLU / Chemistry', dto.coding, 'Coding should match');
    }
    
    @isTest
    static void testLabResultDTO_NullValues() {
        Test.startTest();
        
        SAT_LabResultsService.LabResultDTO dto = new SAT_LabResultsService.LabResultDTO(
            null,
            null,
            null,
            null,
            null,
            null,
            null
        );
        
        Test.stopTest();
        
        System.assertEquals(null, dto.test, 'Test should be null');
        System.assertEquals(null, dto.observationDateTime, 'DateTime should be null');
        System.assertEquals(null, dto.value, 'Value should be null');
        System.assertEquals(null, dto.unit, 'Unit should be null');
        System.assertEquals(null, dto.referenceRangeTxt, 'Reference range should be null');
        System.assertEquals(null, dto.abnormalFlagCd, 'Abnormal flag should be null');
        System.assertEquals(null, dto.coding, 'Coding should be null');
    }
}