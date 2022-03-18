@isTest
public with sharing class FaxServiceTest {
  @TestSetup
  static void makeData(){
    Case record = new Case();
    record.status='Approved';
    record.Provider_Fax__c='8558120171';
    insert record; 

    Case record2 = new Case();
    record2.status='Approved2';
    record2.Fax_Sent_Date__c=null;
    insert record2; 
  }

  @isTest
static void test_Send_Fax_pass() {
    EmailTemplate template = new EmailTemplate();
    template.developername  = 'Approved_Fax_Template1'; 
    template.name = 'Approved Fax';
    template.templatetype = 'custom';
    template.FolderId= UserInfo.getUserId();
    insert template;

    Case record = [SELECT Id,status,Fax_Sent_Date__c FROM Case WHERE status=:'Approved' LIMIT 1];
    EmailTemplate temp = [SELECT Id,name ,developername from EmailTemplate where developername =:'Approved_Fax_Template1'];
    
    Id templateId = temp.id;
    Id caseId=record.id;

    List<FaxService.FcResponse> mockFcResponses = new List<FaxService.FcResponse> {
      createFcResponse('Success',null)
    };
    
    FilescanConnectMock mockResponse = new FilescanConnectMock(200,mockFcResponses,null);
    Test.setMock(HttpCalloutMock.class, mockResponse);
    Test.startTest();
    System.runAs(new User(Id = UserInfo.getUserId())){
    FaxService.sendFax(caseId,templateId);
  }
    Test.stopTest();
    Case result = [SELECT Id,status,Fax_Sent_Date__c FROM Case WHERE status=:'Approved' LIMIT 1];
    System.assert(result.Fax_Sent_Date__c!=null);
}

  @isTest
static void test_Send_Fax_Fail() {
    EmailTemplate template = new EmailTemplate();
    template.developername  = 'Approved_Fax_Template1'; 
    template.name = 'Approved Fax';
    template.templatetype = 'custom';
    template.FolderId= UserInfo.getUserId();
    insert template;

    Case record = [SELECT Id,status,Fax_Sent_Date__c FROM Case WHERE status=:'Approved2' LIMIT 1];
    EmailTemplate temp = [SELECT Id,name ,developername from EmailTemplate where developername =:'Approved_Fax_Template1'];
    
    Id templateId = temp.id;
    Id caseId=record.id;

    List<FaxService.FcResponse> mockFcResponses = new List<FaxService.FcResponse> {
      createFcResponse('Fail','Invalid Parameter')
    };
    
    FilescanConnectMock mockResponse = new FilescanConnectMock(400,mockFcResponses,null);
    Test.setMock(HttpCalloutMock.class, mockResponse);
    Test.startTest();
    System.runAs(new User(Id = UserInfo.getUserId())){
    try{
    FaxService.sendFax(caseId,templateId);
    }
    catch (Exception e) {
      system.assertEquals('Script-thrown exception', e.getMessage());
    }
    Test.stopTest();
  }
}

@isTest
static void test_Send_Fax_Flow_Pass() {
    List<Id> caseIds = new List<Id>();
    Case record = [Select Id from case where status='Approved'];
    Id value = record.Id;
    caseIds.add(value);
    List<FaxService.FcResponse> mockFcResponses = new List<FaxService.FcResponse> {
      createFcResponse('Success',null)
    };
    
    FilescanConnectMock mockResponse = new FilescanConnectMock(200,mockFcResponses,null);
    Test.setMock(HttpCalloutMock.class, mockResponse);
    Test.startTest();
    System.runAs(new User(Id = UserInfo.getUserId())){
    FaxService.sendFax(caseIds);
    Test.stopTest();
    Case result = [Select Id ,Fax_Sent_Date__c from case where status='Approved'];
    System.assert(result.Fax_Sent_Date__c!=null);
  }
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
 static void test_send_fax_evaluate_fcresponse_pass() {
   
  List<FaxService.FcResponse> mockFcResponses = new List<FaxService.FcResponse> {
      createFcResponse('Success',null)
    };

    List<FaxService.Payload> payloads = new List<FaxService.Payload>();
    Case record = [select Id, CaseNumber, status,Provider_Fax__c,Provider__r.name,Fax_Sent_Date__c FROM Case WHERE status=:'Approved' LIMIT 1]; 
    Id caseId = record.id;
    String caseNumber = record.CaseNumber; 
    String faxNumber = record.Provider_Fax__c;
    String recepientName = record.Provider__r.name;
    String attachment = 'attachemt';
    List<String> emails = new List<String>();
    String email1 = 'afreen9@outlook.com';
    emails.add(email1);
    
    FaxService.Payload payload = new FaxService.payload();
    payload.caseId = caseId;
    payload.caseNumber = caseNumber;
    payload.faxNumber = faxNumber; 
    payload.recepientName = recepientName;
    payload.attachment = attachment;
    payload.emails = emails;
    List<QueueOwnerSetter.CaseQueue> caseQueues = new List<QueueOwnerSetter.CaseQueue>();
    QueueOwnerSetter.CaseQueue queue = new QueueOwnerSetter.CaseQueue();
    queue.caseId = caseId;
    queue.queueName='Regular';
    caseQueues.add(queue);
    payloads.add(payload);
    FilescanConnectMock mockResponse = new FilescanConnectMock(200, mockFcResponses, null);
    Test.setMock(HttpCalloutMock.class, mockResponse);
    
    Test.startTest();
    FaxService.sendFax(payloads);
    Case result = [select Id, CaseNumber, status,Provider_Fax__c,Provider__r.name,Fax_Sent_Date__c FROM Case WHERE status=:'Approved' LIMIT 1]; 
    Test.stopTest();
    
    System.assert(result.Fax_Sent_Date__c!=null);
    System.assert(queue.queueName=='Regular');

  }
  
  @isTest
   static void test_send_fax_evaluate_fcresponses_fail() {
    List<FaxService.FcResponse> mockFcResponses = new List<FaxService.FcResponse> {
        createFcResponse('fail', 'Invalid Prameter')
      };
    FilescanConnectMock mockResponse = new FilescanConnectMock(200, mockFcResponses, null);

    List<FaxService.Payload> payload = new List<FaxService.payload>();

    Test.setMock(HttpCalloutMock.class, mockResponse);
    
     Test.startTest();
     try {
      FaxService.sendFax(payload);
     }
     catch (Exception e) {
      system.assertEquals('Invalid Payload', e.getMessage());
    }
     Test.stopTest();
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
    Test.startTest();
    try {
      FaxService.sendHttpRequest(new List<FaxService.Payload>());
      system.assert(false, 'An expected exception was not thrown.');
    } catch (Exception e) {
      system.assertEquals('<html></html>', e.getMessage());
    }
    Test.stopTest();

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
    
    public FilescanConnectMock(){

    }

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
      res.setHeader('Content-Type', 'application/json');
      
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