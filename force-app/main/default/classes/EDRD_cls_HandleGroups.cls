/**********************************************************************************************
* @Author:      Accenture 
* @Date:        09 Mar 2023
* @Description: The purpose of this class is to  Adding/Removing - Provider/Reviewer to public groups in without sharing context.
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description] 
                20 Dec -  EDRD-1150         -  Accenture   -  Adding/Removing - Provider/Reviewer to public groups based on Committees 
***********************************************************************************************/
public without Sharing class EDRD_cls_HandleGroups {

/**
* @author: Deepak
* @date: 20 Dec 2024
* @description: The purpose of this method is to Adding/Removing - Provider/Reviewer to public groups based on EDRD Committees in future transcation.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]                    
*/    
    @future
    public Static void handleGroupMembership(List<String> perConIdVsOldCommitteeNameSTRList, List<String> perConIdVsNewCommitteeNameSTRList){
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
    } 
}