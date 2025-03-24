/**********************************************************************************************
* @Author:      Accenture 
* @Date:        20/12/2024
* @Description: The purpose of this class is to cover Code coverage of EDRD_cls_HandleGroups
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description] 
                20 Dec -  EDRD-1150         -  Accenture   -  The purpose of this method is to Remove Committee based on ACR delete of EDRD_Committee & Provider OR Committee_Reviewer.
***********************************************************************************************/
@isTest
public class EDRD_cls_HandleGroupsTest {

/**
* @author: 
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
}