/**********************************************************************************************
* @Author:      Accenture 
* @Date:        24 Sept 2024
* @Description: The purpose of this class is to cover Code coverage of UserTriggerHandler
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]
                24Sept -  EDRD-911          -  Deepak   -  Added activateACROnEDRDPortalEnable_Test method
                07 Jan -  EDRD-1150         -  Accenture   -  Added handleEDRDPublicGroupMemberTest method
                02 Jul -  EDRD-1522		    -  Deepak   -  Added createGMForAlliedStaffRoleACRUsersTest method.
***********************************************************************************************/
@isTest
public class UserTriggerHandlerTest {
    
/**
* @author: Deepak
* @date: 24 Sept 2024
* @description: The purpose of this method is to cover Testcoverage of activateACROnAccportalEnable
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/    
    @isTest
    public static void activateACROnEDRDPortalEnable_Test(){
        Account patientAcc1 = TestFactory.newPatient('Patient1');
        insert patientAcc1;
        Account providerAcc = TestFactory.newProvider('Provider Test');
        providerAcc.Provider_Type__pc = 'Provider';
        insert providerAcc;
        
        Id patientContactId = [SELECT Id FROM Contact Where accountId =: patientAcc1.Id].get(0).Id;
        AccountContactRelation ACRObj = new AccountContactRelation();
        ACRObj.AccountId = providerAcc.Id;
        ACRObj.ContactId = patientContactId;
        ACRObj.Roles = ESA_cls_constants.EDRD_PHYSICIAN;
        ACRObj.IsActive = false;
        ACRObj.Is_EDRD_Data_Migration__c = true;
        insert ACRObj;
        
        Id ContactId = [SELECT Id FROM Contact WHERE AccountID =: providerAcc.Id].get(0).Id;
        
        Id recordTypeCaseEDRD = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('EDRD').getRecordTypeId();
        List<Case> eDRDCaseRecList = TestFactory.createEDRDCase(1, recordTypeCaseEDRD, providerAcc.Id);
        eDRDCaseRecList[0].Provider__c = ContactId;
        eDRDCaseRecList[0].Provider_Account__c = providerAcc.Id;
        insert eDRDCaseRecList;
        
        List<Medication> MediRecList = TestFactory.createMedication(1, 'Test Medication');
        insert MediRecList;
        List<MedicationRequest> MedicationRequestList = TestFactory.createMedicationRequest(1, MediRecList.get(0).Id, eDRDCaseRecList.get(0).Id, providerAcc.Id, patientAcc1.Id); 
        insert MedicationRequestList;
        Assessment assessmentRecord = TestFactory.createEDRDAssessment(eDRDCaseRecList[0].Id);
        insert assessmentRecord;
        
        Profile profileObj = [SELECT Id FROM Profile WHERE Name =: ESA_cls_constants.EDRD_PRESCRIBER_COMMUNITY_USER LIMIT 1];
        
        User accCommunityUser = TestFactory.createCommunityUser(ContactId, profileObj.Id, 'Provider', 'Test');
        
        Test.startTest();
        insert accCommunityUser;
        Test.stopTest();
        
        List<User> communityUser = [SELECT Id FROM User WHERE Id =: accCommunityUser.Id LIMIT 1];
        
        List<Account> accUser = [SELECT Id, IsCustomerPortal FROM Account WHERE Id =: providerAcc.Id LIMIT 1];
        
        List<AccountContactRelation> aCRList = [SELECT Id, AccountId, ContactId, Roles, Is_EDRD_Data_Migration__c, IsActive 
                                                FROM AccountContactRelation 
                                                WHERE AccountID =: providerAcc.Id LIMIT 1];
        
        List<MedicationRequest> mRList = [SELECT Id, OwnerId FROM MedicationRequest WHERE Id =: MedicationRequestList[0].Id];
        
        List<Assessment> assessmentList = [SELECT Id, OwnerId FROM Assessment WHERE Id =: assessmentRecord.Id];
        
        List<CaseTeamMember> cTMList = [SELECT Id, MemberId FROM CaseTeamMember WHERE ParentId =: eDRDCaseRecList[0].Id AND MemberId =: communityUser[0].Id];
        
        Assert.areEqual(accUser[0].IsCustomerPortal, True, 'Portal User should be Active');
        Assert.areEqual(aCRList[0].isActive, True, 'ACR should be Active');
        Assert.areEqual(communityUser[0].Id, mRList[0].OwnerId, 'Provisioned User(Provider) should be Medication Request OwnerId');
        Assert.areEqual(communityUser[0].Id, assessmentList[0].OwnerId, 'Provisioned User(Provider) should be Assessment OwnerId');
        Assert.areEqual(communityUser[0].Id, cTMList[0].MemberId, 'Provisioned User(Provider) should be Case Team Member');
        Assert.areEqual(cTMList.Size(), 1, 'Case Team Member should be One'); 
        Assert.areNotEqual(cTMList.Size(), null, 'Case Team Member should not be null'); 
    }
    
/**
* @author: Deepak
* @date: 07 Jan 2025
* @description: The purpose of this method is to cover Testcoverage of handleEDRDPublicGroupMember & handleGroupsForUsersAsync
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/    
    @isTest
    public static void handleEDRDPublicGroupMemberTest(){
        Account providerAcc = TestFactory.newProvider('Provider Test');
        providerAcc.Committee__pc = ESA_cls_constants.EDRD_PERSONACCOUNT_SC;
        providerAcc.Committee_Name__pc = ESA_cls_constants.EDRD_PERSONACCOUNT_SC_METABOLIC_SUBCOMMITTEE;
        providerAcc.Provider_Identifier__pc = '1112223';
        providerAcc.Provider_Type__pc = ESA_cls_constants.EDRD_PHYSICIAN;
        insert providerAcc;
        
        Id ContactId = [SELECT Id FROM Contact WHERE AccountID =: providerAcc.Id].get(0).Id;
        Profile profileRec = [SELECT Id FROM Profile WHERE Name = 'EDRD Prescriber Community User'];
        User communityUser = TestFactory.createCommunityUser(ContactId, profileRec.Id, 'Test1', 'Test');  
        
        Test.startTest();
        insert communityUser;
        Test.stopTest();
        
        List<GroupMember> groupMembers = [SELECT Id, GroupId, UserOrGroupId FROM GroupMember WHERE UserOrGroupId = :communityUser.Id];
        
        Assert.areEqual(TRUE, groupMembers.size() > 0, 'At least one GroupMember should be created for the community user.');
        Assert.areEqual(2, groupMembers.size(), 'Exactly one GroupMember should be created for the community user.'); 
        Assert.areNotEqual(null, groupMembers[0].GroupId, 'GroupMember should have a valid GroupId.');
    }
    
/**
* @author: Deepak
* @date: 02 Jul 2025
* @description: The purpose of this method is to cover Testcoverage of createGMForAlliedStaffRoleACRUsers
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/    
    @isTest
    public static void createGMForAlliedStaffRoleACRUsersTest(){
        List<Account> providerAccList = new List<Account>();
        Account pharmacistAccount = TestFactory.newProvider('Patient Test');
        providerAccList.add(pharmacistAccount);
        Account prescriberAccount = TestFactory.newProvider('Provider Test');
        prescriberAccount.Provider_Identifier__pc = '111222334';
        prescriberAccount.Provider_Type__pc = 'Physician';
        providerAccList.add(prescriberAccount);
        insert providerAccList;
        
        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        for (Contact con : [SELECT Id, AccountId FROM Contact WHERE AccountId IN :providerAccList]) {
            contactMap.put(con.AccountId, con);
        }
        Id prescriberContactId = contactMap.get(prescriberAccount.Id).Id;
        Id pharmacistContactId = contactMap.get(pharmacistAccount.Id).Id;
        
        Map<String, Profile> profileNameVsRec = new Map<String, Profile>();
        for(Profile profileObj: [SELECT Id, Name FROM Profile WHERE Name IN ('EDRD Prescriber Community User', 'BC HLTH Pharmacist Community User')]){
            profileNameVsRec.put(profileObj.Name, profileObj);
        }
        
        AccountContactRelation ACRObj = new AccountContactRelation();
        ACRObj.AccountId = prescriberAccount.Id;
        ACRObj.ContactId = pharmacistContactId;
        ACRObj.Roles = 'Allied Staff';
        insert ACRObj;
        
        List<User> communityUserToInsert = new List<User>();
        User providercommunityUser = TestFactory.createCommunityUser(prescriberContactId, profileNameVsRec.get('EDRD Prescriber Community User').Id, 'Test1', 'Provider');
        communityUserToInsert.add(providercommunityUser);
        User pharmacistCommunityUser = TestFactory.createCommunityUser(pharmacistContactId, profileNameVsRec.get('BC HLTH Pharmacist Community User').Id, 'Test1', 'Pharmacist');
        communityUserToInsert.add(pharmacistCommunityUser);
        
        Test.startTest();
        insert communityUserToInsert;
        Test.stopTest();
        
        Account updatedPrescriberAcc = [SELECT Id, EDRD_Provider_Public_GroupId__pc FROM Account WHERE Id =: prescriberAccount.Id];
        Assert.areNotEqual(null, updatedPrescriberAcc.EDRD_Provider_Public_GroupId__pc, 'Public Group ID should be set on Provider person Account');
        
        Group publicGroupRec = [SELECT Id, Name FROM Group WHERE Id =: updatedPrescriberAcc.EDRD_Provider_Public_GroupId__pc];
        Assert.areEqual(updatedPrescriberAcc.EDRD_Provider_Public_GroupId__pc, publicGroupRec.Id, 'Public Group Id should present');
        Assert.areNotEqual(null, updatedPrescriberAcc.EDRD_Provider_Public_GroupId__pc, 'Public Group ID should not be Null');
        
        List<GroupMember> gmList = [SELECT Id, GroupId, UserOrGroupId FROM GroupMember WHERE GroupId =: publicGroupRec.Id];
        Set<Id> userIdsInGroup = new Set<Id>();
        for (GroupMember gm : gmList) {
            userIdsInGroup.add(gm.UserOrGroupId);
        }
        Assert.areEqual(true, userIdsInGroup.contains(providercommunityUser.Id), 'Provider should be part of Provider Public Group');
        Assert.areEqual(true, userIdsInGroup.contains(pharmacistCommunityUser.Id), 'Allied Staff User should be part of Provider Public Group');
    }
}