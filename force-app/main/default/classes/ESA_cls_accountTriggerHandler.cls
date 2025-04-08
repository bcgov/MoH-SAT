/**********************************************************************************************
* @Author:      Accenture 
* @Date:        09 Mar 2023
* @Description: The purpose of this class is to create methods which can be used by different trigger event
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
                11 Nov -  EDRD-82           -  Accenture   -  Added Close Case method on Account Inactive
                20 Dec -  EDRD-1150         -  Accenture   -  Adding/Removing - Provider/Reviewer to public groups based on Committees. 
***********************************************************************************************/
public with sharing class ESA_cls_accountTriggerHandler {
    public static Id recordTypeProvider = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ESA_cls_constants.EDRD_PROVIDER).getRecordTypeId();
    public static Id recordTypeEDRDReviewer = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ESA_cls_constants.EDRD_COMMITTEE_REVIEWER).getRecordTypeId();
    
/**
* @author: Deepak
* @date: 09 Mar 2023
* @description: The purpose of this method is to populate the specialty.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/ 
    public static void populateSpecialty(List<Account> allNewAccountList, Map<id,Account> allOldAccountMap, Map<id,Account> allNewAccountMap) {
        
        //Filtering the account records for record types belonging to SAT
        
        List<Account> newAccountList = new List<Account>();
        Map<id,Account> oldAccountMap = new Map<id,Account>();
        Map<id,Account> newAccountMap = new Map<id,Account>();
        List<String> saRecordTypeList = new List<String>{'Business_Account', 'DEC', 'Patient', 'Person', 'Provider'};

        for(Account acc : allNewAccountList){
            if(saRecordTypeList.contains(acc.Record_Type_Name__c)){
                newAccountList.add(acc);
                if(allOldAccountMap!= NULL && allOldAccountMap.size()>0){
                    oldAccountMap.put(acc.Id, allOldAccountMap.get(acc.Id));
                }
                if(allNewAccountMap!= NULL && allNewAccountMap.size()>0){
                    newAccountMap.put(acc.Id, allNewAccountMap.get(acc.Id));
                }      
            }
        }


        if(newAccountList != NULL && newAccountList.size()>0){
            Set<id> accountIdSet = new Set<id>();
            List<Contact> conListToUpdate = new List<Contact>();
            
            for (Account accObj:newAccountList){
                
                Boolean isSpecialtyChanged = trigger.isUpdate && oldAccountMap.get(accObj.id).Provider_Specialty__pc != newAccountMap.get(accObj.id).Provider_Specialty__pc;
                if (trigger.isInsert || isSpecialtyChanged){
                accountIdSet.add(accObj.id);
                } 
            } 
            List<Contact> conList = [Select Id, account.Provider_Specialty__pc, ESA_Provider_Specialty__c from Contact Where accountID =: accountIdSet];
            for(Contact conObj: conList){
                if(!String.isEmpty(conObj.account.Provider_Specialty__pc) && conObj.account.Provider_Specialty__pc.length() < 254){
                    conObj.ESA_Provider_Specialty__c = conObj.account.Provider_Specialty__pc;
                }else if(!String.isEmpty(conObj.account.Provider_Specialty__pc) && conObj.account.Provider_Specialty__pc.length() > 254){
                    conObj.ESA_Provider_Specialty__c = conObj.account.Provider_Specialty__pc.substring(0,250);
                }else if(String.isEmpty(conObj.account.Provider_Specialty__pc)){
                    conObj.ESA_Provider_Specialty__c = '';
                }
                conListToUpdate.add(new Contact(id = conObj.id, ESA_Provider_Specialty__c = conObj.ESA_Provider_Specialty__c));
            }
            if(!conListToUpdate.isEmpty()){
                Update conListToUpdate;
            }
        }
    }
    
/**
* @author: Deepak
* @date: 10 Nov 2023
* @description: The purpose of this method is to close related cases on patient inactive.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
                     02 Oct -  EDRD-819           -  Accenture   -  Added account helper class to run in system context                      
*/ 
    public static void closeCaseOnAccDeceased(List<Account> newAccountList, Map<Id,Account> oldAccountMap, Map<Id,Account> newAccountMap) {
        Set<Id> patientIdSet = new Set<Id>();
        for(account patientRec: newAccountList){
            Boolean isPatientDeceasedChange = (oldAccountMap.get(patientRec.Id).Patient_is_Deceased__pc != newAccountMap.get(patientRec.Id).Patient_is_Deceased__pc
                                               && newAccountMap.get(patientRec.Id).Patient_is_Deceased__pc);
            
            if(isPatientDeceasedChange){
                patientIdSet.add(patientRec.Id);
            }
        }
        
        if(!patientIdSet.isEmpty()){
            AccountTriggerHelper.processDeceasedPatientEDRDCPE(patientIdSet);
            AccountTriggerHelper.processDeceasedPatientEDRDCases(patientIdSet);
        }
    }
    
/**
* @author: Deepak
* @date: 20 Dec 2024
* @description: The purpose of this method is to Adding/Removing - Provider/Reviewer to public groups based on EDRD Committees.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]  
                     02 Oct -  EDRD-1450         -  Accenture   -  Adding/Removing - Provider/Reviewer to EDRD Reviewer public groups & Permission set
*/ 
    public static void handlePublicGroupMemberships(Map<Id, Account> oldAccountMap, Map<Id, Account> newAccountMap) {
        Map<Id, Set<String>> perConIdVsOldCommittesName = new Map<Id, Set<String>>();
        Map<Id, Set<String>> perConIdVsnewCommitteeName = new Map<Id, Set<String>>();
        List<String> perConIdVsOldCommittesNameSTRList = new List<String>();
        List<String> perConIdVsnewCommitteeNameSTRList = new List<String>();
        Map<String, Id> accNameVsPerConId = new Map<String, Id>();
        Map<Id, String> PerConIdVsTransType = new Map<Id, String>();
        
        for (Id accountId : newAccountMap.keySet() ) {
            Account oldAccount = oldAccountMap.get(accountId);
            Account newAccount = newAccountMap.get(accountId);
            if(oldAccount.Committee__pc == newAccount.Committee__pc && oldAccount.Committee_Name__pc == newAccount.Committee_Name__pc 
               || ((newAccount.RecordTypeId != recordTypeProvider) && (newAccount.RecordTypeId != recordTypeEDRDReviewer))){
                   continue;
               }
            accNameVsPerConId.put(newAccount.Name, newAccount.PersonContactId);
            
            if(oldAccount.Committee_Name__pc != newAccount.Committee_Name__pc){
                if (oldAccount.Committee_Name__pc != null) {
                    perConIdVsOldCommittesName.put(oldAccount.perSonContactId, new Set<String>(oldAccount.Committee_Name__pc.split(';')));
                }
                if (newAccount.Committee_Name__pc != null) {
                    perConIdVsnewCommitteeName.put(newAccount.perSonContactId, new Set<String>(newAccount.Committee_Name__pc.split(';')));
                }
            }
            if(oldAccount.Committee__pc != newAccount.Committee__pc){
                if(!String.IsEmpty(newAccount.Committee__pc) && String.IsEmpty(oldAccount.Committee__pc)){
                    PerConIdVsTransType.put(newAccount.personContactId, 'ADD');
                }else if(String.IsEmpty(newAccount.Committee__pc) && !String.IsEmpty(oldAccount.Committee__pc)){
                    PerConIdVsTransType.put(newAccount.personContactId, 'REMOVE');
                }
                if(!perConIdVsOldCommittesName.containsKey(oldAccount.perSonContactId)){
                    perConIdVsOldCommittesName.put(oldAccount.perSonContactId, new Set<String>());
                }
                if(!perConIdVsnewCommitteeName.containsKey(newAccount.perSonContactId)){
                    perConIdVsnewCommitteeName.put(newAccount.perSonContactId, new Set<String>());
                }
                if (oldAccount.Committee__pc != null) {
                    String committeeName = (oldAccount.Committee__pc == 'EDRD Advisory/ Sub Committee') ? 'EDRD Advisory Committee' : oldAccount.Committee__pc;
                    perConIdVsOldCommittesName.get(oldAccount.perSonContactId).add(committeeName);
                }
                if (newAccount.Committee__pc != null) {
                    perConIdVsnewCommitteeName.get(newAccount.perSonContactId).addAll(newAccount.Committee__pc.split(';'));                    
                }  
            }
            if(oldAccount.Committee__pc != newAccount.Committee__pc){
                if(newAccount.Committee__pc == 'EDRD Advisory Committee' || newAccount.Committee__pc == 'EDRD Advisory/ Sub Committee'){
                    if(!perConIdVsnewCommitteeName.containsKey(newAccount.perSonContactId)){
                        perConIdVsnewCommitteeName.put(newAccount.perSonContactId, new Set<String>{'EDRD Advisory Committee'});
                    }else {
                        perConIdVsnewCommitteeName.get(newAccount.perSonContactId).add('EDRD Advisory Committee');
                    }
                }                
            }
            for(Id perContactId: perConIdVsOldCommittesName.keySet()){
                groupMemberWrapper gMWObj = new groupMemberWrapper();
                gMWObj.personContactId = perContactId;
                List<cls_committiees> committeList = new List<cls_committiees>();
                for(String committeeName : perConIdVsOldCommittesName.get(perContactId)){
                    committeList.add(new cls_committiees(committeeName));
                }
                gMWObj.committiees = committeList;
                perConIdVsOldCommittesNameSTRList.add(JSON.serialize(gMWObj));
            }
            
            for(Id perContactId: perConIdVsnewCommitteeName.keySet()){
                groupMemberWrapper gMWObj = new groupMemberWrapper();
                gMWObj.personContactId = perContactId;
                List<cls_committiees> committeList = new List<cls_committiees>();
                for(String committeeName : perConIdVsnewCommitteeName.get(perContactId)){
                    committeList.add(new cls_committiees(committeeName));
                }
                gMWObj.committiees = committeList;
                perConIdVsnewCommitteeNameSTRList.add(JSON.serialize(gMWObj));
            }
            if(!perConIdVsOldCommittesNameSTRList.isEmpty() || !perConIdVsnewCommitteeNameSTRList.isEmpty()){
                EDRD_cls_HandleGroups.handleGroupMembership(perConIdVsOldCommittesNameSTRList, perConIdVsnewCommitteeNameSTRList, PerConIdVsTransType);
            }
        }
    }
    
/**
* @author: Deepak
* @date: 20 Dec 2024
* @description: The purpose of this wrapper is to create JSON for Maps -perConIdVsOldCommittesName & perConIdVsnewCommitteeName.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]                    
*/    
    public class groupMemberWrapper{        
        public String personContactId;	
        public cls_committiees[] committiees;
    }
    public class cls_committiees {
        public String committeeName;  
        cls_committiees(String committeeName){
            this.committeeName = committeeName;
        }
    }
    public static groupMemberWrapper parse(String json){
        return (groupMemberWrapper) System.JSON.deserialize(json, groupMemberWrapper.class);
    }

}