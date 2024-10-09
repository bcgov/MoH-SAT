/**********************************************************************************************
* @Author:      Deepak 
* @Date:        09 Mar 2023
* @Description: The purpose of this class is to create methods which can be used by different trigger event
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
                11 Nov -  EDRD-82           -  Accenture   -  Added Close Case method on Account Inactive
***********************************************************************************************/
public with sharing class ESA_cls_accountTriggerHandler {
    
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
}