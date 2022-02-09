@isTest
public class SAApprovalUpdateRequestResponseTest {
    @isTest
    public static void SAApprovalUpdateRequestResponseTest() {
        SAApprovalUpdateRequestResponse sar = new SAApprovalUpdateRequestResponse();
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
