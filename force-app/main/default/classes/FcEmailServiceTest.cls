@isTest()
public class FcEmailServiceTest {
        static testMethod void test_find_value_positive() {
                String source = 'FILE NAME:1023.pdf';
                String result = new FcEmailService().findValues(source, 'FILE NAME:');
                System.debug(result);
                system.assertEquals('1023.pdf', result);
        }
        static testMethod void test_file_name_empty() {
                String source = 'FILE NAME:';
                String result = new FcEmailService().findValues(source, 'FILE NAME:');
                System.debug(result);
                system.assertEquals('', result);
        }
        static testMethod void test_store_email_positive() {
                Case record=new Case();
                insert record;
                Messaging.InboundEmail emails = new Messaging.InboundEmail() ;
                emails.PlainTextBody ='STATUS:Success\n FILE NAME:00001029.pdf\n';
                new FcEmailService().storeEmail(emails,record.id);
                System.assert(record.id!=null);    
        }
        static testMethod void test_update_case_positive() {
                Case record = new Case();
                record.Fax_Sent_Date__c = null;
                insert record;
                record=[Select Id, caseNumber from Case where Id=:record.id ];
                new FcEmailService().updateCase(record.caseNumber,'Success');
                Case results = [select Fax_Notification_Date__c,Fax_Sent_Date__c from Case where ID= :record.Id];
                System.debug(results.Fax_Notification_Date__c);
                System.assert(results.Fax_Sent_Date__c != null);
        }
        static testMethod void  test_update_case_negative() {
                Case record = new Case();
                record.Fax_Sent_Date__c = null;
                insert record;
                record=[Select Id, caseNumber from Case where Id=:record.id ];
                new FcEmailService().updateCase(record.caseNumber,'Failed');
                Case results = [select Fax_Notification_Date__c,Fax_Sent_Date__c from Case where ID= :record.Id];
                System.assert(results.Fax_Sent_Date__c == null);
        }
        static testMethod void TestingBoundEmail(){
                Messaging.InboundEmail emails = new Messaging.InboundEmail() ;
                emails.PlainTextBody ='STATUS:\nSuccess\n FILE NAME:\n00001026.pdf\n';
                new FcEmailService().handleInboundEmail(emails,null);
                Messaging.InboundEmailResult result = new FcEmailService().handleInboundEmail(emails, null);
                System.assertEquals( result.Success , true);
        }
}