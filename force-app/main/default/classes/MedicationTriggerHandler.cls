/**********************************************************************************************
* @Author:      Deepak 
* @Date:        16 Dec 2023
* @Description: The purpose of this class is to create methods which can be used by different trigger event
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]  
***********************************************************************************************/
public with sharing class MedicationTriggerHandler {
    
/**
* @author: Deepak
* @date: 16 Dec 2023
* @description: The purpose of this method is to Close Case on Drug Inactive.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/ 
    public static void changeCaseStatus(Map<Id,Medication> oldDrugIdVsRec, Map<Id,Medication> newDrugIdVsRec){
        Set<Id> medicationIdSet = new Set<Id>();
        Set<String> MedCloseStatus = new Set<String>{'Inactive'};
            Id recordTypeMedicationEDRD = Schema.SObjectType.Medication.getRecordTypeInfosByDeveloperName().get('EDRD').getRecordTypeId();
        List<Case> caseListToUpdate = new List<Case>();
        Map<Id, Map<String, String>> accountIdVsNotificationDetails = new Map<Id, Map<String, String>>();
        for(Medication medObj: newDrugIdVsRec.Values()){
            Boolean isDrugInactive = medObj.Status != oldDrugIdVsRec.get(medObj.Id).status && MedCloseStatus.Contains(medObj.Status);
            if(isDrugInactive && medObj.recordTypeId == recordTypeMedicationEDRD){
                medicationIdSet.add(medObj.Id);
            }
        }
        if(!medicationIdSet.isEmpty()){
            for(MedicationRequest MRObj: [SELECT Id, Case__c, Case__r.EDRD_Notes__c, Case__r.Provider__r.AccountId,
                                          Case__r.Provider__r.Name, Case__r.CaseNumber, Medication.Name
                                          FROM MedicationRequest WHERE MedicationId IN: medicationIdSet AND Case__r.IsClosed = false AND Case__c != NULL])
            {
                if(MRObj.Case__c != NULL && MRObj.Case__r.Provider__c != NULL && MRObj.Case__r.Provider__r.AccountId != NULL){
                    accountIdVsNotificationDetails.put(MRObj.Case__r.Provider__r.AccountId, 
                                                       new Map<String, String>{'PROVIDER_NAME' => MRObj.Case__r.Provider__r.Name, 
                                                           'CASE_NUMBER' =>  MRObj.Case__r.CaseNumber,
                                                           'MEDICATION_NAME' => MRObj.Medication.Name});
                }
                caseListToUpdate.add(new Case(Id = MRObj.Case__c, 
                                              Status = 'Cancelled', 
                                              EDRD_Case_closure_reasons__c = 'Other',
                                              EDRD_MOHFunding_Decision__c = 'Denied',
                                              EDRD_MOHIndefinite_Funding__c = false,
                                              EDRD_Notes__c = !String.IsBlank(MRObj.Case__r.EDRD_Notes__c) 
                                              ? MRObj.Case__r.EDRD_Notes__c + '\n' + label.EDRD_label_closeCase_DrugInactive 
                                              : label.EDRD_label_closeCase_DrugInactive));            
            }
        }
        if(!caseListToUpdate.isEmpty()){
            Update caseListToUpdate;
        }
        if(!accountIdVsNotificationDetails.isEmpty()){
            MedicationTriggerHandler.sendNotification(accountIdVsNotificationDetails);
        }
    }
    
/**
* @author: Deepak
* @date: 16 Dec 2023
* @description: The purpose of this method is to send custom Notification when Medication is inactive.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/    
    public static void sendNotification(Map<Id, Map<String, String>> accountIdVsNotificationDetails){
        List<User> userList = [SELECT Id, Contact.AccountId FROM USER WHERE Contact.AccountId IN: accountIdVsNotificationDetails.KeySet()];
        List<CustomNotificationType> TemplateInfoDetail = [SELECT Id, DeveloperName FROM CustomNotificationType
                                                           WHERE DeveloperName='EDRD_BellNotificationForProviders'];
        for(User userObj:userList){
            Map<String, String> notificationDetails = accountIdVsNotificationDetails.get(UserObj.Contact.accountId);
            Messaging.CustomNotification cusNotification = new Messaging.CustomNotification();
            cusNotification.setTitle(label.EDRD_label_customNotificationSub);
            cusNotification.setBody(label.EDRD_label_customNoficationMsg.replace('PROVIDER_NAME',notificationDetails.get('PROVIDER_NAME'))
                                    .replace('CASE_NUMBER',notificationDetails.get('CASE_NUMBER'))
                                    .replace('MEDICATION_NAME',notificationDetails.get('MEDICATION_NAME')));
            cusNotification.setNotificationTypeId(TemplateInfoDetail[0].Id);
            cusNotification.setTargetId(userObj.Id);
            try {
                cusNotification.send(new Set<String> {userObj.Id});
            }
            catch (Exception ex) {
                System.debug('Notification Failed:'  + ex.getMessage());
            }
        }
    } 
}