/**********************************************************************************************
* @Author:      Deepak 
* @Date:        14 Dec 2023
* @Description: The purpose of this class is to cover Code coverage of medicationRequestTriggerHandler
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description] 
***********************************************************************************************/

@isTest
public class medicationRequestTriggerHandlerTest {
    
/**
* @author: Deepak
* @date: 14 Dec 2023
* @description: The purpose of this method is to cover Testcoverage of validateMedicationRequest
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/    
    @isTest
    public static void validateMedicationRequest_positive(){
        Account requestorAccount = TestFactory.newProvider('Provider Test');
        insert requestorAccount;
        Account patientAccount = TestFactory.newPatient('Patient Test');
        insert patientAccount;
        Id recordTypeCaseEDRD = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('EDRD').getRecordTypeId();
        List<Case> MRCaseList = TestFactory.createEDRDCase(2, recordTypeCaseEDRD, RequestorAccount.Id);
        insert MRCaseList;
        UnitOfMeasure UOMRec = TestFactory.createUnitOfMeasure();
        insert UOMRec;
        List<Medication> MedicationRecList = TestFactory.createMedication(1, 'Test Medication');
        insert MedicationRecList;
        List<MedicinalIngredient> MInRecList = TestFactory.createMedicinalIngredient(1, MedicationRecList.get(0).Id, UOMRec.Id);
        Id recordTypeEDRDMI = Schema.SObjectType.MedicinalIngredient.getRecordTypeInfosByDeveloperName().get('EDRD_Medicinal_Ingredient').getRecordTypeId();
        MInRecList.get(0).RecordtypeId = recordTypeEDRDMI;
        insert MInRecList;
        List<MedicationRequest> MedicationRequestList = TestFactory.createMedicationRequest(1, MedicationRecList.get(0).Id, MRCaseList.get(0).Id, requestorAccount.Id, patientAccount.Id); 
        insert MedicationRequestList;
        try{
            Test.startTest();
            List<MedicationRequest> MedicationRequestList2 = TestFactory.createMedicationRequest(1, MedicationRecList.get(0).Id, MRCaseList.get(1).Id, requestorAccount.Id, patientAccount.Id);
            insert MedicationRequestList2;
            Test.stopTest();
        } 
        catch(exception e){
            Assert.areEqual(e.getMessage().containsIgnoreCase(label.EDRD_label_MR_duplicateCase), True, 'Duplicate Record Created');
            Assert.areNotEqual(e.getMessage().containsIgnoreCase(label.EDRD_label_MR_duplicateCase), False, 'Validation Failed');
        }
    }
    
/**
* @author: Deepak
* @date: 19 Dec 2023
* @description: The purpose of this method is to cover Testcoverage of populateMRExpenditureEstimate
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/    
    @isTest
    public static void populateMRExpenditureEstimate_positive(){
        Account requestorAccount = TestFactory.newProvider('Provider Test');
        insert requestorAccount;
        Account patientAccount = TestFactory.newPatient('Patient Test');
        insert patientAccount;
        Id recordTypeCaseEDRD = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('EDRD').getRecordTypeId();
        List<Case> MRCaseList = TestFactory.createEDRDCase(1, recordTypeCaseEDRD, RequestorAccount.Id);
        insert MRCaseList;
        List<Medication> MedicationRecList = TestFactory.createMedication(1, 'Test Medication');
        insert MedicationRecList;
        UnitOfMeasure UOMRec = TestFactory.createUnitOfMeasure();
        insert UOMRec;
        List<MedicinalIngredient> MIRecList = TestFactory.createMedicinalIngredient(1, MedicationRecList.get(0).Id, UOMRec.Id);
        Id recordTypeEDRDMI = Schema.SObjectType.MedicinalIngredient.getRecordTypeInfosByDeveloperName().get('EDRD_Medicinal_Ingredient').getRecordTypeId();
        MIRecList.get(0).RecordtypeId = recordTypeEDRDMI;
        insert MIRecList;
        List<MedicationRequest> MRList = TestFactory.createMedicationRequest(1, MedicationRecList.get(0).Id, MRCaseList.get(0).Id, requestorAccount.Id, patientAccount.Id); 
        MRList.get(0).Dosage__c = 300;
        MRList.get(0).Dosage_Units__c = UOMRec.Id;
        MRList.get(0).Requested_Frequency__c = 1;
        MRList.get(0).Requested_Frequency_Unit__c = 'Weekly';
        MRList.get(0).Requested_Funding_Duration__c = 1;
        MRList.get(0).Requested_Funding_Duration_Unit__c = 'Weeks';
        MRList.get(0).Medication_Information__c = MIRecList.get(0).Id;
        Test.startTest();
        insert MRList;
        MRList.get(0).Requested_Funding_Duration_Unit__c = 'Months';
        Update MRList;
        MRList.get(0).Requested_Funding_Duration_Unit__c = 'Years';
        Update MRList;
        Test.stopTest();
        Assert.areEqual([SELECT Id, Expenditure_Estimate__c FROM MedicationRequest WHERE Id =: MRList.get(0).Id].get(0).Expenditure_Estimate__c, 5200, 'Calculation Failed');
        Assert.areNotEqual([SELECT Id, Expenditure_Estimate__c FROM MedicationRequest WHERE Id =: MRList.get(0).Id].get(0).Expenditure_Estimate__c, NULL, 'Calculation Populated Blank value');
    }
    
/**
* @author: Deepak
* @date: 14 Jan 2024
* @description: The purpose of this method is to cover Testcoverage of calDrugForecastOnCase
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/    
    @isTest
    public static void calDrugForecastOnCase_positive(){
        Account requestorAccount1 = TestFactory.newProvider('Provider Test');
        insert requestorAccount1;
        Account patientAccount1 = TestFactory.newPatient('Patient Test');
        insert patientAccount1;
        UnitOfMeasure UOMRec = TestFactory.createUnitOfMeasure();
        insert UOMRec;
        Id recordTypeCaseEDRD = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('EDRD').getRecordTypeId();
        List<Case> MRCaseList = TestFactory.createEDRDCase(1, recordTypeCaseEDRD, RequestorAccount1.Id);
        MRCaseList.get(0).EDRD_MOHApproved_Dosage__c = 300;
        MRCaseList.get(0).EDRD_MOHApproved_Dosage_Unit__c = UOMRec.Id;
        MRCaseList.get(0).EDRD_MOHApproved_Frequency__c = 1;
        MRCaseList.get(0).EDRD_MOHApproved_Frequency_Unit__c = 'Weekly';
        MRCaseList.get(0).EDRD_MOHApproved_Funding_Duration__c = 1;
        MRCaseList.get(0).EDRD_MOHApproved_Funding_Duration_Unit__c = 'Weeks';
        insert MRCaseList;
        List<Medication> MedicationRecList = TestFactory.createMedication(1, 'Test Medication');
        insert MedicationRecList;
        List<MedicinalIngredient> MIRecList = TestFactory.createMedicinalIngredient(1, MedicationRecList.get(0).Id, UOMRec.Id);
        Id recordTypeMIEDRD = Schema.SObjectType.MedicinalIngredient.getRecordTypeInfosByDeveloperName().get('EDRD_Medicinal_Ingredient').getRecordTypeId();
        MIRecList.get(0).RecordtypeId = recordTypeMIEDRD;
        insert MIRecList;
        List<MedicinalIngredient> MIRecList1 = TestFactory.createMedicinalIngredient(1, MedicationRecList.get(0).Id, UOMRec.Id);
        Id recordTypeEDRDMI = Schema.SObjectType.MedicinalIngredient.getRecordTypeInfosByDeveloperName().get('EDRD_Medicinal_Ingredient').getRecordTypeId();
        MIRecList1.get(0).RecordtypeId = recordTypeEDRDMI;
        insert MIRecList1;
        List<MedicationRequest> MRObjList = TestFactory.createMedicationRequest(1, MedicationRecList.get(0).Id, MRCaseList.get(0).Id, requestorAccount1.Id, patientAccount1.Id); 
        MRObjList.get(0).Dosage__c = 300;
        MRObjList.get(0).Dosage_Units__c = UOMRec.Id;
        MRObjList.get(0).Requested_Frequency__c = 1;
        MRObjList.get(0).Requested_Frequency_Unit__c = 'Weekly';
        MRObjList.get(0).Requested_Funding_Duration__c = 1;
        MRObjList.get(0).Requested_Funding_Duration_Unit__c = 'Weeks';
        MRObjList.get(0).Medication_Information__c = MIRecList.get(0).Id;
        insert MRObjList;
        Test.startTest();
        MRObjList.get(0).Medication_Information__c = MIRecList1.get(0).Id;
        Update MRObjList;
        Test.stopTest();
        Assert.areEqual([SELECT Id, Expenditure_Estimate__c, Case__r.EDRD_MOHDrug_Cost_Forecast__c FROM MedicationRequest WHERE Id =: MRObjList.get(0).Id].get(0).Case__r.EDRD_MOHDrug_Cost_Forecast__c, 100, 'Calculation Failed');
        Assert.areNotEqual([SELECT Id, Expenditure_Estimate__c, Case__r.EDRD_MOHDrug_Cost_Forecast__c FROM MedicationRequest WHERE Id =: MRObjList.get(0).Id].get(0).Case__r.EDRD_MOHDrug_Cost_Forecast__c, NULL, 'Calculation Populated Blank value');
    }
}