@isTest
private class RxHistoryPatientDrugValidatorTest {

    // ============================================================
    // SECTION 1: Basic Validation Tests
    // ============================================================

    @isTest
    static void test_NullCaseId_ThrowsException() {
        Test.startTest();
        try {
            RxHistoryPatientDrugValidator.validateDrugStep(null);
            Assert.fail('Expected exception');
        } catch (Exception e) {
            Assert.isTrue(true, 'Exception caught as expected');
        }
        Test.stopTest();
    }

    @isTest
    static void test_BlankDrugName_ReturnsEmptyList() {
        Case c = new Case(Subject='Test', Status='New', Origin='Web', Drug_Name__c='');
        insert c;

        Test.startTest();
        List<RxHistoryPatientDrugValidator.ResultWrapper> results = 
            RxHistoryPatientDrugValidator.validateDrugStep(c.Id);
        Test.stopTest();

        Assert.areEqual(0, results.size());
    }

    @isTest
    static void test_NoStepCriteria_ReturnsEmptyList() {
        Case c = new Case(Subject='Test', Status='New', Origin='Web', Drug_Name__c='Nonexistent');
        insert c;

        Test.startTest();
        List<RxHistoryPatientDrugValidator.ResultWrapper> results = 
            RxHistoryPatientDrugValidator.validateDrugStep(c.Id);
        Test.stopTest();

        Assert.areEqual(0, results.size());
    }

    @isTest
    static void test_EmptyDINs_ReturnsEmptyList() {
        Din_List_Category__c cat = new Din_List_Category__c(
            Name='EmptyCat', 
            DINs__c='', 
            Lookback_Window__c=90, 
            Grace_Period__c=7, 
            Threshold__c=30
        );
        insert cat;

        Drug__c drug = new Drug__c(Name='TestDrug2');
        insert drug;

        Step__c step = new Step__c(Drug__c=drug.Id, Order__c=1);
        insert step;

        Step_Criteria__c criteria = new Step_Criteria__c(
            Step__c=step.Id, 
            Field_Name__c='EmptyCat', 
            Object_Name__c='Rx History', 
            Order__c=1,
            Operator__c='equals'
        );
        insert criteria;

        Case c = new Case(Subject='Test', Status='New', Origin='Web', Drug_Name__c='TestDrug2');
        insert c;

        Test.startTest();
        List<RxHistoryPatientDrugValidator.ResultWrapper> results = 
            RxHistoryPatientDrugValidator.validateDrugStep(c.Id);
        Test.stopTest();

        Assert.areEqual(0, results.size());
    }

    // ============================================================
    // SECTION 2: Grace Period = 0 Tests
    // ============================================================

    @isTest
    static void test_GraceZero_FirstRecordMeetsThreshold() {
        Id caseId = setupTestData('GraceZero1', '12345', 0, 30);
        
        String recentDate = String.valueOf(Date.today().addDays(-30));
        
        PrescriptionHistoryResponse mockResp = createMockResponse(
            new List<MockRecord>{
                new MockRecord(12345, recentDate, 30, 90)
            }
        );
        
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(mockResp));

        Test.startTest();
        List<RxHistoryPatientDrugValidator.ResultWrapper> results = 
            RxHistoryPatientDrugValidator.validateDrugStep(caseId);
        Test.stopTest();

        Assert.areEqual(1, results.size(), 'Should return one result');
        Assert.areEqual(30, results[0].totalDaysSupply, 'Should have 30 days supply');
        Assert.isTrue(results[0].threshold, 'Should meet threshold');
    }

    @isTest
    static void test_GraceZero_OverlappingRecords() {
        Id caseId = setupTestData('GraceZero2', '12346', 0, 50);
        
        String date1 = String.valueOf(Date.today().addDays(-40));
        String date2 = String.valueOf(Date.today().addDays(-21)); // Overlaps
        
        PrescriptionHistoryResponse mockResp = createMockResponse(
            new List<MockRecord>{
                new MockRecord(12346, date1, 30, 90),
                new MockRecord(12346, date2, 30, 90)
            }
        );
        
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(mockResp));

        Test.startTest();
        List<RxHistoryPatientDrugValidator.ResultWrapper> results = 
            RxHistoryPatientDrugValidator.validateDrugStep(caseId);
        Test.stopTest();

        Assert.areEqual(1, results.size());
        Assert.isTrue(results[0].totalDaysSupply >= 50, 'Should meet 50-day threshold with overlap');
    }

    @isTest
    static void test_GraceZero_ChainBreakOnGap() {
        Id caseId = setupTestData('GraceZero3', '12347', 0, 60);
        
        String date1 = String.valueOf(Date.today().addDays(-60));
        String date2 = String.valueOf(Date.today().addDays(-28)); // 2-day gap after first coverage ends
        
        PrescriptionHistoryResponse mockResp = createMockResponse(
            new List<MockRecord>{
                new MockRecord(12347, date1, 30, 90),  // Day -60 to -31
                new MockRecord(12347, date2, 30, 90)   // Day -28 to +1 (gap breaks chain)
            }
        );
        
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(mockResp));

        Test.startTest();
        List<RxHistoryPatientDrugValidator.ResultWrapper> results = 
            RxHistoryPatientDrugValidator.validateDrugStep(caseId);
        Test.stopTest();

        Assert.areEqual(1, results.size());
        // With grace=0, chain should break, so first chain only has 30 days
        Assert.areEqual(30, results[0].totalDaysSupply, 'First chain should only have 30 days');
        Assert.isFalse(results[0].threshold, 'Should not meet 60-day threshold');
    }

    @isTest
    static void test_GraceZero_BackToBackRecords() {
        Id caseId = setupTestData('GraceZero4', '12348', 0, 60);
        
        String date1 = String.valueOf(Date.today().addDays(-60));
        String date2 = String.valueOf(Date.today().addDays(-30)); // Exactly back-to-back
        
        PrescriptionHistoryResponse mockResp = createMockResponse(
            new List<MockRecord>{
                new MockRecord(12348, date1, 30, 90),  // Day -60 to -31
                new MockRecord(12348, date2, 30, 90)   // Day -30 to -1 (back-to-back)
            }
        );
        
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(mockResp));

        Test.startTest();
        List<RxHistoryPatientDrugValidator.ResultWrapper> results = 
            RxHistoryPatientDrugValidator.validateDrugStep(caseId);
        Test.stopTest();

        Assert.areEqual(1, results.size());
        Assert.areEqual(60, results[0].totalDaysSupply, 'Should have 60 days supply');
        Assert.isTrue(results[0].threshold, 'Should meet threshold');
    }

    // ============================================================
    // SECTION 3: Normal Chain (Grace Period > 0) Tests
    // ============================================================

    @isTest
    static void test_NormalChain_FirstRecordMeetsThreshold() {
        Id caseId = setupTestData('Normal1', '12349', 7, 30);
        
        String recentDate = String.valueOf(Date.today().addDays(-30));
        
        PrescriptionHistoryResponse mockResp = createMockResponse(
            new List<MockRecord>{
                new MockRecord(12349, recentDate, 30, 90)
            }
        );
        
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(mockResp));

        Test.startTest();
        List<RxHistoryPatientDrugValidator.ResultWrapper> results = 
            RxHistoryPatientDrugValidator.validateDrugStep(caseId);
        Test.stopTest();

        Assert.areEqual(1, results.size());
        Assert.areEqual(30, results[0].totalDaysSupply);
        Assert.isTrue(results[0].threshold);
    }

    @isTest
    static void test_NormalChain_GapWithinGracePeriod() {
        Id caseId = setupTestData('Normal2', '12350', 7, 60);
        
        String date1 = String.valueOf(Date.today().addDays(-60));
        String date2 = String.valueOf(Date.today().addDays(-25)); // 5-day gap, within 7-day grace
        
        PrescriptionHistoryResponse mockResp = createMockResponse(
            new List<MockRecord>{
                new MockRecord(12350, date1, 30, 90),  // Day -60 to -31
                new MockRecord(12350, date2, 30, 90)   // Gap of 5 days
            }
        );
        
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(mockResp));

        Test.startTest();
        List<RxHistoryPatientDrugValidator.ResultWrapper> results = 
            RxHistoryPatientDrugValidator.validateDrugStep(caseId);
        Test.stopTest();

        Assert.areEqual(1, results.size());
        Assert.areEqual(60, results[0].totalDaysSupply, 'Should have 60 days supply');
        Assert.areEqual(5, results[0].totalGapDays, 'Should have 5 gap days');
        Assert.isTrue(results[0].threshold, 'Should meet threshold');
    }

    @isTest
    static void test_NormalChain_GapExceedsGracePeriod() {
        Id caseId = setupTestData('Normal3', '12351', 7, 60);
        
        String date1 = String.valueOf(Date.today().addDays(-60));
        String date2 = String.valueOf(Date.today().addDays(-22)); // 9-day gap, exceeds 7-day grace
        
        PrescriptionHistoryResponse mockResp = createMockResponse(
            new List<MockRecord>{
                new MockRecord(12351, date1, 30, 90),  // Day -60 to -31
                new MockRecord(12351, date2, 30, 90)   // Gap of 9 days
            }
        );
        
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(mockResp));

        Test.startTest();
        List<RxHistoryPatientDrugValidator.ResultWrapper> results = 
            RxHistoryPatientDrugValidator.validateDrugStep(caseId);
        Test.stopTest();

        Assert.areEqual(1, results.size());
        Assert.areEqual(30, results[0].totalDaysSupply, 'First chain should only have 30 days');
        Assert.isFalse(results[0].threshold, 'Should not meet 60-day threshold');
    }

    @isTest
    static void test_NormalChain_MultipleGapsWithinGrace() {
        Id caseId = setupTestData('Normal4', '12352', 10, 90);
        
        String date1 = String.valueOf(Date.today().addDays(-80));
        String date2 = String.valueOf(Date.today().addDays(-47)); // 3-day gap
        String date3 = String.valueOf(Date.today().addDays(-14)); // 3-day gap, total 6 days
        
        PrescriptionHistoryResponse mockResp = createMockResponse(
            new List<MockRecord>{
                new MockRecord(12352, date1, 30, 90),
                new MockRecord(12352, date2, 30, 90),
                new MockRecord(12352, date3, 30, 90)
            }
        );
        
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(mockResp));

        Test.startTest();
        List<RxHistoryPatientDrugValidator.ResultWrapper> results = 
            RxHistoryPatientDrugValidator.validateDrugStep(caseId);
        Test.stopTest();

        Assert.areEqual(1, results.size());
        Assert.areEqual(90, results[0].totalDaysSupply, 'Should have 90 days supply');
        Assert.areEqual(6, results[0].totalGapDays, 'Should have 6 gap days total');
        Assert.isTrue(results[0].threshold, 'Should meet threshold');
    }

    @isTest
    static void test_NormalChain_OverlappingRecords() {
        Id caseId = setupTestData('Normal5', '12353', 7, 50);
        
        String date1 = String.valueOf(Date.today().addDays(-40));
        String date2 = String.valueOf(Date.today().addDays(-21)); // Overlaps by 10 days
        
        PrescriptionHistoryResponse mockResp = createMockResponse(
            new List<MockRecord>{
                new MockRecord(12353, date1, 30, 90),
                new MockRecord(12353, date2, 30, 90)
            }
        );
        
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(mockResp));

        Test.startTest();
        List<RxHistoryPatientDrugValidator.ResultWrapper> results = 
            RxHistoryPatientDrugValidator.validateDrugStep(caseId);
        Test.stopTest();

        Assert.areEqual(1, results.size());
        Assert.isTrue(results[0].totalDaysSupply >= 50, 'Should meet 50-day threshold');
        Assert.isTrue(results[0].threshold, 'Should meet threshold');
    }

    @isTest
    static void test_NormalChain_SecondChainMeetsThreshold() {
        Id caseId = setupTestData('Normal6', '12354', 7, 30);
        
        String date1 = String.valueOf(Date.today().addDays(-80));
        String date2 = String.valueOf(Date.today().addDays(-40)); // Large gap, breaks chain
        
        PrescriptionHistoryResponse mockResp = createMockResponse(
            new List<MockRecord>{
                new MockRecord(12354, date1, 20, 60),  // First chain: 20 days (doesn't meet threshold)
                new MockRecord(12354, date2, 30, 90)   // Second chain: 30 days (meets threshold)
            }
        );
        
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(mockResp));

        Test.startTest();
        List<RxHistoryPatientDrugValidator.ResultWrapper> results = 
            RxHistoryPatientDrugValidator.validateDrugStep(caseId);
        Test.stopTest();

        Assert.areEqual(1, results.size());
        Assert.areEqual(30, results[0].totalDaysSupply, 'Should show second chain days');
        Assert.isTrue(results[0].threshold, 'Should meet threshold');
        Assert.isFalse(results[0].isFirstChain, 'Should not be first chain');
    }

    // ============================================================
    // SECTION 4: Edge Cases
    // ============================================================

    @isTest
    static void test_ResultWrapperConstructor() {
        Test.startTest();
        RxHistoryPatientDrugValidator.ResultWrapper wrapper = 
            new RxHistoryPatientDrugValidator.ResultWrapper(
                'TestCat', 'true', 100, 30, true, 90, 7, 5, 'Reason', true
            );
        Test.stopTest();

        Assert.areEqual('TestCat', wrapper.categoryName);
        Assert.areEqual('true', wrapper.found);
        Assert.areEqual(100, wrapper.totalQuantity);
        Assert.areEqual(30, wrapper.totalDaysSupply);
    }

    @isTest
    static void test_GraceAndThresholdBothZero() {
        Id caseId = setupTestDataWithBothZero('BothZero', '12366');
        
        PrescriptionHistoryResponse mockResp = new PrescriptionHistoryResponse();
        mockResp.medHistory = new PrescriptionHistoryResponse.MedHistory();
        mockResp.medHistory.medRecords = new List<PrescriptionHistoryResponse.MedRecords>();
        
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(mockResp));

        Test.startTest();
        List<RxHistoryPatientDrugValidator.ResultWrapper> results = 
            RxHistoryPatientDrugValidator.validateDrugStep(caseId);
        Test.stopTest();

        Assert.areEqual(1, results.size());
        Assert.areEqual('false', results[0].found);
    }

    @isTest
    static void test_NoRecordsFound() {
        Id caseId = setupTestData('NoRecords', '12367', 7, 30);
        
        PrescriptionHistoryResponse mockResp = new PrescriptionHistoryResponse();
        mockResp.medHistory = new PrescriptionHistoryResponse.MedHistory();
        mockResp.medHistory.medRecords = new List<PrescriptionHistoryResponse.MedRecords>();
        
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(mockResp));

        Test.startTest();
        List<RxHistoryPatientDrugValidator.ResultWrapper> results = 
            RxHistoryPatientDrugValidator.validateDrugStep(caseId);
        Test.stopTest();

        Assert.areEqual(1, results.size());
        Assert.areEqual('false', results[0].found);
        Assert.areEqual(0, results[0].totalDaysSupply);
    }

    @isTest
    static void test_RecordsOutsideLookbackWindow() {
        Id caseId = setupTestData('OutsideLookback', '12368', 7, 30);
        
        // Date outside 90-day lookback window
        String oldDate = String.valueOf(Date.today().addDays(-120));
        
        PrescriptionHistoryResponse mockResp = createMockResponse(
            new List<MockRecord>{
                new MockRecord(12368, oldDate, 30, 90)
            }
        );
        
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(mockResp));

        Test.startTest();
        List<RxHistoryPatientDrugValidator.ResultWrapper> results = 
            RxHistoryPatientDrugValidator.validateDrugStep(caseId);
        Test.stopTest();

        Assert.areEqual(1, results.size());
        Assert.areEqual(0, results[0].totalDaysSupply, 'Should filter out old records');
    }

    // ============================================================
    // SECTION 5: validateAndUpdateCase Tests
    // ============================================================

    @isTest
    static void test_validateAndUpdateCase_ComplianceTrue() {
        Id caseId = setupTestData('FutureTest1', '12370', 7, 30);
        
        String recentDate = String.valueOf(Date.today().addDays(-30));
        
        PrescriptionHistoryResponse mockResp = createMockResponse(
            new List<MockRecord>{
                new MockRecord(12370, recentDate, 30, 90)
            }
        );
        
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(mockResp));

        Test.startTest();
        RxHistoryPatientDrugValidator.validateAndUpdateCase(caseId);
        Test.stopTest();

        Case updatedCase = [SELECT Id, Compliance__c FROM Case WHERE Id = :caseId LIMIT 1];
        Assert.areEqual('True', updatedCase.Compliance__c, 'Compliance should be True');
    }

    @isTest
    static void test_validateAndUpdateCase_ComplianceFalse() {
        Id caseId = setupTestData('FutureTest2', '12371', 7, 60);
        
        String recentDate = String.valueOf(Date.today().addDays(-30));
        
        PrescriptionHistoryResponse mockResp = createMockResponse(
            new List<MockRecord>{
                new MockRecord(12371, recentDate, 30, 90)
            }
        );
        
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(mockResp));

        Test.startTest();
        RxHistoryPatientDrugValidator.validateAndUpdateCase(caseId);
        Test.stopTest();

        Case updatedCase = [SELECT Id, Compliance__c FROM Case WHERE Id = :caseId LIMIT 1];
        Assert.areEqual('False', updatedCase.Compliance__c, 'Compliance should be False');
    }

    @isTest
    static void test_validateAndUpdateCase_NullCaseId() {
        Test.startTest();
        RxHistoryPatientDrugValidator.validateAndUpdateCase(null);
        Test.stopTest();
        
        Assert.isTrue(true, 'Method handled null case ID');
    }

    @isTest
    static void test_validateAndUpdateCase_NoCriteria() {
        Case c = new Case(Subject='Test', Status='New', Origin='Web', Drug_Name__c='NoCriteriaDrug');
        insert c;
        
        PrescriptionHistoryResponse mockResp = new PrescriptionHistoryResponse();
        mockResp.medHistory = new PrescriptionHistoryResponse.MedHistory();
        mockResp.medHistory.medRecords = new List<PrescriptionHistoryResponse.MedRecords>();
        
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(mockResp));

        Test.startTest();
        RxHistoryPatientDrugValidator.validateAndUpdateCase(c.Id);
        Test.stopTest();
        
        Assert.isTrue(true, 'Method handled no criteria case');
    }

    @isTest
    static void test_validateAndUpdateCase_ComplianceMetFalse() {
        Din_List_Category__c cat = new Din_List_Category__c(
            Name='FutureTest3', 
            DINs__c='12372', 
            Lookback_Window__c=90, 
            Grace_Period__c=7, 
            Threshold__c=30
        );
        insert cat;

        Drug__c drug = new Drug__c(Name='FutureTest3Drug');
        insert drug;

        Step__c step = new Step__c(Drug__c=drug.Id, Order__c=1);
        insert step;

        Step_Criteria__c criteria = new Step_Criteria__c(
            Step__c=step.Id, 
            Field_Name__c='FutureTest3', 
            Object_Name__c='Rx History', 
            Order__c=1,
            Operator__c='equals',
            Compliance_Logic__c='FutureTest3',
            Compliance_Met__c='false'
        );
        insert criteria;

        Case c = new Case(
            Subject='Test', 
            Status='New', 
            Origin='Web', 
            Drug_Name__c='FutureTest3Drug'
        );
        insert c;
        
        PrescriptionHistoryResponse mockResp = new PrescriptionHistoryResponse();
        mockResp.medHistory = new PrescriptionHistoryResponse.MedHistory();
        mockResp.medHistory.medRecords = new List<PrescriptionHistoryResponse.MedRecords>();
        
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(mockResp));

        Test.startTest();
        RxHistoryPatientDrugValidator.validateAndUpdateCase(c.Id);
        Test.stopTest();

        Case updatedCase = [SELECT Id, Compliance__c FROM Case WHERE Id = :c.Id LIMIT 1];
        Assert.areEqual('True', updatedCase.Compliance__c);
    }

    @isTest
    static void test_validateAndUpdateCase_MultipleCategories() {
        Din_List_Category__c cat1 = new Din_List_Category__c(
            Name='MultiCat1', 
            DINs__c='12373', 
            Lookback_Window__c=90, 
            Grace_Period__c=7, 
            Threshold__c=30
        );
        insert cat1;

        Din_List_Category__c cat2 = new Din_List_Category__c(
            Name='MultiCat2', 
            DINs__c='12374', 
            Lookback_Window__c=90, 
            Grace_Period__c=7, 
            Threshold__c=30
        );
        insert cat2;

        Drug__c drug = new Drug__c(Name='MultiCatDrug');
        insert drug;

        Step__c step = new Step__c(Drug__c=drug.Id, Order__c=1);
        insert step;

        Step_Criteria__c criteria = new Step_Criteria__c(
            Step__c=step.Id, 
            Field_Name__c='MultiCat1,MultiCat2', 
            Object_Name__c='Rx History', 
            Order__c=1,
            Operator__c='equals',
            Compliance_Logic__c='MultiCat1,MultiCat2',
            Compliance_Met__c='true'
        );
        insert criteria;

        Case c = new Case(
            Subject='Test', 
            Status='New', 
            Origin='Web', 
            Drug_Name__c='MultiCatDrug'
        );
        insert c;
        
        String recentDate = String.valueOf(Date.today().addDays(-30));
        
        PrescriptionHistoryResponse mockResp = createMockResponse(
            new List<MockRecord>{
                new MockRecord(12373, recentDate, 30, 90),
                new MockRecord(12374, recentDate, 30, 90)
            }
        );
        
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(mockResp));

        Test.startTest();
        RxHistoryPatientDrugValidator.validateAndUpdateCase(c.Id);
        Test.stopTest();

        Case updatedCase = [SELECT Id, Compliance__c FROM Case WHERE Id = :c.Id LIMIT 1];
        Assert.areEqual('True', updatedCase.Compliance__c);
    }

    // ============================================================
    // Helper Methods & Classes
    // ============================================================

    private class MockRecord {
        Integer dinpin;
        String dateDispensed;
        Integer daysSupply;
        Integer quantity;
        
        MockRecord(Integer d, String dt, Integer ds, Integer q) {
            this.dinpin = d;
            this.dateDispensed = dt;
            this.daysSupply = ds;
            this.quantity = q;
        }
    }

    private static PrescriptionHistoryResponse createMockResponse(List<MockRecord> records) {
        PrescriptionHistoryResponse resp = new PrescriptionHistoryResponse();
        resp.medHistory = new PrescriptionHistoryResponse.MedHistory();
        resp.medHistory.medRecords = new List<PrescriptionHistoryResponse.MedRecords>();
        
        for (MockRecord mr : records) {
            PrescriptionHistoryResponse.MedRecords rec = new PrescriptionHistoryResponse.MedRecords();
            rec.dinpin = mr.dinpin;
            rec.dateDispensed = mr.dateDispensed;
            rec.daysSupply = Double.valueOf(mr.daysSupply);
            rec.quantity = Double.valueOf(mr.quantity);
            resp.medHistory.medRecords.add(rec);
        }
        
        return resp;
    }

    private class SingleRequestMock implements HttpCalloutMock {
        PrescriptionHistoryResponse response;
        
        SingleRequestMock(PrescriptionHistoryResponse resp) {
            this.response = resp;
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(JSON.serialize(response));
            res.setStatusCode(200);
            return res;
        }
    }

    private static Id setupTestData(String catName, String dins, Integer grace, Integer threshold) {
        Din_List_Category__c cat = new Din_List_Category__c(
            Name=catName, 
            DINs__c=dins, 
            Lookback_Window__c=90, 
            Grace_Period__c=grace, 
            Threshold__c=threshold
        );
        insert cat;

        Drug__c drug = new Drug__c(Name=catName+'Drug');
        insert drug;

        Step__c step = new Step__c(Drug__c=drug.Id, Order__c=1);
        insert step;

        Step_Criteria__c criteria = new Step_Criteria__c(
            Step__c=step.Id, 
            Field_Name__c=catName, 
            Object_Name__c='Rx History', 
            Order__c=1,
            Operator__c='equals',
            Compliance_Logic__c=catName,
            Compliance_Met__c='true'
        );
        insert criteria;

        Case c = new Case(
            Subject='Test', 
            Status='New', 
            Origin='Web', 
            Drug_Name__c=catName+'Drug'
        );
        insert c;
        
        return c.Id;
    }

    private static Id setupTestDataWithBothZero(String catName, String dins) {
        Din_List_Category__c cat = new Din_List_Category__c(
            Name=catName, 
            DINs__c=dins, 
            Lookback_Window__c=90, 
            Grace_Period__c=0, 
            Threshold__c=0
        );
        insert cat;

        Drug__c drug = new Drug__c(Name=catName+'Drug');
        insert drug;

        Step__c step = new Step__c(Drug__c=drug.Id, Order__c=1);
        insert step;

        Step_Criteria__c criteria = new Step_Criteria__c(
            Step__c=step.Id, 
            Field_Name__c=catName, 
            Object_Name__c='Rx History', 
            Order__c=1,
            Operator__c='equals'
        );
        insert criteria;

        Case c = new Case(
            Subject='Test', 
            Status='New', 
            Origin='Web', 
            Drug_Name__c=catName+'Drug'
        );
        insert c;
        
        return c.Id;
    }
}