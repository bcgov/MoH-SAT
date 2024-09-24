/**********************************************************************************************
* @Author:      Accenture 
* @Date:        24 Sept 2024
* @Description: The purpose of this class is to create methods which can be used by different trigger event
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
                24Sept -  EDRD-911          -  Accenture   -  Added activateACROnEDRDPortalEnable method
***********************************************************************************************/
public with sharing class UserTriggerHandler {
    public static Id eDRDPrescriberProfileId = [SELECT Id FROM Profile WHERE Name =: ESA_cls_constants.EDRD_PRESCRIBER_COMMUNITY_USER LIMIT 1].Id;
    public static Id recordTypeProvider = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ESA_cls_constants.EDRD_PROVIDER).getRecordTypeId();
    
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
}