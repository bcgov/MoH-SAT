/**********************************************************************************************
* @Author:      Deepak 
* @Date:        02 March 2023
* @Description: The purpose of this class is to create Test data
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
***********************************************************************************************/
@istest
public class ESA_cls_utilityTest {

/**
* @author: Deepak
* @date: 02 March 2023
* @description: The purpose of this method is to create Test case record.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/  
@isTest
    public static case createCase(){
        case caseObj = new case();
        caseObj.ESA_Approval_Time_Unit__c = ESA_cls_constants.Case_Approval_Time_Unit_Week;
        caseObj.ESA_Approval_Time__c = 7;
        return caseObj;
    }    
}