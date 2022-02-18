@isTest(SeeAllData=true)
public class FcEmailServiceTest  {
      static testMethod void test_find_value_positive() {
                String source = '...FILE NAME:\n1023.pdf';
                String result = FcEmailService.findValues(source, 'FILE NAME:');
                system.assertEquals('1023.pdf', result);
        }
      static testMethod void test_file_name_empty() {
                String source = 'FILE NAME:\n';
                String result = FcEmailService.findValues(source, 'FILE NAME:');
                system.assertEquals('', result);
        }
      static testMethod void test_update_case_positive() {
                Case record = new Case(Id='5000i000000uomKAAQ');
                record.Fax_Notification_Date__c = null;
                Update record;
                FcEmailService.updateCase('00001026','Success');
                Case results = [select Fax_Notification_Date__c from Case where ID= :record.Id];
                System.debug(results.Fax_Notification_Date__c);
                System.assert(results.Fax_Notification_Date__c != null);
        }
     static testMethod void  test_update_case_negative() {
                Case record = new Case(Id='5000i000000uomKAAQ');
                record.Fax_Notification_Date__c = null;
                Update record;
                FcEmailService.updateCase('00001026','Fail');
                Case result = [select Fax_Notification_Date__c from Case where ID = :record.Id];
                System.assert(result.Fax_Notification_Date__c == null);
        }
     static testMethod void TestingBoundEmail(){

                Messaging.InboundEmail emails = new Messaging.InboundEmail() ;
                emails.PlainTextBody ='STATUS:\nSuccess\n FILE NAME:\n00001026.pdf\n';
                FcEmailService.handleInboundEmail(emails,null);
                Messaging.InboundEmailResult result = FcEmailService.handleInboundEmail(emails, null);
                System.assertEquals( result.Success , true);
        }
}
