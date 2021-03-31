@isTest
public class InterfaxIntegrationTest {
  @future
  public static void createEmailTemplate() {
    EmailTemplate e = new EmailTemplate (developerName = 'test', FolderId = userInfo.getUserId(), TemplateType= 'Text', Name = 'test');
    insert e;
  }
  @isTest
    public static void InterfaxIntegrationTest() {
      // InterfaxOutboundResponse ior = new InterfaxOutboundResponse();
      // ior.submitTime = '';
      // ior.status = 0;
      // ior.error = '';

      // TODO
      // sendFax
      // getProviderFaxNumber
      // getFaxOutboundStatus
      // updateCaseFaxSent
      // getInboundFaxes
      // markFaxAsRead
      // getFaxImage
      // getOutboudImage
      // getJSONVariable
      Integer RESPONSE_CODE = 200;
      createEmailTemplate();
      String developerName = 'test';
      EmailTemplate e;
      List<EmailTemplate> ets = [select Id, developerName FROM EmailTemplate];
      if(ets.size() > 0) {
        // Pick the first one.
        e = ets[0];
      }
      Drug__c drug = TestFactory.newDrug('Drug 1');
      insert drug;

      Account patient = TestFactory.newPatient('Patient 1');
      Account provider = TestFactory.newProvider('Provider 1');
      insert new Account[] { patient, provider };

      Case saCase = TestFactory.newCase(drug, patient, provider, 'Test case 1');
      insert saCase;

      Test.startTest();
      String faxNumber = '009999999000000000';

      ODRCalloutMock fakeResponse = new ODRCalloutMock(RESPONSE_CODE,
                                                      'callout:Interfax/outbound/faxes?faxNumber=' + faxNumber,
                                                      'POST',
                                                      null);
      Test.setMock(HttpCalloutMock.class, fakeResponse);
      String resp = InterfaxIntegration.sendFax(saCase.Id, faxNumber, Id.valueOf(e.Id), '7a');
      // System.assertEquals(RESPONSE_CODE, calloutResponseObject.errorCode, 'Response code should be ' + RESPONSE_CODE);
      Test.stopTest();
    }
}