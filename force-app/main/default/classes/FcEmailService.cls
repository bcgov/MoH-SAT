public with sharing class FcEmailService implements Messaging.InboundEmailHandler{

    public Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email,Messaging.InboundEnvelope env){
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        processEmail(email);
        return result;
    }

    public void processEmail(Messaging.inboundEmail email) {
        String emailBody = email.plainTextBody;

        String status = findValues(emailBody, 'JOB STATUS:');
        String fileName = findValues(emailBody, 'FILE NAME:');
        if(String.isEmpty(status) ||String.isEmpty(fileName) || !filename.contains('.pdf'))
        {
            System.Debug('Invalid status or file.');
            return;
        }
        String caseNumber = fileName.substringBefore('.pdf').trim(); 

        List<Case> records=[SELECT ID, caseNumber from Case where caseNumber=:caseNumber LIMIT 1];
        for(Case record:records){
            ID caseId= record.ID ;
            storeEmail(email,caseId);
        }
        updateCase(caseNumber, status);  
    }
    
    public void storeEmail(Messaging.inboundEmail mail,ID caseId){
        EmailMessage  em = new EmailMessage();
        em.RelatedToId = caseId;
        em.Incoming = true;
        em.FromAddress = mail.fromAddress;
        em.FromName = mail.fromName;
        em.TextBody = mail.plainTextBody;
        em.Subject = mail.subject;
        em.Status = '3'; 
        insert em;
        List<EmailMessage> msg=[SELECT ID, fromName,fromAddress, relatedToId from EmailMessage];
        EmailMessage msgs=msg.isEmpty()?null:msg[0];
        update msgs;
    }

    public String findValues(String source, String key) {
        String value = '';
        if(String.isEmpty(source)){
            return value;
        }

        //String Implementation
        Integer keyEndIndex = source.lastIndexOf(key);
        Integer valueStartIndex = source.indexOf(':', keyEndIndex)+1;
        Integer valueEndIndex = source.indexOf(':',valueStartIndex);
        
         
        if(valueEndIndex==-1){
            if(valueStartIndex==-1){
                return value;
            }
            else if(valueStartIndex < source.length()){
                valueEndIndex = source.length();
            }
        }
        if(valueEndIndex==-1 || valueStartIndex==-1){
            return value;
        }
        value = source.substring(valueStartIndex, valueEndIndex);
        return value;
    }
  
    public void updateCase(String caseNumber, String status) {
        if(String.isEmpty(caseNumber)||String.isEmpty(status)){
            return;
        }

        List<Case> records=[SELECT ID, caseNumber,Status from Case where caseNumber=:caseNumber LIMIT 1];
        Case record=records.isEmpty()?null:records[0];
        if (record!=null&&status=='Success'){
         //   record.Fax_Sent_Date__c=Date.today();
            record.Fax_Notification_Date__c=Date.today(); 
            update record;
        }
    }
}






 


  