/**********************************************************************************************
* @Author:      Accenture 
* @Date:        24 Sept 2024
* @Description: The purpose of this helper class is to update ACR records on User trigger event
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]
                02 Jul -  EDRD-1522		    -  Accenture   -  Method for Records to update post EDRD Provider User Provisioning in future method..
                24 Sep -  EDRD-911 		    -  Accenture   -  Method is to Update AccountContactRelation records in method.
                02 Jul -  EDRD-1522		    -  Accenture   -  Method is to Update OwnerId of Medication Request & Assessment records in method.
***********************************************************************************************/
public with sharing class UserTriggerHelper{  

/**
* @author: Deepak
* @date: 02 Jul 2025
* @description: Records to update, post EDRD Provider User Provisioning in future method.
* @param Set<Id> acrIdsToUpdate: Set of ACR records to update.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/ 
    @future
    public static void postEDRDProviderUserProvisioning(Set<Id> providerAccountIdSet){
        Set<Id> acrIdsToUpdate = new Set<Id>();
        Map<Id, Id> caseIdVsProviderId = new Map<Id, Id>();
        
        List<AccountContactRelation> aCRList = [SELECT Id, AccountId, ContactId, Roles, Is_EDRD_Data_Migration__c, IsActive 
                                                FROM AccountContactRelation 
                                                WHERE AccountID IN: providerAccountIdSet AND IsActive = false
                                                AND Is_EDRD_Data_Migration__c = true];
        
        for(AccountContactRelation aCRObj : aCRList){
            if(!String.isEmpty(aCRObj.Roles) && aCRObj.Roles.containsIgnoreCase(ESA_cls_constants.EDRD_PHYSICIAN)){
                acrIdsToUpdate.add(aCRObj.Id);
            }
        }
        
        List<Case> eDRDCaseList = [SELECT Id, Provider_Account__c, Provider__c, RecordTypeId FROM Case 
                                   WHERE Provider_Account__c IN: providerAccountIdSet AND RecordTypeId =: ESA_cls_caseTriggerHandler.recordTypeCaseEDRD];
        
        for(Case caseObj: eDRDCaseList){
            caseIdVsProviderId.put(caseObj.Id, caseObj.Provider__c);
        }
        
        if (!acrIdsToUpdate.isEmpty()) {
            UserTriggerHelper.updateACRRecords(acrIdsToUpdate);
        }
        
        if (!eDRDCaseList.isEmpty()) {
            ESA_cls_caseTriggerHandler.handleCaseTeamOnEDRD(eDRDCaseList);
        } 
        
        if (!caseIdVsProviderId.isEmpty()) {
            updateMedReqNAssessmentOwnerId(caseIdVsProviderId);
        } 
    }
    
/**
* @author: Deepak
* @date: 24 Sept 2024
* @description: Update AccountContactRelation records in method.
* @param Set<Id> acrIdsToUpdate: Set of ACR records to update.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/ 
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
    
/**
* @author: Deepak
* @date: 02 Jul 2025
* @description: Update OwnerId of Medication Request & Assessment records in method.
* @param Map<Id, Id> caseIdVsProviderId: Map of caseId & ProviderId to update.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/ 
    public static void updateMedReqNAssessmentOwnerId(Map<Id, Id> caseIdVsProviderId){
        Map<Id, Id> providerIdVsProvisionedUserId = new Map<Id, Id>();
        List<MedicationRequest> MedReqListToUpdate = new List<MedicationRequest>();
        List<Assessment> assessmentListToUpdate = new List<Assessment>();
        
        List<User> userList = [SELECT Id, ContactId From User WHERE ContactId IN: caseIdVsProviderId.values()];
        for(User userObj: userList){
            providerIdVsProvisionedUserId.put(userObj.ContactId, userObj.Id);
        }
        
        List<Case> casesWithRelatedMRNAssessments = [SELECT Id, Provider__c, (SELECT Id, Case__r.Type, Case__r.Status, Case__r.Priority, Case__r.EDRD_Ref_No__c, Case__r.Provider__r.AccountId, Case__r.OwnerId, Case__c, Case__r.Provider__c 
                                                                   FROM Medication_Requests__r WHERE Case__c IN: caseIdVsProviderId.keySet()),
                                          (SELECT Id, OwnerId FROM Assessments WHERE CaseId IN: caseIdVsProviderId.KeySet()) FROM Case WHERE Id IN: caseIdVsProviderId.keySet()];
        
        for(Case caseObj: casesWithRelatedMRNAssessments){
            for(MedicationRequest MRObj: caseObj.Medication_Requests__r){
                if(caseIdVsProviderId.containsKey(MRObj.Case__c) && providerIdVsProvisionedUserId.ContainsKey(MRObj.Case__r.Provider__c)){
                    MRObj.OwnerId = providerIdVsProvisionedUserId.get(MRObj.Case__r.Provider__c);
                }
                MedReqListToUpdate.add(MRObj);
            }
            
            for(Assessment assessmentObj: caseObj.Assessments){
                assessmentListToUpdate.add(new Assessment(Id = assessmentObj.id, OwnerId = providerIdVsProvisionedUserId.get(caseObj.Provider__c)));
            }
        }
        
        if(!MedReqListToUpdate.isEmpty()){
            Update MedReqListToUpdate;
        }
        
        if(!assessmentListToUpdate.isEmpty()){
            Update assessmentListToUpdate;
        }
    }
}