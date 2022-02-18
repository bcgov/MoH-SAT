
public with sharing class FcEmailService implements Messaging.InboundEmailHandler{

    public Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email,Messaging.InboundEnvelope env){
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        processEmail(email);
        return result;
    }

    public void processEmail(Messaging.inboundEmail email) {
        String emailBody = email.plainTextBody;

        String status = findValues(emailBody, 'STATUS:');
        String fileName = findValues(emailBody, 'FILE NAME:');
        if(String.isEmpty(status) ||String.isEmpty(fileName) || !filename.contains('.pdf'))
        {
            System.Debug('Invalid status or file.');
            return;
        }

        String caseId = fileName.substringBefore('.pdf').trim();  
        updateCase(caseId, status);
    }

    public String findValues(String source, String key) {
        String value = '';
        if(String.isEmpty(source)){
            return value;
        }

        //Tokenizing Implementation
        // List<String> emailBody = source.split('\n');
        // Integer index = emailBody.indexOf(key);
        // if(index!=null && index+1!=emailBody.size()){
        //     value = emailBody.get(index+1);
        // }


        //String Implementation
        Integer keyEndIndex = source.lastIndexOf(key);
        Integer valueStartIndex = source.indexOf('\n', keyEndIndex)+1;
        Integer valueEndIndex = source.indexOf('\n', valueStartIndex);
        
         
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
            record.Fax_Notification_Date__c=Date.today();   
            update record;
        }
    }
}






 


