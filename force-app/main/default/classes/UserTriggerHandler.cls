/**********************************************************************************************
* @Author:      Accenture 
* @Date:        24 Sept 2024
* @Description: The purpose of this class is to create methods which can be used by different trigger event
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
                24Sept -  EDRD-911          -  Accenture   -  Added activateACROnEDRDPortalEnable method
                07Jan -   EDRD-1150         -  Accenture   -  Added handleEDRDPublicGroupMember method
                07Jan -   EDRD-1150         -  Accenture   -  Added handleGroupsForUsersAsync method
                03 Apr -  EDRD-1450         -  Accenture   -  Adding/Removing - Provider/Reviewer to EDRD Reviewer public groups & Permission set
***********************************************************************************************/
public with sharing class UserTriggerHandler {
    public static Id eDRDPrescriberProfileId = [SELECT Id FROM Profile WHERE Name =: ESA_cls_constants.EDRD_PRESCRIBER_COMMUNITY_USER LIMIT 1].Id;
    public static Id recordTypeProvider = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ESA_cls_constants.EDRD_PROVIDER).getRecordTypeId();
    public static Id recordTypeEDRDReviewer = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ESA_cls_constants.EDRD_COMMITTEE_REVIEWER).getRecordTypeId();
    public static Boolean isAssignPSG = true;
    
/**
* @author: Deepak
* @date: 24 Sept 2024
* @description: The purpose of this method is to activate EDRD related ACR on provider releated to user.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/ 
    public static void activateACROnEDRDPortalEnable(List<User> newUserList){
        try{
            Set<Id> providerIdSet = new Set<Id>();
            Set<Id> accProviderIdSet = new Set<Id>();
            Set<Id> acrIdsToUpdate = new Set<Id>();
            Map<Id, Contact> contactIdVsContactRec;

            for(User userObj: newUserList){
                if((userObj.ProfileId == eDRDPrescriberProfileId && userObj.IsPortalEnabled)){
                    providerIdSet.add(userObj.ContactId);
                }
            }

            if(!providerIdSet.isEmpty()){ 
                contactIdVsContactRec = new Map<Id, Contact>([SELECT Id, AccountId FROM Contact 
                                                              WHERE ID IN: providerIdSet AND 
                                                              Account.RecordTypeId =: recordTypeProvider]);
                for(Contact conObj: contactIdVsContactRec.values()){
                    accProviderIdSet.add(conObj.accountId);
                }
            }

            if(!accProviderIdSet.isEmpty()){
                List<AccountContactRelation> aCRList = [SELECT Id, AccountId, ContactId, Roles, Is_EDRD_Data_Migration__c, IsActive 
                                                        FROM AccountContactRelation 
                                                        WHERE AccountID IN: accProviderIdSet AND IsActive = false
                                                        AND Is_EDRD_Data_Migration__c = true];

                for(AccountContactRelation aCRObj : aCRList){
                    if(!String.isEmpty(aCRObj.Roles) && aCRObj.Roles.containsIgnoreCase(ESA_cls_constants.EDRD_PHYSICIAN)){
                        acrIdsToUpdate.add(aCRObj.Id);
                    }
                }

                if (!acrIdsToUpdate.isEmpty()) {
                    // Calling the future method to update ACR records in a separate transaction
                    UserTriggerHelper.updateACRRecords(acrIdsToUpdate);
                }
            } 
        }
        catch(Exception ex){
            System.debug('An unexpected error occurred: ' + ex.getMessage());
        }
    }
    
/**
* @author: Deepak
* @date: 07 Jan 2025
* @description: The purpose of this method is to activate EDRD related ACR on provider releated to user.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/ 
    public static void handleEDRDPublicGroupMember(List<User> newUserList) {
        Set<Id> userIdSet = new Set<Id>();
        
        for (User userObj : newUserList) {
            if ((userObj.ProfileId == eDRDPrescriberProfileId && userObj.IsPortalEnabled && userObj.IsActive)) {
                userIdSet.add(userObj.Id);
            }
        }
        
        if (!userIdSet.isEmpty()) {
            handleGroupsForUsersAsync(userIdSet);
        }
    }

/**
* @author: Deepak
* @date: 07 Jan 2025
* @description: The purpose of this method is to async and insert the public groupmember records.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
                     03 Apr -  EDRD-1450         -  Accenture   -  Added assignUserToReviewerGroupAndPermissionSet Method.
*/    
    @future
    public static void handleGroupsForUsersAsync(Set<Id> userIds){
        Map<String, String> committeeToGroupMap = new Map<String, String>();
        Map<String, Id> groupNameVsGroupId = new Map<String, Id>();
        Map<Id, List<String>> userIdVsGroupsToBeAdded = new Map<Id, List<String>>();
        List<GroupMember> groupMemberToInsert = new List<GroupMember>();
        List<User> relevantUsers = new List<User>();
        
        relevantUsers = [SELECT Id, ContactId, Contact.AccountId, Contact.Account.Committee__pc, Contact.Account.Committee_Name__pc
                         FROM User WHERE Id IN :userIds
                         AND (Contact.Account.Committee__pc != NULL OR Contact.Account.Committee_Name__pc != NULL)
                         AND (Account.RecordTypeId = :recordTypeProvider OR Account.RecordTypeId = :recordTypeEDRDReviewer)];
        
        if(!relevantUsers.isEmpty() && isAssignPSG){
            assignUserToReviewerGroupAndPermissionSet(relevantUsers);
        }
                
        for (User userObj : relevantUsers) {
            if (userObj.Contact.Account.Committee_Name__pc != NULL) {
                userIdVsGroupsToBeAdded.put(userObj.Id, userObj.Contact.Account.Committee_Name__pc.split(';'));
            }
            if (userObj.Contact.Account.Committee__pc != NULL && userObj.Contact.Account.Committee_Name__pc == NULL) {
                userIdVsGroupsToBeAdded.put(userObj.Id, new List<String>{userObj.Contact.Account.Committee__pc});
            }
        }
        
        if (!userIdVsGroupsToBeAdded.isEmpty()) {
            Set<String> publicGroupName = new Set<String>();
            
            for (EDRD_Public_Grp_vs_Committee__mdt metadataRecord : [SELECT Committee_Name__c, EDRD_Public_Group_Name__c
                                                                     FROM EDRD_Public_Grp_vs_Committee__mdt]) {
                                                                         committeeToGroupMap.put(metadataRecord.Committee_Name__c, metadataRecord.EDRD_Public_Group_Name__c);
                                                                         publicGroupName.add(metadataRecord.EDRD_Public_Group_Name__c);
                                                                     }
            List<Group> groupList = [SELECT Id, Name, DeveloperName FROM Group WHERE DeveloperName IN :publicGroupName];
            
            for (Group grpObj : groupList) {
                groupNameVsGroupId.put(grpObj.DeveloperName, grpObj.Id);
            }
            
            for (Id userId : userIdVsGroupsToBeAdded.keySet()) {
                for (String committeeName : userIdVsGroupsToBeAdded.get(userId)) {
                    groupMemberToInsert.add(new GroupMember(UserOrGroupId = userId,
                                                            GroupId = groupNameVsGroupId.get(committeeToGroupMap.get(committeeName))));
                }
            }
        }
        
        if (!groupMemberToInsert.isEmpty()) {
            Database.insert(groupMemberToInsert, true);
        }
    }
    
/**
* @author: Deepak
* @date: 03 April 2024
* @description: The purpose of this method is to Adding/Removing - Provider/Reviewer to EDRD Reviewer public groups & Permission set.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]                    
*/ 
    public static void assignUserToReviewerGroupAndPermissionSet(List<User> relevantUsers) {
        List<GroupMember> groupMemberToInsert = new List<GroupMember>();
        List<PermissionSetAssignment> permSetAssignToInsert = new List<PermissionSetAssignment>();
        List<Group> eDRDReviewerPG = [SELECT Id FROM Group WHERE DeveloperName = 'EDRD_Reviewer' LIMIT 1];
        List<PermissionSet> eDRDReviewerPermSet = [SELECT Id FROM PermissionSet WHERE Name = 'EDRD_PS_Reviewer' LIMIT 1];
        
        if (!eDRDReviewerPG.isEmpty() && !eDRDReviewerPermSet.isEmpty()) {
            Id groupId = eDRDReviewerPG[0].Id;
            Id permSetId = eDRDReviewerPermSet[0].Id;
            
            for (User user : relevantUsers) {
                groupMemberToInsert.add(new GroupMember(UserOrGroupId = user.Id, GroupId = groupId));
                
                permSetAssignToInsert.add(new PermissionSetAssignment(AssigneeId = user.Id, PermissionSetId = permSetId));
            }
            
            if (!groupMemberToInsert.isEmpty()) {
                Database.insert(groupMemberToInsert, true);
            }
            
            if (!permSetAssignToInsert.isEmpty()) {
                Database.insert(permSetAssignToInsert, true);
            }
        }
    }
}