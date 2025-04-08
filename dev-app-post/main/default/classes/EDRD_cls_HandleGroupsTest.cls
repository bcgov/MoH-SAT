/**********************************************************************************************
* @Author:      Accenture 
* @Date:        20/12/2024
* @Description: The purpose of this class is to cover Code coverage of EDRD_cls_HandleGroups
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description] 
                20 Dec -  EDRD-1150         -  Accenture   -  The purpose of this method is to Remove Committee based on ACR delete of EDRD_Committee & Provider OR Committee_Reviewer.
                03 Apr -  EDRD-1450         -  Accenture   -  Adding/Removing - Provider/Reviewer to EDRD Reviewer public groups & Permission set.
***********************************************************************************************/
@isTest
public class EDRD_cls_HandleGroupsTest {

/**
* @author: Deepak
* @date: 23 Dec 2024
* @description: The purpose of this method is to cover Testcoverage of handleGroupMembership
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/    
    @isTest
    public static void handleGroupMembershipTest(){
        Account providerAcc = TestFactory.newProvider('Provider Test');
        providerAcc.Committee__pc = ESA_cls_constants.EDRD_PERSONACCOUNT_SC;
        providerAcc.Committee_Name__pc = ESA_cls_constants.EDRD_PERSONACCOUNT_SC_METABOLIC_SUBCOMMITTEE;
        providerAcc.Provider_Identifier__pc = '1112223';
        providerAcc.Provider_Type__pc = ESA_cls_constants.EDRD_PHYSICIAN;
        insert providerAcc;
        
        UserTriggerHandler.isAssignPSG = false;
        
        Id ContactId = [SELECT Id FROM Contact WHERE AccountID =: providerAcc.Id].get(0).Id;
        Profile profileRec = [SELECT Id FROM Profile WHERE Name = 'EDRD Prescriber Community User'];
        User communityUser = TestFactory.createCommunityUser(ContactId, profileRec.Id, 'Test1', 'Test');
        insert communityUser;
        
        providerAcc.Committee__pc = ESA_cls_constants.EDRD_PERSONACCOUNT_ACSC;
        
        Test.startTest();
        update providerAcc;
        Test.stopTest();
        
        List<GroupMember> groupMembers = [SELECT Id, GroupId FROM GroupMember WHERE UserOrGroupId = :communityUser.Id];
        
        Assert.areEqual(TRUE, groupMembers.size() > 0, 'At least one GroupMember should exist for the user');
        Assert.areEqual(2, groupMembers.size(), 'Exactly two GroupMember should exist for the user');
        Assert.areNotEqual(null, groupMembers[0].GroupId, 'GroupMember should have a valid GroupId');     
    }
    
/**
* @author: Deepak
* @date: 03 Apr 2025
* @description: The purpose of this method is to cover Testcoverage of handlePSNPGAssignment
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/    
    @isTest
    public static void handlePSNPGAssignmentTest(){
        List<Account> providerList = new List<Account>();
        Account providerAcc = TestFactory.newProvider('Provider Test');
        providerAcc.Provider_Identifier__pc = '1112223';
        providerAcc.Provider_Type__pc = ESA_cls_constants.EDRD_PHYSICIAN;
        providerList.add(providerAcc);
        Account providerAcc1 = TestFactory.newProvider('Provider Test');
        providerAcc1.Committee__pc = ESA_cls_constants.EDRD_PERSONACCOUNT_SC;
        providerAcc1.Committee_Name__pc = ESA_cls_constants.EDRD_PERSONACCOUNT_SC_METABOLIC_SUBCOMMITTEE;
        providerAcc1.Provider_Identifier__pc = '7772223';
        providerAcc1.Provider_Type__pc = ESA_cls_constants.EDRD_PHYSICIAN;
        providerList.add(providerAcc1);
        insert providerList;
        
        UserTriggerHandler.isAssignPSG = false;
        
        Id ContactId = [SELECT Id FROM Contact WHERE AccountID =: providerAcc.Id].get(0).Id;
        Id Contact1Id = [SELECT Id FROM Contact WHERE AccountID =: providerAcc1.Id].get(0).Id;
        
        Profile profileRec = [SELECT Id FROM Profile WHERE Name = 'EDRD Prescriber Community User'];
        
        List<User> userList = new List<User>();
        User communityUser = TestFactory.createCommunityUser(ContactId, profileRec.Id, 'Test1', 'Test');
        userList.add(communityUser);
        User communityUser1 = TestFactory.createCommunityUser(Contact1Id, profileRec.Id, 'Test11', 'Test');
        userList.add(communityUser1);
        insert userList;
        
        providerList = new List<Account>();
        providerAcc.Committee__pc = ESA_cls_constants.EDRD_PERSONACCOUNT_SC;
        providerAcc.Committee_Name__pc = ESA_cls_constants.EDRD_PERSONACCOUNT_SC_METABOLIC_SUBCOMMITTEE;
        providerList.add(providerAcc);
        providerAcc1.Committee__pc = NULL;
        providerAcc1.Committee_Name__pc = NULL;
        providerList.add(providerAcc1);
        
        Test.startTest();
        update providerList;
        Test.stopTest();
        
        List<GroupMember> groupMembers = [SELECT Id, GroupId, UserOrGroupId FROM GroupMember WHERE UserOrGroupId IN :new List<Id>{communityUser.Id, communityUser1.Id}];
        List<PermissionSetAssignment> pSAList = [SELECT Id, AssigneeId, Assignee.Name, PermissionSetId, PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId IN :new List<Id>{communityUser.Id, communityUser1.Id}];
        
        Map<Id, List<GroupMember>> groupMembersMap = new Map<Id, List<GroupMember>>();
        Map<Id, List<PermissionSetAssignment>> pSAListMap = new Map<Id, List<PermissionSetAssignment>>();
        
        for (GroupMember gm : groupMembers) {
            if (!groupMembersMap.containsKey(gm.UserOrGroupId)) {
                groupMembersMap.put(gm.UserOrGroupId, new List<GroupMember>());
            }
            groupMembersMap.get(gm.UserOrGroupId).add(gm);
        }
        
        for (PermissionSetAssignment psa : pSAList) {
            if (!pSAListMap.containsKey(psa.AssigneeId)) {
                pSAListMap.put(psa.AssigneeId, new List<PermissionSetAssignment>());
            }
            pSAListMap.get(psa.AssigneeId).add(psa);
        }
        
        Assert.areEqual(TRUE, groupMembersMap.containsKey(communityUser.Id) && groupMembersMap.get(communityUser.Id).size() > 0, 'At least one GroupMember should exist for communityUser');
        Assert.areEqual(TRUE, pSAListMap.containsKey(communityUser.Id) && pSAListMap.get(communityUser.Id).size() > 0, 'At least one PermissionSetAssignment should exist for communityUser');
        Assert.areNotEqual(null, groupMembersMap.get(communityUser.Id)[0].GroupId, 'GroupMember should have a valid GroupId');
        Assert.areNotEqual(null, pSAListMap.get(communityUser.Id)[0].PermissionSetId, 'PermissionSetAssignment should have a valid PermissionSetId');
        Assert.areEqual(FALSE, groupMembersMap.containsKey(communityUser1.Id) && groupMembersMap.get(communityUser1.Id).size() > 0, 'No GroupMember should exist for communityUser1');
        Assert.areEqual(FALSE, pSAListMap.containsKey(communityUser1.Id) && pSAListMap.get(communityUser1.Id).size() > 1, 'No PermissionSetAssignment should exist for communityUser1 except Profile');
    }
}