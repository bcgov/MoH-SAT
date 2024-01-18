/**********************************************************************************************
* @Author:      Deepak 
* @Date:        07 Jan 2024
* @Description: The purpose of this class is to create methods which can be used by different trigger event
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]  
***********************************************************************************************/
public with sharing class EDRD_cls_medicinalIngredientHandler {
    
/**
* @author: Deepak
* @date: 07 Jan 2024
* @description: The purpose of this method is to update the open Medication Request.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/ 
    public static Boolean updateOpenMedicationRequest_RunOnce = True;
    public static void updateOpenMedicationRequest(Set<Id> MedicinalIDSet){
        updateOpenMedicationRequest_RunOnce = false;
        List<MedicationRequest> MRList = [SELECT Id, Dosage__c, Dosage_Units__c, Requested_Frequency__c, Requested_Frequency_Unit__c,
                                          Requested_Funding_Duration__c, Requested_Funding_Duration_Unit__c, List_Price_per_Unit__c,
                                          Strength__c FROM MedicationRequest WHERE Medication_Information__c IN: MedicinalIDSet 
                                          AND Status = 'Active' AND Dosage__c != NULL AND Dosage_Units__c != NULL AND 
                                          Requested_Frequency__c != NULL AND Requested_Frequency_Unit__c != NULL AND 
                                          Requested_Funding_Duration__c != NULL AND Requested_Funding_Duration_Unit__c != NULL 
                                          AND List_Price_per_Unit__c != NULL AND Strength__c != NULL AND RecordType.DeveloperName = 'EDRD_Medication_Request'];
        
        List<MedicationRequest> MRListToUpdate = new List<MedicationRequest>();
        for(MedicationRequest MRObj : MRList){
            MRObj.Expenditure_Estimate__c = EDRD_cls_medicationRequestHandler.populateMRExpenditureEstimate(MRObj.Dosage__c, 
                                                                                                            MRObj.Dosage_Units__c, 
                                                                                                            MRObj.Requested_Frequency__c, 
                                                                                                            MRObj.Requested_Frequency_Unit__c,
                                                                                                            MRObj.Requested_Funding_Duration__c, 
                                                                                                            MRObj.Requested_Funding_Duration_Unit__c,
                                                                                                            MRObj.List_Price_per_Unit__c, 
                                                                                                            MRObj.Strength__c);
            
            MRListToUpdate.add(MRObj);
        }
        if(!MRListToUpdate.isEmpty()){
            Update MRListToUpdate;
        }
    }
}