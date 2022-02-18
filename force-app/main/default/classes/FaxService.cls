public with sharing class FaxService {
    public class Payload{
        public String caseNumber;
        public String faxNumber;
        public String recepientName;
        public String attachment;
    }
   
    @AuraEnabled(cacheable=true)
    public static String sendFax(ID caseId, ID templateId){
        
        Case record=[SELECT ID, caseNumber, Contact.name,Provider_Fax__c,provider__r.name from Case where ID=:caseId];
        
            PageReference ref=Page.PDFGenerator;
            ref.getParameters().put('templateId',templateId);
            ref.getParameters().put('Id',caseId);
            Blob pdf=ref.getContent();
            String attachment=EncodingUtil.base64encode(pdf);
            System.debug(attachment);
        
            FaxService.Payload payload=new FaxService.Payload();
            payload.caseNumber=record.caseNumber;
            payload.faxNumber=record.Provider_Fax__c; 
            payload.recepientName=record.Contact.name;
            payload.attachment=attachment;
            System.debug(JSON.serialize(payload));
        
        return null;  
    }
}
