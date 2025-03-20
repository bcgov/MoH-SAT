/**********************************************************************************************
* @Author:      Accenture
* @Date:        19/12/2024
* @Description: The purpose of this class is to create methods which can be used by different trigger event
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]
               19-Dec  -   EDRD-309         -  Accenture   -  insert/update the name based on record 
               08 Feb  -   EDRD-338		    -  Accenture   -  method is to Prevent users from selecting the Account records other than committee for EDRD Meetings.
***********************************************************************************************/
public with sharing class ServiceAppointmentTriggerHandler {
    public static Id recordTypeServiceAppointmentEDRD = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByDeveloperName().get('EDRD_Committee_Meeting').getRecordTypeId();
    public static Id recordTypeAccEDRD = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('EDRD_Committee').getRecordTypeId();
    public static String meetingAgenda = Label.EDRDServiceAppointmentAgenda;
    
/**
* @author: Accenture
* @date: 19/12/2024
* @description: The purpose of this method is to insert the Name based on ParentRecord Name and EarliestStartTime
*/     
    public static void insertSAName(List<ServiceAppointment> saList){
        if(!saList.isEmpty()){
            Set<Id>saAccIds = new Set<Id>();
            for(ServiceAppointment sapp : saList){
                sapp.EDRD_Agenda__c = sapp.EDRD_Agenda__c !=null ? meetingAgenda + ' ' + sapp.EDRD_Agenda__c : meetingAgenda;  
                if(sapp.ParentRecordId != null ){
                    saAccIds.add(sapp.ParentRecordId);
                }
            }
            if(!saAccIds.isEmpty()){
                updateServiceAppoinment(saAccIds,saList);
            }
        }
    }
    
/**********************************************************************************************
* @author: Accenture
* @date: 19/12/2024
* @description: The purpose of this method is to update the Name based on ParentRecord Name and EarliestStartTime
*****************************************************************************************************/     
    public static void updateSAName(List<ServiceAppointment> saList,Map<Id,ServiceAppointment> saOldMap){
        if(!saList.isEmpty()){
            Set<Id>saAccIds = new Set<Id>();
            for(ServiceAppointment sapp : saList){
                
                if(sapp.ParentRecordId != null && sapp.EarliestStartTime != saOldMap.get(sapp.Id).EarliestStartTime){
                    saAccIds.add(sapp.ParentRecordId);
                }
            }
            if(!saAccIds.isEmpty()){
                updateServiceAppoinment(saAccIds,saList);
            }
        }
    }

/**********************************************************************************************
* @author: Accenture
* @description: internal Method
*****************************************************************************************************/    
    public static void updateServiceAppoinment(Set<Id> saAccIds,List<ServiceAppointment> saList){
        if(!saAccIds.isEmpty()){
            Map<Id,Account> saAccMap = new Map<Id,Account>([Select Id,Name from Account 
                                                            where RecordTypeId =: recordTypeAccEDRD 
                                                            and Id in :saAccIds]);
            if(!saAccMap.isEmpty()){
                for(ServiceAppointment sapp : saList)
                {
                    if(sapp.EarliestStartTime != null && saAccMap.containskey(sapp.ParentRecordId))        {
                        Account acc = saAccMap.get(sapp.ParentRecordId);                           
                        String trunDate = sapp.EarliestStartTime.format('yyyy-MM-dd');
                        String name = acc.Name + ' - ' + trunDate; 
                        sapp.EDRD_Name__c = name;
                    }                        
                }
            }
        }
    }
    
/**
* @author: Deepak
* @date: 08 Feb 2025
* @description: The purpose of this method is to Prevent users from selecting the Account records other than committee for EDRD Meetings.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/      
    public static void validateEDRDCommitteeMeeting(List<ServiceAppointment> newAppointments) {
        Set<Id> accountIds = new Set<Id>();
        
        for (ServiceAppointment sa : newAppointments) {
            if (sa.RecordTypeId == recordTypeServiceAppointmentEDRD) {
                if (sa.ParentRecordId == null || !String.valueOf(sa.ParentRecordId).startsWith('001')) {
                    sa.addError(Label.EDRD_label_SA_Committee_Error_Msg);
                } else if(sa.ParentRecordId == null || String.valueOf(sa.ParentRecordId).startsWith('001')) {
                    accountIds.add(sa.ParentRecordId);
                }
            }
        }
        
        if (!accountIds.isEmpty()) {
            Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, IsActive, RecordType.DeveloperName FROM Account WHERE Id IN :accountIds]);
            
            for (ServiceAppointment sa : newAppointments) {
                if (sa.RecordTypeId == recordTypeServiceAppointmentEDRD && sa.ParentRecordId != null) {
                    Account relatedAccount = accountMap.get(sa.ParentRecordId);
                    
                    if (relatedAccount != null && relatedAccount.RecordTypeId != recordTypeAccEDRD) {
                        sa.addError(Label.EDRD_label_SA_Committee_Error_Msg);
                    } else if(relatedAccount != null && relatedAccount.RecordTypeId == recordTypeAccEDRD && !relatedAccount.IsActive) {
                        sa.addError(Label.EDRD_label_SA_InActiveCommittee_Error_Msg);                        
                    }
                }
            }
        }
    }    
}