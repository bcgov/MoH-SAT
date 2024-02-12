/**********************************************************************************************
* @Author:      Suman 
* @Date:        08 Feb 2023
* @Description: The purpose of this class is to create methods which can be used by Flow EDRD Account Contact Case Share
***********************************************************************************************/
public with sharing class EDRDAccountContactShare {
/** 
* @author: Suman
* @date:  07 Feb 2023
* @description: The purpose of this method is to share New MedicationRequest details with to all associated Account's of a Contact for newly created AccountContact relation.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/
    @InvocableMethod
    public static void accountContactMedicationRequestSharing(List<AccountContactRelation> newRecords) {
        try {
            Set<Id> contactIds = new Set<Id>();
            Map<Id, Set<Id>> accountToMedicationRequestMap = new Map<Id, Set<Id>>();
            Map<Id, Set<Id>> accountToUserMap = new Map<Id, Set<Id>>();
            AccountContactRelation acr = null;
            for (AccountContactRelation record : [SELECT Id, ContactId, Contact.AccountId, Account.PersonContactId, AccountId FROM AccountContactRelation Order By CreatedDate DESC LIMIT 1]) {
                if (record != null && record.Contact.AccountId != null) {
                    contactIds.add(record.Contact.AccountId);
                    acr = record;
                }
            }
            if (!contactIds.isEmpty()) {
                for (MedicationRequest patientMedicationRequest : [SELECT Id, PatientId FROM MedicationRequest WHERE PatientId IN :contactIds]) {
                    if (!accountToMedicationRequestMap.containsKey(patientMedicationRequest.PatientId)) {
                        accountToMedicationRequestMap.put(patientMedicationRequest.PatientId, new Set<Id>());
                    }
                    accountToMedicationRequestMap.get(patientMedicationRequest.PatientId).add(patientMedicationRequest.Id);
                    
                }
            }
            if (acr != null && acr.Account.PersonContactId != null) {
                for (User userRecord : [SELECT Id FROM User WHERE ContactId = :acr.Account.PersonContactId]) {
                    if (userRecord.Id != null) {
                        if (!accountToUserMap.containsKey(acr.Account.PersonContactId)) {
                            accountToUserMap.put(acr.Account.PersonContactId, new Set<Id>());
                        }
                        accountToUserMap.get(acr.Account.PersonContactId).add(userRecord.Id);
                    }
                }
            }

            List<MedicationRequestShare> medicationRequestSharesToInsert = new List<MedicationRequestShare>();
            for (Id contactId : accountToMedicationRequestMap.keySet()) {
                for (Id userId : accountToUserMap.get(acr.Account.PersonContactId)) {
                    if (accountToUserMap.containsKey(acr.Account.PersonContactId)) {
                        for (Id medicationRequestId : accountToMedicationRequestMap.get(contactId)) {
                            MedicationRequestShare newMedicationRequestShare = new MedicationRequestShare();
                            newMedicationRequestShare.ParentId = medicationRequestId;
                            newMedicationRequestShare.UserOrGroupId = userId;
                            newMedicationRequestShare.AccessLevel = 'Read';
                            medicationRequestSharesToInsert.add(newMedicationRequestShare);
                        }
                    }
                }
            }

            if (!medicationRequestSharesToInsert.isEmpty()) {
                insert medicationRequestSharesToInsert;
            }
        } catch (Exception err) {
            System.debug('An error occurred: ' + err.getMessage());
        }
    }
}