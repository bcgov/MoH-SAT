/**********************************************************************************************
* @Author:      CGI
* @Date:        14/03/2025
* @Description: The purpose of this class is Send Email notification to EDRD PSP queue used in flow 'Create_EDRD_Case'
*******************************************************************************************************************************/
public with sharing class EDRD_SendNewCaseCreationNotification {

    @InvocableMethod(label='Send EDRD Case creation Email Notification' description='Send EDRD Case creation Email Notification')
    public static void sendNewCaseCreationEmailNotificationTo(List<Case> caselist){
        Case objCaseRec = new Case();
       
        For(Case objCase : caselist) {
            objCaseRec = objCase;
         }
      
        try {
            Group queue = [SELECT Id, Name, Email FROM Group WHERE Type = 'Queue' AND Name = 'EDRD PSP Queue' LIMIT 1];
           
            if (queue.Email !=null) {             
                Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
                semail.setToAddresses(new List<String>{queue.Email});
                
                semail.setSubject('EDRD Case # ' + objCaseRec.CaseNumber + ' has been assigned to you.');
                String htmlBody='*** CASE ASSIGNMENT NOTIFICATION ***<br/> <br/>';
                htmlBody= htmlBody + 'Hello EDRD PSP Queue ,<br/> <br/>';
                htmlBody= htmlBody + 'A case has been assigned to you. Below are the details:<br/><br/>';
                htmlBody= htmlBody + 'Case #: ' +  objCaseRec.CaseNumber + '<br/>';
                htmlBody= htmlBody + 'Case Type: '+ objCaseRec.Type + '<br/>';
                htmlBody= htmlBody + 'Date/Time Opened: ' + objCaseRec.CreatedDate + '<br/><br/>';
                htmlBody= htmlBody + 'Click on the link to access the case: <a href="'+URL.getOrgDomainUrl().toExternalForm()+'/'+objCaseRec.Id+'">'+objCaseRec.CaseNumber+'</a>.'+'</br> <br/>';
                htmlBody= htmlBody + 'Thank you,' + '<br/>';
                htmlBody= htmlBody + 'Expensive Drugs For Rare Diseases - BC Ministry of Health';             

                semail.setHtmlBody(htmlBody);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail});
            }

        } catch (Exception e) {
            System.debug('Queue/Owner not found: ' + e.getMessage());
        }
    }

}