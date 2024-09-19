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
        if (!accShareListToInsert.isEmpty()) {
            try {
                Database.insert(accShareListToInsert, true);
            } catch (DmlException e) {
                System.debug('Error inserting AccountShare records: ' + e.getMessage());
            }
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
        if (!accShareList.isEmpty()) {
            try {
                Database.delete(accShareList, true);
            } catch (DmlException e) {
                System.debug('Error deleting AccountShare records: ' + e.getMessage());
            }
        }
    }
}