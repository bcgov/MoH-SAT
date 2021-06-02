@isTest
public class RequestDetailsTest {

    @isTest
    static void test_get_request_details() {
        Case newCase = TestFactory.newCase(new Drug__c(), 'TestCase');
        insert newCase;

        List<Request_Detail__c> rdList = new List<Request_Detail__c>();
        rdList.add(TestFactory.newRequestDetail(newCase, 'qid1', 'answer 1'));
        rdList.add(TestFactory.newRequestDetail(newCase, 'qid2', 'answer 2'));
        rdList.add(TestFactory.newRequestDetail(newCase, 'qid3', 'answer 3'));
        insert rdList;

        List<Request_Detail__c> result = RequestDetails.getRequestDetails(newCase.Id);

        system.assertEquals(result.size(), rdList.size());
    }

    @isTest
    static void post_to_case_feed() {
        Case newCase = TestFactory.newCase(new Drug__c(), 'TestCase');
        insert newCase;

        List<Request_Detail__c> rdList = new List<Request_Detail__c>();
        rdList.add(TestFactory.newRequestDetail(newCase, 'qid1', 'answer 1'));
        rdList.add(TestFactory.newRequestDetail(newCase, 'qid2', 'answer 2'));
        insert rdList;

        Test.startTest();
        RequestDetails.postToCaseFeed(rdList[0], rdList[1]);
        Test.stopTest();
    }

    @isTest
    static void test_build_chatter_post_string_change() {        
        Request_Detail__c oldRecord = TestFactory.newRequestDetail(new Case(), 'qid1', 'test answer');
        Request_Detail__c newRecord = TestFactory.newRequestDetail(new Case(), 'qid1', 'test answer editted');

        Test.startTest();
        String post = RequestDetails.buildMessage('Test Question', 'RD-001', oldRecord, newRecord);
        Test.stopTest();

        system.assertEquals(
            Userinfo.getName() + ' changed request detail response for "Test Question" (RD-001) from "test answer" to "test answer editted"',
            post
        );
    }

    @isTest
    static void test_build_chatter_post_date_change() {        
        Request_Detail__c oldRecord = TestFactory.newRequestDetail(new Case(), 'qid1', Date.today());
        Request_Detail__c newRecord = TestFactory.newRequestDetail(new Case(), 'qid1', Date.today().addDays(1));

        Test.startTest();
        String post = RequestDetails.buildMessage('Test Question', 'RD-001', oldRecord, newRecord);
        Test.stopTest();

        system.assertEquals(
            Userinfo.getName() + 
            ' changed request detail response for "Test Question" (RD-001) from "' +
             String.valueOf(Date.today()) + 
             '" to "' + 
             String.valueOf(Date.today().addDays(1))+ '"',
            post
        );
    }

    @isTest
    static void test_build_chatter_post_datetime_change() {   
        Datetime d1 = Datetime.now();
        Datetime d2 = Datetime.now().addHours(1);
             
        Request_Detail__c oldRecord = TestFactory.newRequestDetail(new Case(), 'qid1', d1);
        Request_Detail__c newRecord = TestFactory.newRequestDetail(new Case(), 'qid1', d2);

        Test.startTest();
        String post = RequestDetails.buildMessage('Test Question', 'RD-001', oldRecord, newRecord);
        Test.stopTest();

        system.assertEquals(
            Userinfo.getName() + 
            ' changed request detail response for "Test Question" (RD-001) from "' +
             String.valueOf(d1) + 
             '" to "' + 
             String.valueOf(d2)+ '"',
            post
        );
    }

    @isTest
    static void test_build_chatter_post_decimal_change() {   
        Request_Detail__c oldRecord = TestFactory.newRequestDetail(new Case(), 'qid1', 10.0);
        Request_Detail__c newRecord = TestFactory.newRequestDetail(new Case(), 'qid1', 11.0);

        Test.startTest();
        String post = RequestDetails.buildMessage('Test Question', 'RD-001', oldRecord, newRecord);
        Test.stopTest();

        system.assertEquals(
            Userinfo.getName() + 
            ' changed request detail response for "Test Question" (RD-001) from "' +
             String.valueOf(10.0) + 
             '" to "' + 
             String.valueOf(11.0)+ '"',
            post
        );
    }

    @isTest
    static void test_build_chatter_post_boolean_change() {   
        Request_Detail__c oldRecord = TestFactory.newRequestDetail(new Case(), 'qid1', false);
        Request_Detail__c newRecord = TestFactory.newRequestDetail(new Case(), 'qid1', true);

        Test.startTest();
        String post = RequestDetails.buildMessage('Test Question', 'RD-001', oldRecord, newRecord);
        Test.stopTest();

        system.assertEquals(
            Userinfo.getName() + 
            ' changed request detail response for "Test Question" (RD-001) from "' +
             String.valueOf(false) + 
             '" to "' + 
             String.valueOf(true)+ '"',
            post
        );
    }
}
