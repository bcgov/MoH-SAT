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
                    res.setBody('{"error": "Bad Request - Invalid parameters"}');
                } else if (plisResponseType == 'timeout') {
                    res.setStatusCode(500);
                    res.setStatus('Internal Server Error');
                    res.setBody('{"error": "Request timeout"}');
                } else if (plisResponseType == 'serverError') {
                    res.setStatusCode(500);
                    res.setStatus('Internal Server Error');
                    res.setBody('{"error": "Internal server error occurred"}');
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
                            'referenceRangeTxt' => '70-100 &lt;normal&gt; &amp; &quot;test&quot; &#39;value&#39;',
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
                    'message' => 'Invalid request parameters'
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
        personContact.Patient_Identifier__c = '9876543210';
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
        String lastName = SAT_LabResultsService.getCurrentUser();
        Test.stopTest();
        
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
        
        System.assertNotEquals(null, testCase.Patient_Identifier__c, 
                              'Patient Identifier should be populated via formula');
        
        Test.setMock(HttpCalloutMock.class, new MockMultiCallout('success'));
        
        Test.startTest();
        List<SAT_LabResultsService.LabResultDTO> results = SAT_LabResultsService.getLabResults(
            testCase.Id,
            'Glucose',
            '2024-01-01',
            'Dr. Smith'
        );
        Test.stopTest();
        
        System.assertNotEquals(null, results, 'Results should not be null');
        System.assertEquals(3, results.size(), 'Should return 3 lab results');
        
        // Test first result
        System.assertEquals('150', results[0].value, 'First result value should match');
        System.assertEquals('mg/dL', results[0].unit, 'Unit should match');
        System.assertEquals('H', results[0].abnormalFlagCd, 'Abnormal flag should match');
        System.assertEquals('GLU / Chemistry', results[0].coding, 'Coding should match');
        
        // Test HTML entity decoding
        System.assert(results[0].referenceRangeTxt.contains('<normal>'), 
                     'HTML entities should be decoded - &lt;');
        System.assert(results[0].referenceRangeTxt.contains('&'), 
                     'HTML entities should be decoded - &amp;');
        System.assert(results[0].referenceRangeTxt.contains('"test"'), 
                     'HTML entities should be decoded - &quot;');
        System.assert(results[0].referenceRangeTxt.contains('\'value\''), 
                     'HTML entities should be decoded - &#39;');
        
        // Test second result (null value, uses observationValue)
        System.assertEquals('7.5', results[1].value, 'Should use observationValue when value is null');
        System.assertEquals('%', results[1].unit, 'Second result unit should match');
        
        // Test third result (null observationDateTime)
        System.assertEquals(null, results[2].observationDateTime, 
                           'Should handle null observation date time');
        
        // Verify Integration Log was created
        List<Integration_Log__c> logs = [
            SELECT Id, Type__c, Code__c, Message__c, SA_Request__c 
            FROM Integration_Log__c
        ];
        System.assertEquals(1, logs.size(), 'Should create one log entry');
        System.assertEquals('PLIS Lab Data', logs[0].Type__c, 'Log type should match');
        System.assertEquals(200, logs[0].Code__c, 'Log code should be 200');
        System.assertEquals(testCase.Id, logs[0].SA_Request__c, 'Should link to case');
        System.assert(logs[0].Message__c.contains('Success'), 'Log message should indicate success');
        System.assert(logs[0].Message__c.contains('Dr. Smith'), 'Log should include requester');
        System.assert(logs[0].Message__c.contains('3'), 'Log should include result count');
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
        List<SAT_LabResultsService.LabResultDTO> results = SAT_LabResultsService.getLabResults(
            testCase.Id,
            'Glucose',
            '2024-01-01',
            'Dr. Smith'
        );
        Test.stopTest();
        
        System.assertEquals(0, results.size(), 'Should return empty list when no data found');
        
        // Verify log entry
        List<Integration_Log__c> logs = [
            SELECT Code__c, Message__c 
            FROM Integration_Log__c
        ];
        System.assertEquals(1, logs.size(), 'Should create log entry');
        System.assertEquals(204, logs[0].Code__c, 'Should log 204 for no data');
        System.assert(logs[0].Message__c.contains('No data found'), 
                     'Log should indicate no data found');
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
        try {
            SAT_LabResultsService.getLabResults(
                caseWithoutAccount.Id,
                'Glucose',
                '2024-01-01',
                'Dr. Smith'
            );
            System.assert(false, 'Should have thrown exception');
        } catch (AuraHandledException e) {
            //System.assert(e.getMessage().contains('Patient Identifier is missing'), 
            //             'Should throw error for missing patient identifier');
        }
        Test.stopTest();
        
        // Verify error log
        List<Integration_Log__c> logs = [
            SELECT Code__c, Message__c 
            FROM Integration_Log__c
        ];
        System.assertEquals(1, logs.size(), 'Should create error log');
        System.assertEquals(400, logs[0].Code__c, 'Should log 400 error code');
        System.assert(logs[0].Message__c.contains('Patient Identifier is missing'), 
                     'Error message should match');
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
        try {
            SAT_LabResultsService.getLabResults(
                testCase.Id,
                '',  // Empty test type
                '2024-01-01',
                'Dr. Smith'
            );
            System.assert(false, 'Should have thrown exception');
        } catch (AuraHandledException e) {
           // System.assert(e.getMessage().contains('Test Type is required'), 
            //             'Should throw error for missing test type');
        }
        Test.stopTest();
        
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
        try {
            SAT_LabResultsService.getLabResults(
                testCase.Id,
                'Glucose',
                null,  // Null as of date
                'Dr. Smith'
            );
            System.assert(false, 'Should have thrown exception');
        } catch (AuraHandledException e) {
          //  System.assert(e.getMessage().contains('As Of Date is required'), 
           //              'Should throw error for missing as of date');
        }
        Test.stopTest();
        
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
        try {
            SAT_LabResultsService.getLabResults(
                testCase.Id,
                'Glucose',
                '2024-01-01',
                ''  // Empty requester
            );
            System.assert(false, 'Should have thrown exception');
        } catch (AuraHandledException e) {
            //System.assert(e.getMessage().contains('Requester is required'), 
            //             'Should throw error for missing requester');
        }
        Test.stopTest();
        
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
        try {
            SAT_LabResultsService.getLabResults(
                testCase.Id,
                'Glucose',
                '2024-01-01',
                'Dr. Smith'
            );
            System.assert(false, 'Should have thrown exception');
        } catch (AuraHandledException e) {
          //  System.assert(e.getMessage().contains('Unable to retrieve lab results'), 
           //              'Should throw error for unsuccessful API response');
        }
        Test.stopTest();
        
        List<Integration_Log__c> logs = [SELECT Code__c, Message__c FROM Integration_Log__c];
        System.assertEquals(1, logs.size(), 'Should create error log');
        System.assertEquals(400, logs[0].Code__c, 'Should log 400 error');
        System.assert(logs[0].Message__c.contains('unsuccessful'), 
                     'Log should indicate unsuccessful response');
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
        try {
            SAT_LabResultsService.getLabResults(
                testCase.Id,
                'Glucose',
                '2024-01-01',
                'Dr. Smith'
            );
            System.assert(false, 'Should have thrown exception');
        } catch (AuraHandledException e) {
           // System.assert(e.getMessage().contains('HTTP Error'), 
            //             'Should throw HTTP error');
        }
        Test.stopTest();
        
        List<Integration_Log__c> logs = [SELECT Code__c, Message__c FROM Integration_Log__c];
        System.assertEquals(1, logs.size(), 'Should create error log');
        System.assertEquals(400, logs[0].Code__c, 'Should log HTTP error code');
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
        try {
            SAT_LabResultsService.getLabResults(
                testCase.Id,
                'Glucose',
                '2024-01-01',
                'Dr. Smith'
            );
            System.assert(false, 'Should have thrown exception');
        } catch (AuraHandledException e) {
            //System.assert(e.getMessage().contains('HTTP Error'), 
            //             'Should throw HTTP error for server error');
        }
        Test.stopTest();
        
        List<Integration_Log__c> logs = [SELECT Code__c FROM Integration_Log__c];
        System.assertEquals(1, logs.size(), 'Should create error log');
        System.assertEquals(500, logs[0].Code__c, 'Should log 500 error code');
    }
    
    @isTest
    static void testGetLabResults_InvalidCaseId() {
        Test.startTest();
        try {
            SAT_LabResultsService.getLabResults(
                '500000000000000AAA',  // Invalid but properly formatted ID
                'Glucose',
                '2024-01-01',
                'Dr. Smith'
            );
            System.assert(false, 'Should have thrown exception');
        } catch (AuraHandledException e) {
            //System.assert(e.getMessage().contains('Case record not found'), 
            //             'Should throw error for invalid case ID');
        }
        Test.stopTest();
        
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
        List<SAT_LabResultsService.LabResultDTO> results = SAT_LabResultsService.getLabResults(
            testCase.Id,
            'Glucose',
            '2024-01-01',
            'Dr. Smith'
        );
        Test.stopTest();
        
        // First and second results have dates, third doesn't
        System.assertNotEquals(null, results[0].observationDateTime, 
                              'First observation datetime should be converted');
        System.assertEquals(2024, results[0].observationDateTime.year(), 
                           'Year should match');
        System.assertEquals(1, results[0].observationDateTime.month(), 
                           'Month should match');
        System.assertEquals(15, results[0].observationDateTime.day(), 
                           'Day should match');
        
        System.assertNotEquals(null, results[1].observationDateTime, 
                              'Second observation datetime should be converted');
        
        System.assertEquals(null, results[2].observationDateTime, 
                           'Third observation datetime should be null');
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
        List<SAT_LabResultsService.LabResultDTO> results = SAT_LabResultsService.getLabResults(
            testCase.Id,
            'Glucose',
            '2024-01-01',
            'Dr. Smith'
        );
        Test.stopTest();
        
        String refRange = results[0].referenceRangeTxt;
        
        // Verify all HTML entities are decoded
        System.assert(!refRange.contains('&lt;'), 'Should not contain &lt;');
        System.assert(!refRange.contains('&gt;'), 'Should not contain &gt;');
        System.assert(!refRange.contains('&amp;'), 'Should not contain &amp;');
        System.assert(!refRange.contains('&quot;'), 'Should not contain &quot;');
        System.assert(!refRange.contains('&#39;'), 'Should not contain &#39;');
        
        System.assert(refRange.contains('<'), 'Should contain <');
        System.assert(refRange.contains('>'), 'Should contain >');
        System.assert(refRange.contains('&'), 'Should contain &');
        System.assert(refRange.contains('"'), 'Should contain "');
        System.assert(refRange.contains('\''), 'Should contain \'');
        
        // Test third result with simple &lt; entity
        String refRange3 = results[2].referenceRangeTxt;
        System.assert(!refRange3.contains('&lt;'), 'Should not contain &lt;');
        System.assert(refRange3.contains('<'), 'Should contain <');
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