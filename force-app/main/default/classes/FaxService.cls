public with sharing class FaxService {
    public class Payload{
        public String caseNumber;
        public String faxNumber;
        public String recepientName;
        public String attachment;
    }
   
    @AuraEnabled(cacheable=true)
    public static void sendFax(ID caseId, ID templateId){
        
     List<Case> record=[SELECT ID, caseNumber, Contact.name,Provider_Fax__c,provider__r.name from Case where ID=:caseId];
        for(Case records:record){
            PageReference ref=Page.PDFGenerator;
            ref.getParameters().put('templateId',templateId);
            ref.getParameters().put('Id',caseId);
            Blob pdf=ref.getContent();
            String attachment=EncodingUtil.base64encode(pdf);
        
            FaxService.Payload payload=new FaxService.Payload();
            payload.caseNumber=records.caseNumber;
            payload.faxNumber=records.Provider_Fax__c; 
            payload.recepientName=records.Contact.name;
            payload.attachment=attachment;

            HttpRequest req = new HttpRequest();
            req.setBody(JSON.serialize(payload));
            req.setEndpoint('callout:FilescanConnectWs/SA/sf2fsc');
            req.setMethod('POST');
            
            Http http = new Http();
            HTTPResponse res;
            try{
            res = http.send(req);
            }
            catch(Exception e){
                 throw new AuraHandledException(e.getMessage());
            }
            if(res.getStatusCode()==200){
                return;
            }
            else{
                 throw new AuraHandledException(res.getStatusCode()+': '+res.getStatus());
            }
      }       
    }
}

