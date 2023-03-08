/**********************************************************************************************
* @Author:      Deepak 
* @Date:        23/02/2023
* @Description: The purpose of this class is to cover Code coverage of ESA_cls_caseTriggerHandler
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
***********************************************************************************************/

@isTest
public class ESA_cls_caseTriggerHandlerTest {
    
/**
* @author: Deepak
* @date: 23 Feb 2023
* @description: The purpose of this method is to cover Testcoverage
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
}