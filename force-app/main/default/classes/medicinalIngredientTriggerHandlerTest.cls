/**********************************************************************************************
* @Author:      Deepak 
* @Date:        07 Jan 2024
* @Description: The purpose of this class is to cover Code coverage of medicinalIngredientTriggerHandler
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description] 
***********************************************************************************************/

@isTest
public class medicinalIngredientTriggerHandlerTest {
    
/**
* @author: Deepak
* @date: 07 Jan 2024
* @description: The purpose of this method is to cover Testcoverage of updateOpenMedicationRequest.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/    
    @isTest
    public static void updateOpenMedicationRequest_positive(){
        Account requestorAccountRec = TestFactory.newProvider('Provider Test');
        insert requestorAccountRec;
        Account patientAccountRec = TestFactory.newPatient('Patient Test');
        insert patientAccountRec;
        UnitOfMeasure UOMeasureRec = TestFactory.createUnitOfMeasure();
        insert UOMeasureRec;
        Id recordTypeCaseEDRD = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('EDRD').getRecordTypeId();
        List<Case> MRCaseList = TestFactory.createEDRDCase(1, recordTypeCaseEDRD, RequestorAccountRec.Id);
        MRCaseList.get(0).EDRD_MOHApproved_Dosage__c = 300;
        MRCaseList.get(0).EDRD_MOHApproved_Dosage_Unit__c = UOMeasureRec.Id;
        MRCaseList.get(0).EDRD_MOHApproved_Frequency__c = 1;
        MRCaseList.get(0).EDRD_MOHApproved_Frequency_Unit__c = 'Weekly';
        MRCaseList.get(0).EDRD_MOHApproved_Funding_Duration__c = 1;
        MRCaseList.get(0).EDRD_MOHApproved_Funding_Duration_Unit__c = 'Weeks';
        insert MRCaseList;
        List<Medication> MedicationRecList = TestFactory.createMedication(1, 'Test Medication');
        insert MedicationRecList;
        Id recordTypeMIEDRD = Schema.SObjectType.MedicinalIngredient.getRecordTypeInfosByDeveloperName().get('EDRD_Medicinal_Ingredient').getRecordTypeId();
        List<MedicinalIngredient> MIRecList = TestFactory.createMedicinalIngredient(1, MedicationRecList.get(0).Id, UOMeasureRec.Id);
        MIRecList.get(0).recordTypeId = recordTypeMIEDRD;
        insert MIRecList;
        List<MedicationRequest> MRObjList = TestFactory.createMedicationRequest(1, MedicationRecList.get(0).Id, MRCaseList.get(0).Id, requestorAccountRec.Id, patientAccountRec.Id); 
        MRObjList.get(0).Dosage__c = 600;
        MRObjList.get(0).Dosage_Units__c = UOMeasureRec.Id;
        MRObjList.get(0).Requested_Frequency__c = 1;
        MRObjList.get(0).Requested_Frequency_Unit__c = 'Monthly';
        MRObjList.get(0).Requested_Funding_Duration__c = 2;
        MRObjList.get(0).Requested_Funding_Duration_Unit__c = 'Months';
        MRObjList.get(0).Medication_Information__c = MIRecList.get(0).Id;
        Id recordTypeMREDRD = Schema.SObjectType.MedicationRequest.getRecordTypeInfosByDeveloperName().get('EDRD_Medication_Request').getRecordTypeId();
        MRObjList.get(0).recordTypeId = recordTypeMREDRD;
        insert MRObjList;
        Test.startTest();        
        MIRecList.get(0).Unit_Price__c = 200;
        Update MIRecList;
        Test.stopTest();
        Assert.areEqual([SELECT Id, Expenditure_Estimate__c FROM MedicationRequest WHERE Id =: MRObjList.get(0).Id].get(0).Expenditure_Estimate__c, 800, 'Expenditure Estimate Calculation has Failed');
        Assert.areNotEqual([SELECT Id, Expenditure_Estimate__c FROM MedicationRequest WHERE Id =: MRObjList.get(0).Id].get(0).Expenditure_Estimate__c, NULL, 'Expenditure Estimate Calculation has Populated Blank value');
    }
}