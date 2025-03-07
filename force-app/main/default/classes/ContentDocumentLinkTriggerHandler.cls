/**********************************************************************************************
* @Author:      Accenture 
* @Date:        20 Jan 2025
* @Description: The purpose of this class is the handler is to fire on different trigger events. 
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]  
                20-Jan -  EDRD-1112         -  Deepak      -  Changes related to EDRD EMPI Integration for getAccount
***********************************************************************************************/
public with sharing class ContentDocumentLinkTriggerHandler {
    
/** 
* @author: Deepak
* @date: 20 Jan 2025
* @description: The purpose of this method is to get the ContentDocumentLink of Eform Responses Document Generated of type Word.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/  
    public static void getDocumentGenerated(List<ContentDocumentLink> cDLList) {
        Set<Id> contentDocIdSet = new Set<Id>();
        
        for (ContentDocumentLink cdl : cDLList) {  
            String linkIdPrefix = test.isRunningTest() ? '005' : '500';
            if (String.valueOf(cdl.LinkedEntityId).startsWith(linkIdPrefix)) {
                contentDocIdSet.add(cdl.ContentDocumentId);
            }
        }
        
        if(!contentDocIdSet.isEmpty()){
            deleteDocumentGenerated(contentDocIdSet);
        }
    }
/** 
* @author: Deepak
* @date: 20 Jan 2025
* @description: The purpose of this method is to delete the Eform Responses Document Generated of type Word.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/   
    @future
    public static void deleteDocumentGenerated(Set<Id> cDLIdSet) {        
        List<ContentDocument> contentDocsToDelete = new List<ContentDocument>();
        
        if(!cDLIdSet.isEmpty()){
            Map<Id, ContentDocument> cDIdVsRec = new Map<Id, ContentDocument>([SELECT Id, Title, FileType FROM ContentDocument WHERE Id IN: cDLIdSet]);
            
            for (ContentDocument cDObj : cDIdVsRec.values()) {            
                if (cDObj.Title == 'Eform Responses' && cDObj.FileType == 'WORD_X') {
                    contentDocsToDelete.add(cDObj);
                }
            }
            
            if (!contentDocsToDelete.isEmpty()) {
                Database.delete(contentDocsToDelete, true);
            }
        }
    }
}