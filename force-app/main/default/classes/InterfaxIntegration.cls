public with sharing class InterfaxIntegration {
    public InterfaxIntegration() {
    }

    /*
         Send outbound Fax
         URI: POST URI: GET https://rest.interfax.net/outbound/faxes?faxNumber={faxNumber}
         Add application/pdf attachement as BLOB
         Return FaxID if success or ERROR
    */
    @AuraEnabled(cacheable=true)
    public static String sendFax(Id recordId, String faxNumber, String templateId, String integrationName) {
        
        String result;
        List<Logging_Event__e> loggingEvents = new List<Logging_Event__e>();

        Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(templateId, UserInfo.getUserId(), recordId);

        String content = email.getHTMLBody().replaceall('src','');

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Interfax/outbound/faxes?faxNumber='+faxNumber);
        req.setMethod('POST');
        req.setBodyAsBlob(Blob.toPdf(content));
        req.setHeader('Content-Type', 'application/pdf');
        
        Http http = new Http();

        HTTPResponse res = http.send(req);

        if (res.getStatusCode() == 201) {
            result = res.getHeader('Location').Substring(res.getHeader('Location').LastIndexOf('/')+1);             
            loggingEvents.add(new Logging_Event__e(code__c=res.getStatusCode(),
                                                    message__c='Success',
                                                    caseId__c=recordId,
                                                    type__c=integrationName));
        } else {
            loggingEvents.add(new Logging_Event__e(code__c=res.getStatusCode(),
                                                    message__c=getJSONVariable('message',res.getBody()),
                                                    caseId__c=recordId,
                                                    type__c=integrationName));
            result = 'ERROR CODE:'+res.getStatusCode()+' ERROR MESSAGE:'+getJSONVariable('message',res.getBody());
        }
        EventBus.publish(loggingEvents);
        return result;
    }

    @AuraEnabled
    public static String getProviderFaxNumber(Id recordId){
      try {
        System.debug('GETTING FAX NUM');
        System.debug(recordId);
        SpecialAuthorityRequest sar = SpecialAuthorityRequest.build(recordId);
        System.debug('****');
        System.debug(sar.saCase.Provider__r);
        return sar.saCase.Provider__r.Fax;
      } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
      }
    }

    /*
        Get Outbound Fax Status by ID
        URI: GET https://rest.interfax.net/outbound/faxes/{faxid}
        Return Status: 0= OK; less than 0 = in process; greater than 0 = Error
    */
    @AuraEnabled
    public static InterfaxOutboundResponse getFaxOutboundStatus(Id recordId, String faxId, String integrationName) {
        List<Logging_Event__e> loggingEvents = new List<Logging_Event__e>();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Interfax/outbound/faxes/'+faxId);
        req.setMethod('GET');

        Http http = new Http();
        HTTPResponse res = http.send(req);
        InterfaxOutboundResponse iorFax = (InterfaxOutboundResponse) JSON.deserialize(res.getBody(), InterfaxOutboundResponse.class);

        if (res.getStatusCode() == 200) {
          loggingEvents.add(new Logging_Event__e(code__c=res.getStatusCode(),
                                                  message__c='Success',
                                                  caseId__c=recordId,
                                                  type__c=integrationName));
        } else {
          loggingEvents.add(new Logging_Event__e(code__c=res.getStatusCode(),
                                                  message__c='Error sending fax',
                                                  caseId__c=recordId,
                                                  type__c=integrationName));
        }
        System.debug(iorFax);
        EventBus.publish(loggingEvents);
        return iorFax;
    }

    @AuraEnabled
    public static void updateCaseFaxSent(Id caseId) {
      Case c = [select Id, Fax_Notification_Date__c FROM case WHERE Id =:caseId];
      c.Fax_Notification_Date__c = Date.newInstance(Datetime.now().year(), Datetime.now().month(), Datetime.now().day());
      update c;
  }

    /*
        Get unread Inbound faxes
        URI: GET https://rest.interfax.net/inbound/faxes?unreadOnly=true
        return List of InterFaxJSON.InboundFaxDetail objects
    */
    public static List<InterFaxJSON.InboundFaxDetail> getInboundFaxes(Id recordId, String integrationName) { 

        List<InterFaxJSON.InboundFaxDetail > listInboundFaxes = new List<InterFaxJSON.InboundFaxDetail>();
        List<Logging_Event__e> loggingEvents = new List<Logging_Event__e>();

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Interfax/inbound/faxes?unreadOnly=true');
        req.setMethod('GET');

        Http http = new Http();
        HTTPResponse res = http.send(req);       
        
        if(res.getStatusCode() == 200) {
            listInboundFaxes = InterFaxJSON.parseInboundFaxDetail(res.getBody());
            loggingEvents.add(new Logging_Event__e(code__c=res.getStatusCode(),
                                                    message__c='Success',
                                                    caseId__c=recordId,
                                                    type__c=integrationName));
        } else {
            loggingEvents.add(new Logging_Event__e(code__c=res.getStatusCode(),
                                                    message__c=getJSONVariable('message',res.getBody()),
                                                    caseId__c=recordId,
                                                    type__c=integrationName));
        }
        EventBus.publish(loggingEvents);
        return listInboundFaxes;
    }


    /*
        Mark faxes as read
        URI: GET https://rest.interfax.net/inbound/faxes/{faxid}/mark
    */
    public static void markFaxAsRead(Id recordid, String faxid, String integrationName) {
        List<Logging_Event__e> loggingEvents = new List<Logging_Event__e>();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Interfax/inbound/faxes/'+faxId+'/mark');
        req.setMethod('POST');

        Http http = new Http();
        HTTPResponse res = http.send(req);       

        if(res.getStatusCode() == 200) {
            loggingEvents.add(new Logging_Event__e(code__c=res.getStatusCode(),
                                                    message__c='Success',
                                                    caseId__c=recordId,
                                                    type__c=integrationName));
        } else {
            loggingEvents.add(new Logging_Event__e(code__c=res.getStatusCode(),
                                                    message__c=getJSONVariable('message',res.getBody()),
                                                    caseId__c=recordId,
                                                    type__c=integrationName));
        }
        EventBus.publish(loggingEvents);
    }

    
    /*
        Get faxes image
        URI: GET https://rest.interfax.net/inbound/faxes/{faxid}/image
        return: BLOB
    */
    public static Blob getFaxImage(Id recordid, String faxid, String integrationName){
        List<Logging_Event__e> loggingEvents = new List<Logging_Event__e>();

        Blob faxImage;

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Interfax/inbound/faxes/'+faxId+'/image');
        req.setMethod('GET');

        Http http = new Http();
        HTTPResponse res = http.send(req);    

        if(res.getStatusCode() == 200) {
            faxImage = res.getBodyAsBlob();
            loggingEvents.add(new Logging_Event__e(code__c=res.getStatusCode(),
                                                    message__c='Success',
                                                    caseId__c=recordId,
                                                    type__c=integrationName));
        } else {
            loggingEvents.add(new Logging_Event__e(code__c=res.getStatusCode(),
                                                    message__c=getJSONVariable('message',res.getBody()),
                                                    caseId__c=recordId,
                                                    type__c=integrationName));
        }
        EventBus.publish(loggingEvents);
        return faxImage;
    }

    @AuraEnabled(cacheable=true)
    public static String getOutboudImage(Id recordId, String templateId) {
        Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(templateId, UserInfo.getUserId(), recordId);
        return email.getHTMLBody();
    }

    private static String getJSONVariable(String attr, String body) {
        JSONParser parser = JSON.createParser(body);
        String value;
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
             (parser.getText() == 'attr')) {
             parser.nextToken();
             value = parser.getText();
            }
        }
    return value;
    }

}
