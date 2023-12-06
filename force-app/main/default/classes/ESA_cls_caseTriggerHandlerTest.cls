/**********************************************************************************************
* @Author:      Deepak 
* @Date:        23/02/2023
* @Description: The purpose of this class is to cover Code coverage of ESA_cls_caseTriggerHandler
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]  
                1 Dec23 -   EDRD-170        -   Rahul      -  Manage case assignment
                4 Dec23 -   EDRD-332        -  Accenture   -  Change case status according to RPH, SC, AC Review Field
***********************************************************************************************/

@isTest
public class ESA_cls_caseTriggerHandlerTest {
    
/**
* @author: Deepak
* @date: 23 Feb 2023
* @description: The purpose of this method is to cover Testcoverage of populateTerminationDate
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/  
    
    @isTest
    public static void populateTerminationDate_positive(){
        
        List<Case> allCases = new List<Case>();     
        for(integer i=0; i<5; i++){
            Case c = new case();
            c.Termination_date__c = NULL;
            c.ESA_Approval_Time_Unit__c = ESA_cls_constants.CASE_APPROVAL_TIME_UNIT_WEEK;
            c.ESA_Approval_Time__c = 7;    
            allCases.add(c);
        }
        insert allCases;
        List<case> caseLst = [select id, termination_date__c from Case where id =: allCases[0].id]; 
        system.assertEquals(caseLst[0].termination_date__c, system.Today().addDays((7*7)+1));
        for(case c:allCases){
            c.ESA_Approval_Time_Unit__c = ESA_cls_constants.CASE_APPROVAL_TIME_UNIT_DAYS;
            c.ESA_Approval_Time__c = 7;    
        }
        Update allCases;
        caseLst = [select id, termination_date__c from Case where id =: allCases[0].id]; 
        system.assertEquals(caseLst[0].termination_date__c, system.Today().addDays(7+1));
        for(case c:allCases){
            c.ESA_Approval_Time_Unit__c = NULL;
            c.ESA_Approval_Time__c = NULL;    
        }
        Update allCases;
        caseLst = [select id, termination_date__c from Case where id =: allCases[0].id]; 
        system.assertEquals(caseLst[0].termination_date__c, NULL);
    }
    /**
* @author: Rahul
* @date: 04 Dec 2023
* @description: The purpose of this method is to cover Testcoverage of manageAssignmentRule
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/ 
    @isTest public static void manageAssignmentRuleTest(){
        Id caseRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('EDRD').getRecordTypeId();
        Case testCase = new Case(
            Subject = 'Test Case',
            Description ='Test');
        insert testCase;
        testCase.subject ='Test Case 1';
        testCase.RecordTypeId = caseRecType;
        Test.startTest();
        update testCase;
        Test.stopTest();
        Case caCheck = [ SELECT Id,Owner.Name, OwnerId FROM Case WHERE Id =: testCase.Id ];
        Assert.areNotEqual(Userinfo.getUserId(), caCheck.OwnerId, 'Should be not be the user');
        system.debug(caCheck.OwnerId);
        String sub = 'abcde'.substring(2);
        Assert.areEqual('00G',String.valueOf(caCheck.OwnerId).substring(0,3));
    }
/**
* @author: Deepak
* @date: 04 Dec 2023
* @description: The purpose of this method is to cover Testcoverage of assignStatus
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/      
   @isTest
    public static void assignStatusTest(){
        List<Case> allCases = new List<Case>();  
        for(integer i=0; i<3; i++){
            Case caseObj = new case();
            caseObj.EDRD_RPH_Review_Pathway__c = '';
            caseObj.EDRD_SC_Review_Pathway__c = '';
            caseObj.EDRD_AC_Review_Pathway__c = '';
            allCases.add(caseObj);
        }
        insert allCases;        
        allCases[0].EDRD_RPH_Review_Pathway__c = 'Sent to SC';
        allCases[1].EDRD_SC_Review_Pathway__c = 'Sent to AC';
        allCases[2].EDRD_AC_Review_Pathway__c = 'Sent to MOH';
        Test.startTest();
        Update allCases;
        Test.stopTest();
        Assert.areEqual([SELECT Id, Status FROM Case WHERE Id =: allCases[0].id].Status, 'SC Review', 'Status has not updated as SC Review');
        Assert.areNotEqual([SELECT Id, Status FROM Case WHERE Id =: allCases[0].id].Status, NULL, 'Status has been updated as Null');
        Assert.areEqual([SELECT Id, Status FROM Case WHERE Id =: allCases[1].id].Status, 'AC Review', 'Status has not updated as AC Review');
        Assert.areNotEqual([SELECT Id, Status FROM Case WHERE Id =: allCases[1].id].Status, NULL, 'Status has been updated as Null');
        Assert.areEqual([SELECT Id, Status FROM Case WHERE Id =: allCases[2].id].Status, 'MOH Review', 'Status has not updated as MOH Review');
        Assert.areNotEqual([SELECT Id, Status FROM Case WHERE Id =: allCases[2].id].Status, NULL, 'Status has been updated as Null');
    }
}