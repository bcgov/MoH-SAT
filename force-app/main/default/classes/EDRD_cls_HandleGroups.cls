/**********************************************************************************************
* @Author:      Accenture 
* @Date:        09 Mar 2023
* @Description: The purpose of this class is to  Adding/Removing - Provider/Reviewer to public groups in without sharing context.
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description] 
                20 Dec -  EDRD-1150         -  Accenture   -  Adding/Removing - Provider/Reviewer to public groups based on Committees
                03 Apr -  EDRD-1450         -  Accenture   -  Adding/Removing - Provider/Reviewer to EDRD Reviewer public groups & Permission set
***********************************************************************************************/
public without Sharing class EDRD_cls_HandleGroups {
    
/**
* @author: Deepak
* @date: 20 Dec 2024
* @description: The purpose of this method is to Adding/Removing - Provider/Reviewer to public groups based on EDRD Committees in future transcation.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]                    
*/    
    @future
    public Static void handleGroupMembership(List<String> perConIdVsOldCommitteeNameSTRList, List<String> perConIdVsNewCommitteeNameSTRList, Map<Id, String> PerConIdVsTransType){
        Map<Id, Set<String>> perConIdVsOldCommittesName = new Map<Id, Set<String>>();
        Map<Id, Set<String>> perConIdVsnewCommitteeName = new Map<Id, Set<String>>();
        Map<String, String> committeeToGroupMap = new Map<String, String>();
        Map<Id, Set<String>> perConIdVsOldGroupName = new Map<Id, Set<String>>();
        Map<Id, Set<String>> perConIdVsnewGroupName = new Map<Id, Set<String>>();
        Map<String, Id> groupNameVsGroupId = new Map<String, Id>();
        List<GroupMember> groupMemberToDelete = new List<GroupMember>();
        List<GroupMember> groupMemberToInsert = new List<GroupMember>();
        
        for(String wrapperOldSTR : perConIdVsOldCommitteeNameSTRList){
            ESA_cls_accountTriggerHandler.groupMemberWrapper gMWObj = ESA_cls_accountTriggerHandler.parse(wrapperOldSTR);
            if(!perConIdVsOldCommittesName.ContainsKey(gMWObj.personContactId)){
                perConIdVsOldCommittesName.put(gMWObj.personContactId, new set<String>());
            }    
            for(ESA_cls_accountTriggerHandler.cls_committiees committeeObj: gMWObj.committiees){
                perConIdVsOldCommittesName.get(gMWObj.personContactId).add(committeeObj.committeeName);
            }
        }
        
        for(String wrapperNewSTR : perConIdVsNewCommitteeNameSTRList){
            ESA_cls_accountTriggerHandler.groupMemberWrapper gMWObj = ESA_cls_accountTriggerHandler.parse(wrapperNewSTR);
            if(!perConIdVsnewCommitteeName.ContainsKey(gMWObj.personContactId)){
                perConIdVsnewCommitteeName.put(gMWObj.personContactId, new set<String>());
            }    
            for(ESA_cls_accountTriggerHandler.cls_committiees committeeObj: gMWObj.committiees){
                perConIdVsnewCommitteeName.get(gMWObj.personContactId).add(committeeObj.committeeName);
            }
        }
        
        Set<String> publicGroupName = new Set<String>();
        for (EDRD_Public_Grp_vs_Committee__mdt metadataRecord : [SELECT Committee_Name__c, EDRD_Public_Group_Name__c FROM EDRD_Public_Grp_vs_Committee__mdt]) {
            committeeToGroupMap.put(metadataRecord.Committee_Name__c, metadataRecord.EDRD_Public_Group_Name__c);
            publicGroupName.add(metadataRecord.EDRD_Public_Group_Name__c);            
        }
        List<Group> groupList = [SELECT Id, Name, DeveloperName FROM Group WHERE DeveloperName IN: publicGroupName];
        
        for(Id perContactId :perConIdVsOldCommittesName.KeySet()){            
            for(String committeeName: perConIdVsOldCommittesName.get(perContactId)){
                if(!perConIdVsOldGroupName.containsKey(perContactId)){
                    perConIdVsOldGroupName.put(perContactId, new Set<String>());
                }
                perConIdVsOldGroupName.get(perContactId).add(committeeToGroupMap.get(committeeName));
            }         
        }
        
        List<User> userListToDelete = [SELECT Id, ContactId FROM User WHERE ContactId IN: perConIdVsOldGroupName.keySet()];
        
        for(Group  grpObj: groupList){
            groupNameVsGroupId.put(grpObj.DeveloperName, grpObj.Id);
        }
        Map<Id, Id> groupIdVsUserGroupId = new Map<Id, Id>();
        for(User userObj: userListToDelete){
            for(String groupName: perConIdVsOldGroupName.get(userObj.ContactId)){
                groupIdVsUserGroupId.put(groupNameVsGroupId.get(groupName), userObj.Id);
            }
        }        
        
        if (!groupIdVsUserGroupId.isEmpty()) {
            groupMemberToDelete = [Select Id FROM GroupMember Where GroupId IN: groupIdVsUserGroupId.keySet() AND UserOrGroupId IN: groupIdVsUserGroupId.values()]; 
            if (!groupMemberToDelete.isEmpty()) {
                delete groupMemberToDelete;            
            }
        }
        
        for(Id perContactId :perConIdVsnewCommitteeName.KeySet()){            
            for(String committeeName: perConIdVsnewCommitteeName.get(perContactId)){
                if(!perConIdVsNewGroupName.containsKey(perContactId)){
                    perConIdVsNewGroupName.put(perContactId, new Set<String>());
                }
                perConIdVsNewGroupName.get(perContactId).add(committeeToGroupMap.get(committeeName));
            }
        }
        
        List<User> userList = [SELECT Id, ContactId FROM User WHERE ContactId IN: perConIdVsNewGroupName.keySet()];
        
        for(Group  grpObj: groupList){
            groupNameVsGroupId.put(grpObj.DeveloperName, grpObj.Id);
        }
        
        for(User userObj: userList){
            for(String groupName: perConIdVsNewGroupName.get(userObj.ContactId)){
                if(groupNameVsGroupId.get(groupName) != NULL){
                    groupMemberToInsert.add(new GroupMember(groupId = groupNameVsGroupId.get(groupName), UserOrGroupId = userObj.Id));
                }
            }
        }
        
        if (!groupMemberToInsert.isEmpty()) {            
            insert groupMemberToInsert;
        }
        
        if(!PerConIdVsTransType.IsEmpty()){
            handlePSNPGAssignment(PerConIdVsTransType);
        }
    } 

/**
* @author: Deepak
* @date: 03 April 2024
* @description: The purpose of this method is to Adding/Removing - Provider/Reviewer to EDRD Reviewer public groups & Permission set.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]                    
*/     
    public static void handlePSNPGAssignment(Map<Id, String> PerConIdVsTransType){
        Set<Id> userIdsToAdd = new Set<Id>();
        Set<Id> userIdsToRemove = new Set<Id>();
        List<GroupMember> groupMemberList = new List<GroupMember>();
        List<GroupMember> groupMemberListToDelete = new List<GroupMember>();
        Set<Id> userPartOfEDRDReviewerPG = new Set<Id>();
        List<Group> eDRDReviewerPG = [SELECT Id FROM Group WHERE DeveloperName = 'EDRD_Reviewer'];
        List<GroupMember> memberToInsert = new List<GroupMember>();
        List<GroupMember> memberToDelete = new List<GroupMember>();
        List<permissionSetAssignment> premissionsetAssignList = new List<PermissionSetAssignment>();
        Set<Id> userPartOfEDRDReviewerPSA = new Set<Id>();
        List<PermissionSetAssignment> permSetAssignmentsToInsert = new List<PermissionSetAssignment>();
        List<PermissionSetAssignment> permSetAssignmentsToDelete = new List<PermissionSetAssignment>();
        
        List<PermissionSet> eDRDReviewerPermSet = [SELECT Id FROM PermissionSet WHERE Name = 'EDRD_PS_Reviewer' LIMIT 1];
        
        List<User> userList = [SELECT Id, ContactId FROM User WHERE ContactId IN: PerConIdVsTransType.keySet()];
        
        for(User userObj: userList){
            if(PerConIdVsTransType.containsKey(userObj.ContactId) && PerConIdVsTransType.get(userObj.ContactId) == 'ADD'){
                userIdsToAdd.add(userObj.Id);
            }else if(PerConIdVsTransType.containsKey(userObj.ContactId) && PerConIdVsTransType.get(userObj.ContactId) == 'REMOVE'){
                userIdsToRemove.add(userObj.Id);
            }
        }
        
        if(!userIdsToAdd.isEmpty()){
            groupMemberList = [SELECT Id, UserOrGroupId FROM GroupMember WHERE Group.DeveloperName = 'EDRD_Reviewer' AND UserOrGroupId IN: userIdsToAdd];
            premissionsetAssignList = [SELECT Id, AssigneeId FROM PermissionSetAssignment WHERE AssigneeId IN: userIdsToAdd AND PermissionSet.Name = 'EDRD_PS_Reviewer'];
        }
        
        for(GroupMember gMObj: groupMemberList){
            userPartOfEDRDReviewerPG.add(gMObj.UserOrGroupId);
        }
        
        for(PermissionSetAssignment pSAObj: premissionsetAssignList){
            userPartOfEDRDReviewerPSA.add(pSAObj.AssigneeId);
        }
        
        for(Id userId: userIdsToAdd){
            if(!userPartOfEDRDReviewerPG.Contains(userId)){
                memberToInsert.add(new GroupMember(UserOrGroupId = userId, GroupId = eDRDReviewerPG.get(0).Id));
            }
            if(!userPartOfEDRDReviewerPSA.Contains(userId)){
                permSetAssignmentsToInsert.add(new PermissionSetAssignment(AssigneeId = userId, PermissionSetId = eDRDReviewerPermSet.get(0).Id));
            }
        }
        
        if(!memberToInsert.IsEmpty()){
            Database.Insert(memberToInsert, true);
        }
        
        if(!permSetAssignmentsToInsert.isEmpty()){
            Database.insert(permSetAssignmentsToInsert, false);
        }
        
        if(!memberToDelete.IsEmpty()){
            groupMemberListToDelete = [SELECT Id, UserOrGroupId FROM GroupMember WHERE Group.DeveloperName = 'EDRD_Reviewer' AND UserOrGroupId IN: userIdsToRemove];
        }
        
        if(!groupMemberListToDelete.IsEmpty()){
            Database.Delete(groupMemberListToDelete, true);
        }
        
        if(!userIdsToRemove.isEmpty()){
            permSetAssignmentsToDelete = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSetId =: edrdReviewerPermSet.get(0).Id AND AssigneeId IN :userIdsToRemove];
        }
        
        if(!permSetAssignmentsToDelete.isEmpty()){
            Database.delete(permSetAssignmentsToDelete, false);
        }
    } 
}