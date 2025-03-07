/**********************************************************************************************
* @Author:      Deepak 
* @Date:        21 Nov 2024
* @Description: The purpose of this class is to create methods which can be used by different trigger event
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
                21 Nov -  EDRD-             -  Accenture   -  Processes the Status category logic for after-insert triggers on OmniScriptSavedSession.
                08 Nov -  EDRD-             -  Accenture   -  Processes the Status category logic for after-insert triggers on OmniScriptSavedSession based on omniProcessId.
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
                nameToUserIdMap.put(session.Name, session.createdById);  
            }                      
        }
        
        if (nameToUserIdMap.isEmpty()) {
            return; 
        }
        
        List<OmniScriptSavedSession> existingSessions = [SELECT Id, CreatedDate, StatusCategory FROM OmniScriptSavedSession WHERE Name IN :nameToUserIdMap.keySet()
                                                         AND CreatedById IN :nameToUserIdMap.values() AND StatusCategory = 'In Progress' 
                                                         AND Id NOT IN :sessionIdVsNewRec.keyset() AND CreatedDate = LAST_N_DAYS:90];
        
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
                omniScriptToUserIdMap.put(session.OmniScriptId, session.CreatedById);
            }
        }
        
       if (omniScriptToUserIdMap.isEmpty()) {
            return;
        }
        
        List<OmniScriptSavedSession> existingSessions = [SELECT Id, CreatedDate, StatusCategory FROM OmniScriptSavedSession 
                                                         WHERE OmniScriptId IN :omniScriptToUserIdMap.keySet() AND CreatedById IN :omniScriptToUserIdMap.values()
                                                         AND StatusCategory = 'In Progress' AND Id NOT IN :sessionIdVsNewRec.keySet() AND CreatedDate = LAST_N_DAYS:90];
        
        
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
}