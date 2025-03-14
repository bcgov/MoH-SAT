/**********************************************************************************************
* @Author:      CGI
* @Date:        14/03/2025
* @Description: The purpose of this class is to cover Code coverage of EDRD_SendNewCaseCreationNotification
*******************************************************************************************************************************/
@isTest
public class EDRD_SendNewCaseCreationNotif_Test {    
    @isTest  (seeAllData=true) static void testSendNewCaseCreationNotif(){
        Id caseRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('EDRD').getRecordTypeId();
        List<case> caseLst = new List<case>();
        Case testCase = new Case(
            Subject = 'Test Case',
            Description ='Test',
            Type = 'New',
            RecordTypeId = caseRecType);
       
        insert testCase;
        caseLst.add(testCase);
                 
        Test.startTest();
        EDRD_SendNewCaseCreationNotification.sendNewCaseCreationEmailNotificationTo(caseLst);
        Test.stopTest();
    }

}