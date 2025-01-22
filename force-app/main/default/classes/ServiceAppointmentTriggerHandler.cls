/**********************************************************************************************
* @Author:      Accenture
* @Date:        19/12/2024
* @Description: The purpose of this class is to create methods which can be used by different trigger event
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]
19-Dec24     EDRD-309           Accenture      insert/update the name based on record 

***********************************************************************************************/
public with sharing class ServiceAppointmentTriggerHandler {
    public static Id recordTypeAccEDRD = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('EDRD_Committee').getRecordTypeId();
    public static String meetingAgenda = Label.EDRDServiceAppointmentAgenda;
    /**
* @author: Accenture
* @date: 19/12/2024
* @description: The purpose of this method is to insert the Name based on ParentRecord Name and EarliestStartTime
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
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
    /**
* @author: Accenture
* @date: 19/12/2024
* @description: The purpose of this method is to update the Name based on ParentRecord Name and EarliestStartTime
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/     
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
    
}