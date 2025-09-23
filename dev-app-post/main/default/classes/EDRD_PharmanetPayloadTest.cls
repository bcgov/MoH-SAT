/*-------------------------------------------------------------------
Test Class Name : EDRD_PharmanetPayloadTest
Main Class Name : EDRD_PharmanetPayload
Reference Class : EDRD_PharmanetPayload/EDRD_PharmanetWrapper/ESA_cls_constants
Purpose : Submit the Data in PharmaNet.
Version : 1.0
Devloper Name : Accenture.
Date : 20/Feb/2025
--------------------------------------------------------------------------*/
@isTest
private class EDRD_PharmanetPayloadTest {
    
    @IsTest(SeeAllData=true)
    static void testGetPharmanetDecisionTable() {        
        
        String jsonInput = '{"input":{"caseType":"New","orginalTerminationDate":"2025-02-27","indication":"cystic fibrosis - CF","phn":"9879449988","caseFundingStartdate":"2025-02-01","caseId":"500Aq00000Q5UXyIAN","caseStatus":"Funding Approved","casePushToPnet":true,"practId":"0A0P1","terminationDate":"2027-01-31","medicationName":"elexacaftor/tezacaftor/ivacaftor - Trikafta"},"output":{},"option":{}}'; 
        String methodName = 'getPharmanetDecisionTable';
        Map<String, Object> inputMap = (Map<String, Object>) JSON.deserializeUntyped(jsonInput);

        EDRD_PharmanetPayload payload = new EDRD_PharmanetPayload();
        Test.startTest();
        payload.call(methodName, inputMap);        
        Test.stopTest();
    }
    
    // Test for UpdateSubmitPharmanet
    @isTest
    static void testUpdateSubmitAndSubmitallPharmanet() {
        
      Case testCase = new Case(
            Status = 'New',
            Subject = ESA_cls_constants.FundingApproved,
            Priority = 'High',
            Origin = 'Email'
           );
        insert testCase;
        String jsonInput = '{"input":{"caseId":"'+ testCase.Id +'","din":"00614491","practId":"0A0R1","practIdRef":"91-","effectiveDate":"2025-02-14","excludedPlans":"D","justificationCodes":"0","specAuthType":"B","terminationDate":"2030-02-11","phn":"1234567890","maxDaysSupply":"23.0","maxPricePct":"100.0"},"output":{},"option":{}}'; 
        String jsonInput2 ='{"input":{"updatedAllValue":[{"_flex":{"selectedState":{},"uniqueKey":"REC0"},"caseId":"'+ testCase.Id +'","userId":"'+ UserInfo.getUserId() +'","uniqueKey":"REC0","decCode":null,"din":109,"effectiveDate":"2025-02-06","excludedPlans":"D","excludePlan":null,"justificationCodes":"0","maxDaysSupply":39,"maxPricePct":109,"phn":"1234567890","practId":"003Aq00000eHdIrIAK","practIdRef":null,"practitiner":null,"rdp":"109","specAuthType":"N","terminationDate":"2029-02-13","Id":"REC0"},{"_flex":{"selectedState":{},"uniqueKey":"REC1"},"uniqueKey":"REC1","decCode":null,"din":102,"effectiveDate":"2025-02-06","excludedPlans":"DCF","excludePlan":null,"justificationCodes":"120","maxDaysSupply":23,"maxPricePct":100,"phn":"1234567890","practId":"003Aq00000eHdIrIAK","practIdRef":null,"practitiner":null,"rdp":"105","specAuthType":"LCA","terminationDate":null,"Id":"REC1"}]}}';
        String methodName = 'updateSubmitPharmanet';
        Map<String, Object> inputMap = (Map<String, Object>) JSON.deserializeUntyped(jsonInput);
        
        String methodName2= 'updateSubmitAllPharmanet';
        Map<String, Object> inputMap2 = (Map<String, Object>) JSON.deserializeUntyped(jsonInput2);
        
        EDRD_PharmanetPayload payload = new EDRD_PharmanetPayload();
        Test.startTest();
        payload.call(methodName, inputMap);
        payload.call(methodName2,inputMap2);        
        Test.stopTest();
    }
    
    //Test for saaRequestAPICallout
    @isTest
    static void testSaaRequestAPICallout(){        
        Case testCase = new Case(
            Status = 'New',
            Subject = ESA_cls_constants.FundingApproved,
            Priority = 'High',
            Origin = 'Email'
        );
        insert testCase;
        
        EDRD_PharmanetWrapper.InputWrapper inputWrapper = new EDRD_PharmanetWrapper.InputWrapper();
        inputWrapper.terminationDate = '2050-02-06';
        inputWrapper.practId = '0A0R1';
        inputWrapper.phn = '1234567890';
        inputWrapper.caseId = testCase.Id;
        inputWrapper.practIdRef = '91-';
        inputWrapper.effectiveDate = Date.Today();
        inputWrapper.excludedPlans = 'D,G'; 
        inputWrapper.justificationCodes = '0';
        inputWrapper.specAuthType = 'B';
        inputWrapper.rdp  = '0061-4491';
        inputWrapper.maxDaysSupply = 23.0;
        inputWrapper.maxPricePct = 12.0;
        EDRD_PharmanetPayload payload = new EDRD_PharmanetPayload();
        SAApprovalRequest saaRequest = new SAApprovalRequest();
        saaRequest.clientName = 'Test saaREq';        
        payload.saaRequestAPICallout(inputWrapper);
    }
    // Test method for Log
    private static Integration_Log__c createLog(String message, Integer code, Id caseId) {
        Integration_Log__c log = new Integration_Log__c(
            Message__c = message,
            Code__c = code,
            SA_Request__c = caseId
        );
        insert log;
        return log;
    }
    
    @isTest
    static void testGetDataFromIntLog_Success200() {
        // Create a dummy case
        Case testCase = new Case(Subject = 'Test Case');
        insert testCase;

        // Create Integration_Log__c with success message/code
        createLog('Success', 200, testCase.Id);

        // Build InputWrapper
        EDRD_PharmanetWrapper.InputWrapper input = new EDRD_PharmanetWrapper.InputWrapper();
        input.caseId = testCase.Id;

        // Call the testable method
        Test.startTest();
        EDRD_PharmanetPayload payload = new EDRD_PharmanetPayload();
        EDRD_PharmanetWrapper.OutputWrapper output = payload.getDataFromIntLog(input);
        Test.stopTest();

        // Validate
        System.assertEquals(true, output.isSubmitSuccessful);
        System.assertEquals(true, output.isPharmaNetSubmitSuccessfull);
        System.assertEquals('Success', output.ErrorMessage);
    }
    
    @isTest
    static void testGetDataFromIntLog_Failure() {
        // Create a dummy case
        Case testCase = new Case(Subject = 'Test Case');
        insert testCase;

        // Create Integration_Log__c with failure message/code
        createLog('Failed to submit', 400, testCase.Id);

        // Build InputWrapper
        EDRD_PharmanetWrapper.InputWrapper input = new EDRD_PharmanetWrapper.InputWrapper();
        input.caseId = testCase.Id;

        // Call the testable method
        Test.startTest();
        EDRD_PharmanetPayload payload = new EDRD_PharmanetPayload();
        EDRD_PharmanetWrapper.OutputWrapper output = payload.getDataFromIntLog(input);
        Test.stopTest();

        // Validate
        System.assertEquals(false, output.isSubmitSuccessful);
        System.assertEquals(false, output.isPharmaNetSubmitSuccessfull);
        System.assertEquals('Failed to submit', output.ErrorMessage);
    }
}