@isTest
public class ODRBusinessErrorResponseTest {
    @isTest
    public static void ODRBusinessErrorResponseTest() {
        ODRBusinessErrorResponse odrError = new ODRBusinessErrorResponse();
        odrError.requestUUID = '';
        odrError.clientName = '';
        odrError.status = '';
        odrError.statusMessage = new List<String>();
        odrError.statusMessage.add('');
    }
}