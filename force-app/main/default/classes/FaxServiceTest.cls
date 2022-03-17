@isTest
public with sharing class FaxServiceTest {
  @TestSetup
  static void makeData(){
      Case record = new Case();
      record.status='Approved';
      record.Provider_Fax__c='8558120171';
      insert record;
  }
  
  static testMethod void testHttpRequest(){
    // List<FaxService.Payload> payloads = new List<FaxService.Payload>();

    // Case record = [select Id, CaseNumber, status,Provider_Fax__c,Provider__r.name,Fax_Sent_Date__c FROM Case WHERE status=:'Approved' LIMIT 1]; 
    // Id caseId = record.id;
    // String caseNumber = record.CaseNumber; 
    // String faxNumber = record.Provider_Fax__c;
    // String recepientName = record.Provider__r.name;
    // String attachment = 'attachemt';
    // List<String> emails = new List<String>();
    // String email1 = 'afreen9@outlook.com';
    // emails.add(email1);

    // FaxService.Payload payload = new FaxService.payload();
    // payload.caseId = caseId;
    // payload.caseNumber = caseNumber;
    // payload.faxNumber = faxNumber; 
    // payload.recepientName = recepientName;
    // payload.attachment = attachment;
    // payload.emails = emails;

    // payloads.add(payload);

    // Test.startTest();

    // Test.setMock(HttpCalloutMock.class, new FilescanConnectMock());
    // List<FaxService.FcResponse> result =  FaxService.sendHttpRequest(payloads);

    // Test.stopTest();
    // System.assert(result!=null);

  }

  @isTest
  static void test_Send_Fax() {
    // EmailTemplate template = new EmailTemplate();
    // template.developername  = 'Approved_Fax_Template1'; 
    // template.name = 'Approved Fax';
    // template.templatetype = 'custom';
    // template.FolderId= UserInfo.getUserId();
    // insert template;

    // Case records = [SELECT Id,status,Fax_Sent_Date__c FROM Case WHERE status=:'Approved' LIMIT 1];
    // EmailTemplate temp = [SELECT Id,name ,developername from EmailTemplate where developername =:'Approved_Fax_Template1'];
    // Id templateId = temp.id;
    // Id caseIds=records.id;
    // FaxService.sendFax(caseIds,templateId);

    // List<FaxService.Payload> payloads = new List<FaxService.Payload>();
    // Case record = [select Id, CaseNumber, status,Provider_Fax__c,Provider__r.name,Fax_Sent_Date__c FROM Case WHERE status=:'Approved' LIMIT 1]; 
    // Id caseId = record.id;
    // String caseNumber = record.CaseNumber; 
    // String faxNumber = record.Provider_Fax__c;
    // String recepientName = record.Provider__r.name;
    // String attachment = 'attachemt';
    // List<String> emails ;
    
    // FaxService.Payload payload = new FaxService.payload();
    // payload.caseId = caseId;
    // payload.caseNumber = caseNumber;
    // payload.faxNumber = faxNumber; 
    // payload.recepientName = recepientName;
    // payload.attachment = attachment;
    // payload.emails = emails;

    // payloads.add(payload);

    // Test.startTest();

    // Test.setMock(HttpCalloutMock.class, new FilescanConnectMock());
    // FaxService.sendFax(payloads);

    // Test.stopTest();
  
    // System.Debug('Hurrayyy');
  }

  @isTest
  static void test_GeneratePdf() {
    EmailTemplate template = new EmailTemplate();
    template.developername  = 'Approved_Fax_Template1'; 
    template.name = 'Approved Fax';
    template.templatetype = 'custom';
    template.FolderId= UserInfo.getUserId();
    insert template;

    Case records = [SELECT Id,status,Fax_Sent_Date__c FROM Case WHERE status=:'Approved' LIMIT 1];
    EmailTemplate temp = [SELECT Id,name ,developername from EmailTemplate where developername =:'Approved_Fax_Template1'];
    Id templateId = temp.id;
    Id caseId=records.id;

    String result =  FaxService.generatePdf(caseId,templateId);
    System.assert(result!=null);
  }

  @isTest
  static void test_buildPaylload() {
    Case record = [select Id, CaseNumber, status,Provider_Fax__c,Provider__r.name,Fax_Sent_Date__c FROM Case WHERE status=:'Approved' LIMIT 1]; 
    Id caseId = record.id;
    String caseNumber = record.CaseNumber; 
    String faxNumber = record.Provider_Fax__c;
    String recepientName = record.Provider__r.name;
    String attachment = 'attachemt';
    List<String> emails ;
    
    FaxService.Payload payload = new FaxService.payload();
    payload.caseId = caseId;
    payload.caseNumber = caseNumber;
    payload.faxNumber = faxNumber; 
    payload.recepientName = recepientName;
    payload.attachment = attachment;
    payload.emails = emails;

    payload = FaxService.buildPayload(caseId,caseNumber,faxNumber,recepientName,attachment,emails);
    System.assert(payload!=null);
  }

  @isTest
  static void testFlow() {
    // List<Id> testData = new List<Id>();
    // FaxService.sendFax(testData);
    // Case record = new Case();
    // insert record;
    // System.Debug(record.Fax_Sent_Date__c!=null);
  }

  @isTest
  static void test_send_fax_evaluate_fcresponse_pass() {
    // setup mock fc responses in a way that would pass evaluateFcResponse()

    // setup case record and insert (to be used in payload)

    // setup payloads, needs a caseId
    
    // call FaxService.sendFax(payloads)

    // assert case's owner and fax sent date were changed by sendFax.
  }
  
  @isTest
  static void test_send_fax_evaluate_fcresponses_fail() {
    // setup mock fc responses in a way that would fail evaluateFcResponse()
    List<FaxService.FcResponse> mockFcResponses = new List<FaxService.FcResponse> {
        createFcResponse('fail', 'Invalid Parameter')
      };
    FilescanConnectMock mockResponse = new FilescanConnectMock(400, mockFcResponses, null);
    // setup payloads
    List<FaxService.Payload> payload = new List<FaxService.payload>();

    // call 
   
    FaxService.sendFax(payload);
 
    
  }

  @isTest
  static void test_send_http_response_200() {
    List<FaxService.FcResponse> mockFcResponses = new List<FaxService.FcResponse> {
      createFcResponse('success', null)
    };

    FilescanConnectMock mockResponse = new FilescanConnectMock(200, mockFcResponses, null);
    Test.setMock(HttpCalloutMock.class, mockResponse);
    
    Test.startTest();
    List<FaxService.FcResponse> results = FaxService.sendHttpRequest(new List<FaxService.Payload>());
    Test.stopTest();

    system.assert(!results.isEmpty());
    system.assertEquals('success', results[0].status);
  }

  @isTest
  static void test_send_http_response_exception() {
    Test.setMock(HttpCalloutMock.class, new FilescanConnectMock('Some HTTP error'));
    
    Test.startTest();
    try {
      FaxService.sendHttpRequest(new List<FaxService.Payload>());
      system.assert(false, 'An expected exception was not thrown.');
    } catch (Exception e) {
      system.assertEquals('Some HTTP error', e.getMessage());
    }
    Test.stopTest();
  }

  @isTest
  static void test_send_http_response_302_html_response() {
    Test.setMock(HttpCalloutMock.class, new FilescanConnectMock(302, null, '<html></html>'));

    // TODO
  }

  @isTest
  static void test_send_http_response_400_server_validation_exception() {
    List<FaxService.FcResponse> mockFcResponses = new List<FaxService.FcResponse> {
      createFcResponse('success', null),
      createFcResponse('fail', 'invalid whatever')
    };

    FilescanConnectMock mockResponse = new FilescanConnectMock(400, mockFcResponses, null);
    Test.setMock(HttpCalloutMock.class, mockResponse);
    
    Test.startTest();

    List<FaxService.FcResponse> results;

    try {
      FaxService.sendHttpRequest(new List<FaxService.Payload>());
      system.assert(false, 'An expected exception was not thrown.');
    } catch (FaxService.FaxServiceException e) {
      results = (List<FaxService.FcResponse>) JSON.deserialize(e.getMessage(), List<FaxService.FcResponse>.class);
    }
    Test.stopTest();

    system.assert(!results.isEmpty());
    system.assertEquals('success', results[0].status);
    system.assertEquals(null, results[0].error);
    system.assertEquals('fail', results[1].status);
    system.assertEquals('invalid whatever', results[1].error);
  }

  public static FaxService.FcResponse createFcResponse(String status, String error) {
    FaxService.FcResponse fcResponse = new FaxService.FcResponse();
    fcResponse.status = status;
    fcResponse.error = error;
    return fcResponse;
  }

  public class FilescanConnectMock implements HttpCalloutMock{
    private String errorMessage;
    private String responseBody;
    private Integer statusCode;
    private List<FaxService.FcResponse> mockFcResponses;

    public FilescanConnectMock(Integer statusCode) {
      this(statusCode, null, null);
    }

    public FilescanConnectMock(Integer statusCode, List<FaxService.FcResponse> mockFcResponses, String responseBody) {
      this.statusCode = statusCode;
      this.mockFcResponses = mockFcResponses;
      this.responseBody = responseBody;
      this.errorMessage = null;
    }

    public FilescanConnectMock(String errorMessage) {
      this.errorMessage = errorMessage;
    }

    public HttpResponse respond(HttpRequest req) {
      if (String.isNotBlank(errorMessage)) throw new TestException(errorMessage); 

      HttpResponse res = new HttpResponse();
      res.setStatusCode(this.statusCode);
      
      if (mockFcResponses != null) {
        res.setBody(JSON.serialize(mockFcResponses));
      } else if (responseBody != null) {
        res.setBody(responseBody);
      }

      return res;
    }
  }

  public class TestException extends Exception {}
}