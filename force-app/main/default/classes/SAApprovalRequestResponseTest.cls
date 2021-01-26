@isTest
public class SAApprovalRequestResponseTest {
    @isTest
    public static void SAApprovalRequestResponseTest() {
        SAApprovalRequestResponse sar = new SAApprovalRequestResponse();
        sar.requestUUID = '1234';
        sar.clientName = '1234';
        sar.status = 0;
        sar.statusMessage = new List<String>();
        sar.statusMessage.add('');

        CalloutResponse cor = new CalloutResponse();
        cor.errorCode = 200;
        cor.errorMessage = '';
        sar.error = cor;
    }
}