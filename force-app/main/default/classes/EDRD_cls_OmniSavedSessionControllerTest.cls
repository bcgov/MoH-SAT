/**********************************************************************************************
* @Author:      Deepak 
* @Date:        23/02/2023
* @Description: The purpose of this class is to cover Code coverage of EDRD_cls_OmniSavedSessionController
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]  
                18-Jun -   EDRD-1417        -   Accenture  -  Retrieves a paginated and sorted list of "In Progress" OmniScript saved sessions.
                18-Jun -   EDRD-1417        -   Accenture  -  Returns the total count of "In Progress" OmniScript saved sessions.
                18-Jun -   EDRD-1417        -   Accenture  -  Reassigns session and related attachments' ownership to the current user and returns the session’s resume URL.
***********************************************************************************************/

@isTest
public class EDRD_cls_OmniSavedSessionControllerTest {
    
    @testSetup static void dataSetup(){
        List<OmniScriptSavedSession> sessionList = TestFactory.createOmniScriptSavedSessions(3);        
        insert sessionList;
        
        Attachment attRec = new Attachment(Name = 'TestAttachment.txt', Body = Blob.valueOf('Test Data'), ParentId = sessionList[0].Id);
        insert attRec;
        
        Account providerTest = TestFactory.newProvider('Provider Test');
        insert providerTest;
        Profile profileObj = [SELECT Id, UserLicense.Name FROM Profile WHERE Name = 'EDRD Prescriber Community User' 
                              AND UserLicense.Name = 'Customer Community Plus' LIMIT 1];
        
        Id contactId = [SELECT Id FROM Contact WHERE AccountID =: providerTest.Id].get(0).Id;
        User communityUser = TestFactory.createCommunityUser(contactId, profileObj.Id, 'Test1', 'Test');
        insert communityUser;
    }
    
/**
* @author: Deepak
* @date: 18 Jun 2025
* @description: The purpose of this method is to cover Testcoverage of getSessions
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/  
    
    @isTest
    public static void getSessionsTest(){
        User communityUser = [SELECT Id FROM User WHERE Profile.Name = 'EDRD Prescriber Community User' LIMIT 1 ];
        
        OmniScriptSavedSession sessionRec = [SELECT Id, OwnerId FROM OmniScriptSavedSession WHERE StatusCategory = 'In Progress' LIMIT 1];
        sessionRec.OwnerId = communityUser.Id;
        Update sessionRec;
        
        Test.startTest();
        List<OmniScriptSavedSession> myDraftsresults = EDRD_cls_OmniSavedSessionController.getSessions(10, 1, 'CreatedDate', 'DESC', 'MyDrafts');
        List<OmniScriptSavedSession> myTeamDraftsresults = EDRD_cls_OmniSavedSessionController.getSessions(10, 1, 'CreatedDate', 'DESC', 'MyTeamDrafts');
        Test.stopTest();

        Assert.areEqual(2, myDraftsresults.size(), 'Should return paginated session list');
        Assert.areNotEqual(NULL, myDraftsresults, 'results should not be null');
        Assert.areEqual(1, myTeamDraftsresults.size(), 'Should return paginated session list');
        Assert.areNotEqual(NULL, myTeamDraftsresults, 'results should not be null');
    }
    
/**
* @author: Deepak
* @date: 18 Jun 2025
* @description: The purpose of this method is to cover Testcoverage of getSessionCount
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/ 
    @isTest
    public static void getSessionCountTest(){
        Id communityUserId = [SELECT Id FROM User WHERE Profile.Name = 'EDRD Prescriber Community User' LIMIT 1 ].Id;
        
        OmniScriptSavedSession sessionObj = [SELECT Id, OwnerId FROM OmniScriptSavedSession WHERE StatusCategory = 'In Progress' LIMIT 1];
        sessionObj.OwnerId = communityUserId;
        Update sessionObj;
        
        Test.startTest();
        Integer countMyTeamDrafts = EDRD_cls_OmniSavedSessionController.getSessionCount('MyTeamDrafts');
        Integer countMyDrafts = EDRD_cls_OmniSavedSessionController.getSessionCount('MyDrafts');
        Test.stopTest();

        Assert.areEqual(2, countMyDrafts, 'Should return correct count for according to MyDrafts');
        Assert.areNotEqual(NULL, countMyDrafts, 'countMyDrafts URL should not be null');
        Assert.areEqual(1, countMyTeamDrafts, 'Should return correct count for according to MyTeamDrafts');
        Assert.areNotEqual(NULL, countMyTeamDrafts, 'countMyTeamDrafts should not be null');
    }
    
/**
* @author: Deepak
* @date: 18 Jun 2025
* @description: The purpose of this method is to cover Testcoverage of launchSession
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/      
   @isTest
    public static void launchSessionTest(){
        OmniScriptSavedSession session = [SELECT Id, ResumeURL FROM OmniScriptSavedSession WHERE StatusCategory = 'In Progress' LIMIT 1];
        session.ResumeURL = 'www.google.com';
        Update session;

        Test.startTest();
        String resumeUrl = EDRD_cls_OmniSavedSessionController.launchSession(session.Id);
        Test.stopTest();

        Assert.areEqual(session.ResumeUrl, resumeUrl, 'Resume URL should match the session');
        Assert.areNotEqual(NULL, resumeUrl, 'Resume URL should not be null');
    }    
}