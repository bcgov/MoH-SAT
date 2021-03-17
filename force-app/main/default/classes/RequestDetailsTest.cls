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
}
