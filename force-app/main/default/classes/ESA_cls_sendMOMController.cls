/**********************************************************************************************
* @Author:      Deepak 
* @Date:        25th Sept 2023
* @Description: The purpose of this class is to send email to contacts about the meeting minutes of EC.
***********************************************************************************************/
public with sharing class ESA_cls_sendMOMController {
    
    @invocablemethod()
    public static List<String> sendMOM(List<Id> externalCommitteIdList){
        List<String> returnString = new List<String>();
        try{
            List<External_Committee__c> externalCommitteList = [SELECT Id, EC_To_Account__c FROM External_Committee__c 
                                                                WHERE Id =: externalCommitteIdList];
            Map<Id, Contact> contactIdVsRec = new Map<Id, Contact>([SELECT Id, email FROM Contact 
                                                                    WHERE AccountId =: externalCommitteList[0].EC_To_Account__c]);
            
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
            EmailTemplate emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body 
                                           FROM EmailTemplate WHERE name = 'ESA_ET_sendCasesMOM'];
            
            OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'noreply@hlthsa.gov.bc.ca'];
            
            for(Contact conObj: contactIdVsRec.values()){
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.setTargetObjectId(conObj.Id); 
                if(!owea.isEmpty()){
                    message.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                message.setTemplateID(emailTemplate.Id); 
                message.setWhatId(externalCommitteIdList[0]);
                message.toAddresses = new List<String>{conObj.email};
                    messages.add(message);
            }
            
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            
            if (results[0].success) 
            {
                returnString.add(System.Label.ESA_label_sendEmailSuccessMsg);
            } else {
                returnString.add(System.Label.ESA_label_sendEmailErrorMsg +  results[0].errors[0].message);
            }
        }
        catch(exception e){
            returnString.add(e.getmessage());
        }
        return returnString;
        
    }
    
}