/**********************************************************************************************
* @Author:      Accenture 
* @Date:        21 Nov 2024
* @Description: The purpose of this class is to create methods which can be used by different trigger event
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
                21 Nov -  EDRD-             -  Accenture   -  Processes the Status category logic for after-insert triggers on OmniScriptSavedSession.
                08 Nov -  EDRD-             -  Accenture   -  Processes the Status category logic for after-insert triggers on OmniScriptSavedSession based on omniProcessId.
                29 Jun -  EDRD-1483         -  Accenture   -  The purpose of this method is to manually share OmniScriptSavedSession Rec based on PG present in ResumeURL.
                29 Jun -  EDRD-1483         -  Accenture   -  The purpose of this private method is to return PG Id from URL.
                08 Jul -  EDRD-1483         -  Accenture   -  Class/Methods is to perform DML in without Sharing Context.
***********************************************************************************************/
public with sharing class OmniScriptSavedSessionTriggerHandler {
/**
* @author: Deepak
* @date: 21 Nov 2024
* @description: The purpose of this method is to Processes the Status category logic for after-insert triggers on OmniScriptSavedSession.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/  
    public static void processAfterInsert(Map<Id, OmniScriptSavedSession> sessionIdVsNewRec, Map<Id, OmniScriptSavedSession> sessionIdVsOldRec) {
        Map<String, Id> nameToUserIdMap = new Map<String, Id>();
        for (OmniScriptSavedSession session : sessionIdVsNewRec.values()) { 
            if(sessionIdVsNewRec.get(session.Id).Name != sessionIdVsOldRec.get(session.Id).Name){
                nameToUserIdMap.put(session.Name, session.ownerId);  
            }                      
        }
        
        if (nameToUserIdMap.isEmpty()) {
            return; 
        }
        
        List<OmniScriptSavedSession> existingSessions = [SELECT Id, CreatedDate, StatusCategory FROM OmniScriptSavedSession WHERE Name IN :nameToUserIdMap.keySet()
                                                         AND ownerId IN :nameToUserIdMap.values() AND StatusCategory = 'In Progress' 
                                                         AND Id NOT IN :sessionIdVsNewRec.keyset()];
        
        List<OmniScriptSavedSession> sessionsToUpdate = new List<OmniScriptSavedSession>();
        for (OmniScriptSavedSession existingSession : existingSessions) {
            existingSession.StatusCategory = 'Completed';
            sessionsToUpdate.add(existingSession);
        }
        
        if (!sessionsToUpdate.isEmpty()) {
            try {
                Database.update(sessionsToUpdate, true);
            } catch (DmlException ex) {
                System.debug('Error updating OmniScriptSavedSession records: ' + ex.getMessage());
            }
        }
    }
    
/**
* @author: Deepak
* @date: 08 Dec 2024
* @description: The purpose of this method is to Processes the Status category logic for after-insert triggers on OmniScriptSavedSession based on omniProcessId.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/
   public static void processAfterInsertByOmniScriptId(Map<Id, OmniScriptSavedSession> sessionIdVsNewRec,Map<Id, OmniScriptSavedSession> sessionIdVsOldRec){
        
        Map<Id, Id> omniScriptToUserIdMap = new Map<Id, Id>();
        
        for (OmniScriptSavedSession session : sessionIdVsNewRec.values()) {
            if (sessionIdVsNewRec.get(session.Id).OmniScriptId != sessionIdVsOldRec.get(session.Id).OmniScriptId) {
                omniScriptToUserIdMap.put(session.OmniScriptId, session.OwnerId);
            }
        }
        
       if (omniScriptToUserIdMap.isEmpty()) {
            return;
        }
        
        List<OmniScriptSavedSession> existingSessions = [SELECT Id, CreatedDate, StatusCategory FROM OmniScriptSavedSession 
                                                         WHERE OmniScriptId IN :omniScriptToUserIdMap.keySet() AND OwnerId IN :omniScriptToUserIdMap.values()
                                                         AND StatusCategory = 'In Progress' AND Id NOT IN :sessionIdVsNewRec.keySet()];
        
        
        List<OmniScriptSavedSession> sessionsToUpdate = new List<OmniScriptSavedSession>();
        for (OmniScriptSavedSession existingSession : existingSessions) {
            existingSession.StatusCategory = 'Completed';
            sessionsToUpdate.add(existingSession);
        }
        
        if (!sessionsToUpdate.isEmpty()) {
            try {
                Database.update(sessionsToUpdate, true);
            } catch (DmlException ex) {
                System.debug('Error updating OmniScriptSavedSession records: ' + ex.getMessage());
            }
        }
    }   

/**
* @author: Deepak
* @date: 29 Jun 2025
* @description: The purpose of this method is to manually share OmniScriptSavedSession Rec based on PG present in ResumeURL.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/    
    public static void shareSavedSessionsRecToProviderPG(Map<Id, OmniScriptSavedSession> sessionIdVsNewRec, Map<Id, OmniScriptSavedSession> sessionIdVsOldRec) {
        Map<Id, String> sessionIdVsPGId = new Map<Id, String>();
        Set<Id> updatedSessionIds = new Set<Id>();
        List<OmniScriptSavedSessionShare> sharesRecToInsert = new List<OmniScriptSavedSessionShare>();
        
        for (Id sessionId : sessionIdVsNewRec.keySet()) {
            OmniScriptSavedSession newRec = sessionIdVsNewRec.get(sessionId);
            OmniScriptSavedSession oldRec = sessionIdVsOldRec.get(sessionId);
            
            if (((newRec.ResumeUrl != oldRec.ResumeUrl) || (newRec.OwnerId != oldRec.OwnerId)) && !String.isBlank(newRec.ResumeUrl)) {
                updatedSessionIds.add(sessionId);
            }
        }
        
        if (updatedSessionIds.isEmpty()) {
            return;
        }
        
        List<OmniScriptSavedSession> updatedSessions = new Elevated().returnOmniScriptSavedSessionList(updatedSessionIds);
        
        for (OmniScriptSavedSession sessionRec : updatedSessions) {
            if (sessionRec.ResumeUrl != null && sessionRec.ResumeUrl.contains('c__ProviderPGId=')) {
                String pgId = extractProviderPGId(sessionRec.ResumeUrl);
                if (pgId != 'null' && pgId.startsWith('00G')) {
                    sessionIdVsPGId.put(sessionRec.Id, pgId);
                }
            }
        }
        
        if (sessionIdVsPGId.isEmpty()) {
            return;
        }
        
        Map<Id, Group> validGroups = new Map<Id, Group>([SELECT Id FROM Group WHERE Id IN :sessionIdVsPGId.values()]);
        
        if (validGroups.isEmpty()) {
            return;
        }
        
        for (Id sessionId : sessionIdVsPGId.keySet()) {
            Id groupId = sessionIdVsPGId.get(sessionId);
            
            if (validGroups.containsKey(groupId)) {
                sharesRecToInsert.add(new OmniScriptSavedSessionShare(ParentId = sessionId, UserOrGroupId = groupId, AccessLevel = 'Edit',
                                                                      RowCause = Schema.OmniScriptSavedSessionShare.RowCause.Manual));
            }
        }
        
        if (!sharesRecToInsert.isEmpty()) {
            new Elevated().insertShareRecords(sharesRecToInsert);
        }
    }

/**
* @author: Deepak
* @date: 29 Jun 2024
* @description: The purpose of this private method is to return PG Id from URL.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/ 
    private static String extractProviderPGId(String url) {
        if (String.isBlank(url)) {
            return null;
        }
        
        String paramKey = 'c__ProviderPGId=';
        Integer startIndex = url.indexOf(paramKey);
        
        if (startIndex == -1) {
            return null;
        }
        
        startIndex += paramKey.length();
        Integer endIndex = url.indexOf('&', startIndex);
        
        if (endIndex == -1) {
            endIndex = url.length();
        }        
        String pgId = url.substring(startIndex, endIndex);
        
        return EncodingUtil.urlDecode(pgId, 'UTF-8');
    }
    
/**
* @author: Deepak
* @date: 08 July 2025
* @description: The purpose of this Class/Methods is to perform DML in without Sharing Context.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/     
    public without sharing class Elevated{
        public void insertShareRecords(List<OmniScriptSavedSessionShare> omniSciptSavedSessionShareToInsert){
            Database.Insert(omniSciptSavedSessionShareToInsert, true);
        }
        public List<OmniScriptSavedSession> returnOmniScriptSavedSessionList(Set<Id> omniScriptSavedSessionIds){
            List<OmniScriptSavedSession> omniScriptSavedSessionList = [SELECT Id, ResumeURL From OmniScriptSavedSession WHERE Id IN: omniScriptSavedSessionIds];
            return omniScriptSavedSessionList;
        }
    }
}