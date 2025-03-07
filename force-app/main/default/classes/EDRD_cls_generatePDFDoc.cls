/**********************************************************************************************
* @Author:      Accenture 
* @Date:        07 Jan 2025
* @Description: The purpose of this class is to GenerateAndConvert Assessment responses into Word & PDF.
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]
                07 Jan -  EDRD-1112         -  Accenture   - method is to return sessionId
***********************************************************************************************/
public with sharing class EDRD_cls_generatePDFDoc {
    public static String requestText = '';
    
/**
* @author: Deepak
* @date: 07 Jan 2025
* @description: The purpose of this method is to insert the DocumentGenerationProcess request.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/ 
    @AuraEnabled
    public static void createDocumentGenerationProcessRequest(Map<String, String> keyVsValue) {
        
        if(!test.IsRunningTest()){
        List<ContentVersion> conVersionList = [SELECT Id, Title, CreatedDate FROM ContentVersion WHERE TITLE = 'EDRD BC DocGen-Template.docx' ORDER BY CreatedDate DESC LIMIT 2];
        requestText = label.EDRD_label_DocGen_requestText.replace('CVID', conVersionList[1].Id);
        }
        
        String type = 'GenerateAndConvert'; 
        List<DocumentTemplate> docTemplateList = [SELECT Id, Name FROM DocumentTemplate WHERE Name = 'EDRD BC DocGen-Template' LIMIT 1];
        
        String responseText = (keyVsValue.get('TOKENDATA'));
        String assessmentRecordId = keyVsValue.get('RECORDID');
        
        List<Assessment> assessmentList = [SELECT Id, CaseId FROM Assessment WHERE Id =: assessmentRecordId LIMIT 1];
        
        String caseRecordId = (assessmentList.isEmpty()) ? null : assessmentList[0].CaseId;
        
        List<ContentDocumentLink> caseCDLCheckList = [SELECT Id, LinkedEntityId, ContentDocument.title, ContentDocument.FileType FROM ContentDocumentLink 
                                                      WHERE LinkedEntityId =: caseRecordId AND ContentDocument.title = 'Eform Responses' AND ContentDocument.FileType = 'PDF'];
        
        if(caseCDLCheckList.isEmpty()){
            DocumentGenerationProcess request = new DocumentGenerationProcess(); 
            request.Type = type;
            request.RequestText = requestText; 
            request.ReferenceObject = caseRecordId;
            request.TokenData = responseText; 
            request.DocGenApiVersionType = 'Advanced'; 
            request.DocumentTemplateId = docTemplateList[0].Id;               
            insert request; 
        }
    }        
}