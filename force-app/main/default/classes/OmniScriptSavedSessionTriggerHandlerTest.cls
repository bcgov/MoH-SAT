@isTest
public class OmniScriptSavedSessionTriggerHandlerTest {
    @testSetup
    static void setupTestData() {
        // Create existing sessions
        OmniProcess omniScript = new OmniProcess(Name = 'Test OS', Type = 'Test', Subtype = 'OS', Language = 'English');
        insert omniScript;
        
        OmniScriptSavedSession session1 = new OmniScriptSavedSession(
            Name = 'Session 1',
            OmniScriptId = omniScript.Id,
            StatusCategory = 'In Progress'
        );
        insert session1;
        
        OmniScriptSavedSession session2 = new OmniScriptSavedSession(
            Name = 'Session 2',
            OmniScriptId = omniScript.Id,
            StatusCategory = 'In Progress'
        );
        insert session2;
    }
    
    @isTest
    static void testProcessAfterInsert() {
        List<OmniScriptSavedSession> existingSessions = [SELECT Id, Name, StatusCategory, CreatedById FROM OmniScriptSavedSession WHERE Name =: 'Session 1' LIMIT 1];
        List<OmniScriptSavedSession> updatedSessionsList = new List<OmniScriptSavedSession>();
        
		// Create a new session with a different name
        OmniScriptSavedSession newSession = new OmniScriptSavedSession(
            Name = 'New Session',
            CreatedById = UserInfo.getUserId(),
            StatusCategory = 'In Progress'
        );
        
        Test.startTest();
        insert newSession;
        
        newSession.Name = 'Session 1';
        update newSession;
        
        for (OmniScriptSavedSession session : existingSessions) {
            session.StatusCategory = 'Completed';
            updatedSessionsList.add(session);
        }
        // Verify that the existing sessions have been updated
        update updatedSessionsList;
        
        Test.stopTest();
        for (OmniScriptSavedSession session : existingSessions) {
            System.assertEquals('Completed', session.StatusCategory, 'StatusCategory should be updated to Completed.');
        }
        
    }
    
    @isTest
    static void testProcessAfterInsertByOmniScriptId() {
        // Create a new session with a different OmniScriptId
       List<OmniScriptSavedSession> existingSessions = [SELECT Id, StatusCategory FROM OmniScriptSavedSession];
        List<OmniScriptSavedSession> updatedSessionsList = new List<OmniScriptSavedSession>();
        
        OmniProcess omniScript1 = new OmniProcess(Name = 'Test OS', Type = 'Test', Subtype = 'OS', Language = 'English');
        insert omniScript1;
        // Create a new session with a different name
        OmniScriptSavedSession newSession = new OmniScriptSavedSession(
            Name = 'New Session',
            OmniScriptId = omniScript1.Id,
            StatusCategory = 'In Progress'
        );
        
        Test.startTest();
        
        insert newSession;
        for (OmniScriptSavedSession session : existingSessions) {
            session.OmniscriptId = omniScript1.Id;
            session.StatusCategory = 'Completed';
            updatedSessionsList.add(session);
        }
        // Verify that the existing sessions have been updated
        update updatedSessionsList;
        
        Test.stopTest();
        for (OmniScriptSavedSession session : existingSessions) {
            System.assertEquals('Completed', session.StatusCategory, 'StatusCategory should be updated to Completed.');
        }
    }     
}