/**********************************************************************************************
* @Author:      Accenture 
* @Date:        15 Jan 2025
* @Description: The purpose of this class is to cover Code coverage of EDRD_cls_generatePDFDoc.
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]  
***********************************************************************************************/
@isTest
public class EDRD_cls_AssessmentResponseServiceTest{
    
/**
* @author: Deepak
* @date: 15 Jan 2025
* @description: The purpose of this method is to cover Testcoverage of getAssessmentResponseSummary, getUserSessionId & EDRD_cls_Payload.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/        
    @isTest
    public static void getAssessmentResponseSummary_Test(){
        Account providerAccount = TestFactory.newProvider('Provider Test');
        insert providerAccount;
        Id recordTypeCaseEDRD = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('EDRD').getRecordTypeId();
        List<Case> caseRec = TestFactory.createEDRDCase(1, recordTypeCaseEDRD, providerAccount.Id);
        insert caseRec;
        Assessment assessmentRec = TestFactory.createEDRDAssessment(caseRec[0].Id);
        insert assessmentRec;
        
        Test.startTest();        
        EDRD_cls_AssessmentResponseService.getAssessmentResponseSummary(assessmentRec.Id);
        Test.stopTest();
    }
}