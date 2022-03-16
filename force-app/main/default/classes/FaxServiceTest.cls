@isTest
public with sharing class FaxServiceTest {
  public class ExampleCalloutMock implements HttpCalloutMock{
    public HttpResponse respond(HTTPRequest req){
        HttpResponse res = new HttpResponse();
        if(req.getEndpoint().endsWith('SA/sf2fsc')){
        res.setStatus('OK');
        res.setStatusCode(200);
        res.setBody('[{"recepientName":"Wait Di Gregorio","faxNumber":"855-812-1071","emails":["fcemailservice@3-41bw7asxl2wnqbetbivafaggrgp1zsy6cstktlpt9h7w7pr3e.1f-9nzxeaq.cs99.apex.sandbox.salesforce.com","afreenahmed9@outlook.com"],"caseNumber":"00001056","caseId":"5001f000002yAR0AAM","attachment":"This is it"}]');
        return res;
        }
        return res;
    }
}

@TestSetup
static void makeData(){
    Case record = new Case();
    record.status='Approved';
    record.Provider_Fax__c='8558120171';
    insert record;
}
  
  static testMethod void testHttpRequest(){
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

    payloads.add(payload);

    Test.startTest();

    Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
    List<FaxService.FcResponse> result =  FaxService.sendHttpRequest(payloads);

    Test.stopTest();
    System.assert(result!=null);

  }

  @isTest
  static void test_Send_Fax() {

    EmailTemplate template = new EmailTemplate();
    template.developername  = 'Approved_Fax_Template1'; 
    template.name = 'Approved Fax';
    template.templatetype = 'custom';
    template.FolderId= UserInfo.getUserId();
    insert template;

    Case records = [SELECT Id,status,Fax_Sent_Date__c FROM Case WHERE status=:'Approved' LIMIT 1];
    EmailTemplate temp = [SELECT Id,name ,developername from EmailTemplate where developername =:'Approved_Fax_Template1'];
    Id templateId = temp.id;
    Id caseIds=records.id;
    FaxService.sendFax(caseIds,templateId);

    List<FaxService.Payload> payloads = new List<FaxService.Payload>();
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

    payloads.add(payload);

    Test.startTest();

    Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
    FaxService.sendFax(payloads);

    Test.stopTest();
  
    System.Debug('Hurrayyy');
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
    List<Id> testData = new List<Id>();
    FaxService.sendFax(testData);
    Case record = new Case();
    insert record;
    System.Debug(record.Fax_Sent_Date__c!=null);
    }
}