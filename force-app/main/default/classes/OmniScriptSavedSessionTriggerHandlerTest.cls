/**********************************************************************************************
* @Author:      Accenture 
* @Date:        21 Nov 2024
* @Description: The purpose of this class is to cover Code coverage of OmniScriptSavedSessionTriggerHandler
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
                21 Nov -  EDRD-             -  Accenture   -  Processes the Status category logic for after-insert triggers on OmniScriptSavedSession.
                08 Nov -  EDRD-             -  Accenture   -  Processes the Status category logic for after-insert triggers on OmniScriptSavedSession based on omniProcessId.
                29 Jun -  EDRD-1483         -  Accenture   -  The purpose of this method is to manually share OmniScriptSavedSession Rec based on PG present in ResumeURL.
                29 Jun -  EDRD-1483         -  Accenture   -  The purpose of this private method is to return PG Id from URL.
***********************************************************************************************/
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
    
/**
* @author: Accenture
* @date: 21 Nov 2024
* @description: The purpose of this method is to cover Testcoverage of ProcessAfterInsert
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/     
    @isTest
    static void testProcessAfterInsert() {
        List<OmniScriptSavedSession> existingSessions = [SELECT Id, Name, StatusCategory, CreatedById FROM OmniScriptSavedSession WHERE Name =: 'Session 1' LIMIT 1];
        List<OmniScriptSavedSession> updatedSessionsList = new List<OmniScriptSavedSession>();
        
		// Create a new session with a different name
        OmniScriptSavedSession newSession = new OmniScriptSavedSession(
            Name = 'New Session',
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

/**
* @author: Accenture
* @date: 21 Nov 2024
* @description: The purpose of this method is to cover Testcoverage of ProcessAfterInsertByOmniScriptId
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/     
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
    
/**
* @author: Deepak
* @date: 29 Jun 2025
* @description: The purpose of this method is to cover Testcoverage of shareSavedSessionsRecToProviderPG/extractProviderPGId.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/ 
    @isTest
    public static void shareSavedSessionsRecToProviderPGTest() {
        Group testGroup = new Group(Name = 'Test Provider Group', Type = 'Regular');
        insert testGroup;
        
        List<OmniScriptSavedSession> sessionList = TestFactory.createOmniScriptSavedSessions(1);
        sessionList[0].ResumeUrl = 'https://example.com/?c__ProviderPGId=' + EncodingUtil.urlEncode(testGroup.Id, 'UTF-8');
        
        Test.startTest();
        insert sessionList;
        Test.stopTest();
        
        List<OmniScriptSavedSessionShare> shareRecords = [SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM OmniScriptSavedSessionShare 
                                                          WHERE ParentId =: sessionList[0].Id AND RowCause = 'Manual'];
        
        Assert.areEqual(1, shareRecords.size(), 'One share record should be created');
        Assert.areEqual(testGroup.Id, shareRecords[0].UserOrGroupId, 'Shared with correct group');
        Assert.areEqual('Edit', shareRecords[0].AccessLevel, 'AccessLevel should be Edit');
        Assert.areEqual(Schema.OmniScriptSavedSessionShare.RowCause.Manual, shareRecords[0].RowCause, 'RowCause should be Manual');     
    }
}