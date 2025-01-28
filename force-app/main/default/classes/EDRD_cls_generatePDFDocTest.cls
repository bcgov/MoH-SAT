/**********************************************************************************************
* @Author:      Accenture 
* @Date:        15 Jan 2025
* @Description: The purpose of this class is to cover Code coverage of EDRD_cls_generatePDFDoc.
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]  
***********************************************************************************************/
@isTest
public class EDRD_cls_generatePDFDocTest {
    
/**
* @author: Deepak
* @date: 25 Aug 2024
* @description: The purpose of this method is to cover Testcoverage of generateForecastRecords
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/    
    @isTest
    public static void EDRD_cls_IndefiniteBatchExecute_Test(){
        Account providerAccount = TestFactory.newProvider('Provider Test');
        insert providerAccount;
        Id recordTypeCaseEDRD = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('EDRD').getRecordTypeId();
        List<Case> caseRecord = TestFactory.createEDRDCase(1, recordTypeCaseEDRD, providerAccount.Id);
        insert caseRecord;
        Assessment assessmentRec = TestFactory.createEDRDAssessment(caseRecord[0].Id);
        insert assessmentRec;
        DocumentTemplate testDocumentTemplate = new DocumentTemplate(Name = 'EDRD BC DocGen-Template',
                                                                    Type = 'MicrosoftWord',
                                                                    TokenMappingType = 'JSON',
                                                                    TokenMappingMethodType = 'CustomClass',
                                                                    CustomClassName = 'EDRD_cls_generatePDFDoc');
        insert testDocumentTemplate;
        
        System.debug('testDocumentTemplate' + testDocumentTemplate.id);
        
        ContentVersion testContentVersion = new ContentVersion( Title = 'EDRD BC DocGen-Template',
                                                               PathOnClient = 'TestDoc.pdf',
                                                               VersionData = Blob.valueOf('Test content'),
                                                               IsMajorVersion = true); 
        insert testContentVersion;
        EDRD_cls_generatePDFDoc.requestText = label.EDRD_label_DocGen_requestText.replace('CVID', testContentVersion.Id);
        
        System.debug('testContentVersion' + [Select id, title from ContentVersion where Title = 'EDRD BC DocGen-Template']);
        
        Map<String, String> keyVsValue = new Map<String, String>{ 'TOKENDATA' => 'TestTokenData', 'RECORDID' => assessmentRec.Id};
            
        Test.startTest();
        EDRD_cls_generatePDFDoc.createDocumentGenerationProcessRequest(keyVsValue);
        Test.stopTest();
        
        List<DocumentGenerationProcess> generatedProcesses = [SELECT Id, Type, RequestText, ReferenceObject, TokenData, DocGenApiVersionType, DocumentTemplateId 
                                                              FROM DocumentGenerationProcess];
        
        Assert.areEqual(1, generatedProcesses.size(), 'One DocumentGenerationProcess record should be created.');
        Assert.areEqual('GenerateAndConvert', generatedProcesses[0].Type, 'Type should be GenerateAndConvert.');
        Assert.areEqual(caseRecord[0].Id, generatedProcesses[0].ReferenceObject, 'ReferenceObject should match the Case Id.');
        Assert.areEqual('TestTokenData', generatedProcesses[0].TokenData, 'TokenData should match the input value.');
       // Assert.areEqual(testDocumentTemplate.Id, generatedProcesses[0].DocumentTemplateId, 'DocumentTemplateId should match the test template.');
    }

}