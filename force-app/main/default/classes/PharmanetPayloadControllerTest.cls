@isTest
public class PharmanetPayloadControllerTest {
    @TestSetup
    static void test_setup(){
        Case record = TestFactory.newCase(new Drug__c(), 'Test case');
        insert record;
    }

    @isTest
    static void test_mark_pushed_to_pharmanet() {
        Case record = queryCase('Test case');

        Test.startTest();
        PharmanetPayloadController.markPushedToPharmanet(record.Id);
        Test.stopTest();

        record = [select Id, Pushed_To_Pnet__c, Pushed_to_Pnet_Date__c from Case where Id=:record.Id];
        system.assertEquals(true, record.Pushed_to_Pnet__c);
        system.assert(null != record.Pushed_to_Pnet_Date__c);
    }

    @isTest
    static void test_get_pnet_sa_approval_requests() {
        Case record = queryCase('Test case');

        Test.startTest();
        List<SAApprovalRequest> sars = PharmanetPayloadController.getPnetSars(record.Id);
        Test.stopTest();

        system.assert(sars != null);
    }

    @isTest
    static void test_submit_single_pnet_sar_success() {
        Case record = queryCase('Test case');

        PharmanetPayloadController.mockSaaResponse = mockSaaResponse();
        
        try {
            Test.startTest();
            PharmanetPayloadController.submitSinglePnetSar(record.Id, new SAApprovalRequest());
            Test.stopTest();
            system.assert(true);
        } catch (Exception e) {
            system.assert(false, 'An unexpected exception was thrown.');
        }
    }

    @isTest
    static void test_submit_single_pnet_sar_success_with_200() {
        Case record = queryCase('Test case');

        PharmanetPayloadController.mockSaaResponse = mockSaaResponse(200);
        
        try {
            Test.startTest();
            PharmanetPayloadController.submitSinglePnetSar(record.Id, new SAApprovalRequest());
            Test.stopTest();
            system.assert(true);
        } catch (Exception e) {
            system.assert(false, 'An unexpected exception was thrown.');
        }
    }

    @isTest
    static void test_submit_single_pnet_sar_error() {
        Case record = queryCase('Test case');

        PharmanetPayloadController.mockSaaResponse = mockSaaResponse(404);
        
        try {
            Test.startTest();
            PharmanetPayloadController.submitSinglePnetSar(record.Id, new SAApprovalRequest());
            Test.stopTest();
            system.assert(false, 'An expected exception was not thrown.');
        } catch (Exception e) {
            system.assert(true);
        }
    }

    @isTest
    static void test_submit_single_pnet_set_termination_date() {
        Case record = queryCase('Test case');

        SAApprovalRequest saaRequest = new SAApprovalRequest();
        saaRequest.saRecord = new SAApprovalRequest.SARecord();
        saaRequest.saRecord.terminationDate = '2021/03/25';

        PharmanetPayloadController.mockSaaResponse = mockSaaResponse(200);
        Test.startTest();
        PharmanetPayloadController.submitSinglePnetSar(record.Id, saaRequest);
        Test.stopTest();

        record = queryCase('Test case');
        system.assertEquals(Date.newInstance(2021, 3, 25), record.Termination_Date__c);
    }

    private static Case queryCase(String subject) {
        return [select Id, Termination_Date__c from Case where Subject = :subject][0];
    }

    private static SAApprovalRequestResponse mockSaaResponse(Integer errorCode) {
        SAApprovalRequestResponse response = mockSaaResponse();
        response.error = new CalloutResponse();
        response.error.errorCode = errorCode;
        return response;
    }
    private static SAApprovalRequestResponse mockSaaResponse() {
        SAApprovalRequestResponse response = new SAApprovalRequestResponse();
        response.error = null;
        return response;
    }
}
