/**********************************************************************************************
* @Author:      Accenture 
* @Date:        24 Sept 2024
* @Description: The purpose of this helper class is to update ACR records on User trigger event
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]
***********************************************************************************************/
public with sharing class UserTriggerHelper{  
    
/**
* @author: Deepak
* @date: 24 Sept 2024
* @description: Update AccountContactRelation records in future method.
* @param Set<Id> acrIdsToUpdate: Set of ACR records to update.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/ 
    @future
    public static void updateACRRecords(Set<Id> acrIdsToUpdate){
        try {
            List<AccountContactRelation> aCRListToUpdate = [SELECT Id, IsActive, Is_EDRD_Data_Migration__c 
                                                            FROM AccountContactRelation 
                                                            WHERE Id IN :acrIdsToUpdate];

            for(AccountContactRelation aCRObj : aCRListToUpdate){
                aCRObj.IsActive = true;
                aCRObj.Is_EDRD_Data_Migration__c = false;
            }

            if(!aCRListToUpdate.isEmpty()){
                Database.update(aCRListToUpdate, true);
            }
        } catch(Exception ex){
            System.debug('Error while updating ACR records: ' + ex.getMessage());
        }
    }
}