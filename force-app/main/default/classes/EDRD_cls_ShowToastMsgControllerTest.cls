/**********************************************************************************************
* @Author:      Deepak 
* @Date:        19 Jul 2024
* @Description: The purpose of this class is to is to cover Code coverage of EDRD_cls_ShowToastMsgController.
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]  
***********************************************************************************************/
@isTest
public class EDRD_cls_ShowToastMsgControllerTest {
    
/**
* @author: Deepak
* @date: 19 Jul 2024
* @description: The purpose of this method is to cover Testcoverage of isAttachmentPresent
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/    
    @isTest
    public static void isAttachmentPresentTest(){
        Account requestorAccountRec = TestFactory.newProvider('Provider Test');
        insert requestorAccountRec;
        Id recordTypeCaseEDRD = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('EDRD').getRecordTypeId();
        List<Case> caseList = TestFactory.createEDRDCase(1, recordTypeCaseEDRD, RequestorAccountRec.Id);
        insert caseList;
        ContentDocumentLink cDLOnCase = TestFactory.createContentDocumentLinkOnCase(caseList.get(0).Id);
        insert cDLOnCase;
        Test.startTest();        
        Boolean isAttPresent = EDRD_cls_ShowToastMsgController.isAttachmentPresent(caseList.get(0).Id);
        Test.stopTest();
        Assert.areEqual(true, isAttPresent,'Attachment is not present');
        Assert.areNotEqual(false, isAttPresent,'Attachment is present');
    }
}