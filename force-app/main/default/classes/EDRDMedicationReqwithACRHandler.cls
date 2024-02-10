/**********************************************************************************************
* @Author:      Suman 
* @Date:        07 Feb 2023
* @Description: The purpose of this class is to create methods which can be used by different trigger event
***********************************************************************************************/
public class EDRDMedicationReqwithACRHandler {
/** 
* @author: Suman
* @date:  07 Feb 2023
* @description: The purpose of this method is to share New MedicationRequest to all associated Account's of Pateint for whom MedicationRequest is created.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/   
    public static void shareMedicationRequestsWithPatientAccount(List<MedicationRequest> newMedicationRequests) {
        try {
            Set<Id> accountIds = new Set<Id>();
            Map<Id, Set<Id>> accountToUserMap = new Map<Id, Set<Id>>();
            for (MedicationRequest newMedicationRequest : newMedicationRequests) {
                accountIds.add(newMedicationRequest.PatientId);
            }
            Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, AccountId FROM Contact WHERE AccountId IN :accountIds]);
            List<AccountContactRelation> acrList = [
                SELECT AccountId, ContactId, Account.PersonContactId
                FROM AccountContactRelation
                WHERE ContactId IN :contactMap.keySet()
            ];

            for (AccountContactRelation acr : acrList) {
                if (acr.Account.PersonContactId != null) {
                    if (!accountToUserMap.containsKey(acr.AccountId)) {
                        accountToUserMap.put(acr.AccountId, new Set<Id>());
                    }
                    Set<Id> personContactIds = new Set<Id>{acr.Account.PersonContactId};
                    List<User> userList = [SELECT Id FROM User WHERE ContactId IN :personContactIds];
                    for (User userRecord : userList) {
                        accountToUserMap.get(acr.AccountId).add(userRecord.Id);
                    }
                }
            }

            List<MedicationRequestShare> medicationRequestSharesToInsert = new List<MedicationRequestShare>();
            for (MedicationRequest currentMedicationRequest : newMedicationRequests) {
                Set<Id> accountContactIds = new Set<Id>();
                for (AccountContactRelation acr : acrList) {
                    accountContactIds.add(acr.AccountId);
                }

                if (!accountContactIds.isEmpty()) {
                    for (Id accountContactId : accountContactIds) {
                        if (accountToUserMap.containsKey(accountContactId)) {
                            for (Id userId : accountToUserMap.get(accountContactId)) {
                                MedicationRequestShare newMedicationRequestShare = new MedicationRequestShare();
                                newMedicationRequestShare.ParentId = currentMedicationRequest.Id;
                                newMedicationRequestShare.UserOrGroupId = userId;
                                newMedicationRequestShare.AccessLevel = 'Read';
                                medicationRequestSharesToInsert.add(newMedicationRequestShare);
                            }
                        }
                    }
                }
            }

            if (!medicationRequestSharesToInsert.isEmpty()) {
                insert medicationRequestSharesToInsert;
                System.debug('medicationRequestSharesToInsert '+medicationRequestSharesToInsert);
            }
        } catch (Exception err) {
            System.debug('An error occurred: ' + err.getMessage());
        }
    }
}