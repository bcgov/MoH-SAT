/**********************************************************************************************
* @Author:      Accenture 
* @Date:        12 Sept 2024
* @Description: The purpose of this helper class is to insert/delete share record on different ACR trigger event
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]
***********************************************************************************************/
public without sharing class AccountContactShareHelper {
    
/**
* @author: Deepak
* @date: 12 Sept 2024
* @description: Insert AccountShare records in system context.
* @param List<AccountShare> accShareListToInsert: List of AccountShare records to insert.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/ 
    public static void insertAccountShares(List<AccountShare> accShareListToInsert) {
        try {
            if (!accShareListToInsert.isEmpty()) {
                Database.insert(accShareListToInsert, true);
            }
        } catch (DmlException e) {
            System.debug('Error inserting AccountShare records: ' + e.getMessage());
        }
    }
    
/**
* @author: Deepak
* @date: 12 Sept 2024
* @description: Delete AccountShare records in system context.
* @param List<AccountShare> accShareList: List of AccountShare records to delete.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/ 
    public static void deleteAccountShares(List<AccountShare> accShareList) {
        try {
            if (!accShareList.isEmpty()) {
                Database.delete(accShareList, true);
            }
        } catch (DmlException e) {
            System.debug('Error deleting AccountShare records: ' + e.getMessage());
        }
    }

    
    public static void assignUserToGroup(Id userId) {
            // Query the public group 'Omni_Channel_Users'
        Group publicGroup = [SELECT Id FROM Group WHERE DeveloperName = 'Omni_Channel_Users' LIMIT 1];

        // Create the GroupMember record to add the user to the group
        GroupMember groupMember = new GroupMember(
            GroupId = publicGroup.Id,
            UserOrGroupId = userId
        );
        // Insert the group member record
        insert groupMember;
    }
}