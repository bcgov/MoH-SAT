/**********************************************************************************************
* @Author:      Accenture 
* @Date:        28 April 2025
* @Description: The purpose of this Controller class for fetching, counting, and managing OmniScript saved sessions in Salesforce.
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description] 
                18-Jun -   EDRD-1417        -   Accenture  -  Retrieves a paginated and sorted list of "In Progress" OmniScript saved sessions.
                18-Jun -   EDRD-1417        -   Accenture  -  Returns the total count of "In Progress" OmniScript saved sessions.
                18-Jun -   EDRD-1417        -   Accenture  -  Reassigns session and related attachments' ownership to the current user and returns the session’s resume URL.
***********************************************************************************************/
public with sharing class EDRD_cls_OmniSavedSessionController {

/**
* @author: Deepak
* @date: 18 Jun 2025
* @description: The purpose of this method is to retrieves a paginated and sorted list of "In Progress" OmniScript saved sessions.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/     
    @AuraEnabled(cacheable=true)
    public static List<OmniScriptSavedSession> getSessions(Integer pageSize, Integer pageNumber, String sortBy, String sortDirection, String viewMode) {
        Id currentUserId = UserInfo.getUserId();
        Integer offsetSize = (pageNumber - 1) * pageSize;

        String baseQuery = 'SELECT Id, Draft_Name__c, StatusCategory, CreatedDate, LastModifiedDate, CreatedBy.Name, LastModifiedBy.Name ' +
                           'FROM OmniScriptSavedSession WHERE StatusCategory = \'In Progress\'';
        
        if (viewMode == 'MyDrafts') {
            baseQuery += ' AND OwnerId = \'' + currentUserId + '\'';
        } else if (viewMode == 'MyTeamDrafts') {
            baseQuery += ' AND OwnerId != \'' + currentUserId + '\'';
        }

        baseQuery += ' ORDER BY ' + sortBy + ' ' + sortDirection +
                     ' LIMIT ' + pageSize + ' OFFSET ' + offsetSize;

        return Database.query(baseQuery);
    }

/**
* @author: Deepak
* @date: 18 Jun 2025
* @description: The purpose of this method is to returns the total count of "In Progress" OmniScript saved sessions.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/  
    @AuraEnabled(cacheable=true)
    public static Integer getSessionCount(String viewMode){
        Id currentUserId = UserInfo.getUserId();
        String baseQuery = 'SELECT COUNT() FROM OmniScriptSavedSession WHERE StatusCategory = \'In Progress\'';
        
        if (viewMode == 'MyDrafts') {
            baseQuery += ' AND OwnerId = \'' + currentUserId + '\'';
        } else if (viewMode == 'MyTeamDrafts') {
            baseQuery += ' AND OwnerId != \'' + currentUserId + '\'';
        }        
        return Database.countQuery(baseQuery);
    }

/**
* @author: Deepak
* @date: 18 Jun 2025
* @description: The purpose of this method is to reassigns session and related attachments' ownership to the current user and returns the session’s resume URL.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/      
    @AuraEnabled
    public static String launchSession(String recordId) {
        OmniScriptSavedSession sessionRecord = [SELECT Id, ResumeUrl FROM OmniScriptSavedSession WHERE Id = :recordId LIMIT 1];
        
        sessionRecord.OwnerId = UserInfo.getUserId();
        
        update sessionRecord;
        
        List<Attachment> attachments = [SELECT Id, OwnerId FROM Attachment WHERE ParentId = :recordId];
        
        for (Attachment att : attachments) {
            att.OwnerId = UserInfo.getUserId();
        }
        if (!attachments.isEmpty()) {
            update attachments;
        }        
        return sessionRecord.ResumeUrl;
    }
}