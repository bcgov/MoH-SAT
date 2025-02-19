/**********************************************************************************************
* @Author:      Accenture 
* @Date:        15 Jan 2025
* @Description: The purpose of this class is to cover Code coverage of ContentDocumentLinkTriggerHandler.
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]  
                21-Jan -  EDRD-1112         -  Deepak      -  Test Method for getDocumentGenerated & deleteDocumentGenerated.
***********************************************************************************************/
@isTest
public class ContentDocumentLinkTriggerHandlerTest {
    
/**
* @author: Deepak
* @date: 21 Jan 2025
* @description: The purpose of this method is to cover Testcoverage of getDocumentGenerated & deleteDocumentGenerated.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/        
    @isTest
    public static void getNDeleteDocumentGenerated_Test(){
        Account prescriberAccount = TestFactory.newProvider('Provider Test');
        insert prescriberAccount;
        Id recordTypeCaseEDRD = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('EDRD').getRecordTypeId();
        List<Case> caseRecord = TestFactory.createEDRDCase(1, recordTypeCaseEDRD, prescriberAccount.Id);
        insert caseRecord;
        Assessment assessmentRecord = TestFactory.createEDRDAssessment(caseRecord[0].Id);
        insert assessmentRecord;
        DocumentTemplate testDocumentTemplate = new DocumentTemplate(Name = 'EDRD BC DocGen-Template',
                                                                     Type = 'MicrosoftWord',
                                                                     TokenMappingType = 'JSON',
                                                                     TokenMappingMethodType = 'CustomClass',
                                                                     CustomClassName = 'EDRD_cls_generatePDFDoc');
        insert testDocumentTemplate;
        
        ContentVersion testContentVersionRec = new ContentVersion( Title = 'EDRD BC DocGen-Template',
                                                                  PathOnClient = 'TestDoc.pdf',
                                                                  VersionData = Blob.valueOf('Test content'),
                                                                  IsMajorVersion = true); 
        insert testContentVersionRec;
        
        EDRD_cls_generatePDFDoc.requestText = label.EDRD_label_DocGen_requestText.replace('CVID', testContentVersionRec.Id);
        
        Map<String, String> keyVsValue = new Map<String, String>{ 'TOKENDATA' => 'TestTokenData', 'RECORDID' => assessmentRecord.Id};
            
        Test.startTest();                
        EDRD_cls_generatePDFDoc.createDocumentGenerationProcessRequest(keyVsValue);        
        Test.stopTest();
        
        List<ContentVersion> ContentVersions = [SELECT Id FROM ContentVersion WHERE Id =: testContentVersionRec.Id];
        Assert.areEqual(1, ContentVersions.size(), 'The ContentVersion should not be deleted.');
        
        List<DocumentTemplate> existingTemplates = [SELECT Id FROM DocumentTemplate WHERE Name = 'EDRD BC DocGen-Template'];
        Assert.areNotEqual(0, existingTemplates.size(), 'The DocumentTemplate should not be deleted.');
        
    }
}