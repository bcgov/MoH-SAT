/**********************************************************************************************
* @Author:      Deepak 
* @Date:        14 Dec 2023
* @Description: The purpose of this class is to cover Code coverage of EDRD_cls_medicationRequestHandler
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description] 
***********************************************************************************************/

@isTest
public class EDRD_cls_medicationRequestHandlerTest {
    
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
        Case MRCase = TestFactory.createEDRDCase(recordTypeCaseEDRD, RequestorAccount.Id);
        insert MRCase;
        Medication MedicationRec = TestFactory.createMedication();
        insert MedicationRec;
        MedicationRequest MedicationRequestRec = TestFactory.createMedicationRequest(MedicationRec.Id, MRCase.Id, requestorAccount.Id, patientAccount.Id); 
        insert MedicationRequestRec;
        try{
            Test.startTest();
            MedicationRequest MedicationRequestRec2 = TestFactory.createMedicationRequest(MedicationRec.Id, MRCase.Id, requestorAccount.Id, patientAccount.Id);
            insert MedicationRequestRec2;
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
        Case MRCase = TestFactory.createEDRDCase(recordTypeCaseEDRD, RequestorAccount.Id);
        insert MRCase;
        Medication MedicationRec = TestFactory.createMedication();
        insert MedicationRec;
        UnitOfMeasure UOMRec = TestFactory.createUnitOfMeasure();
        insert UOMRec;
        MedicinalIngredient MIRec = TestFactory.createMedicinalIngredient(MedicationRec.Id, UOMRec.Id);
        insert MIRec;
        MedicationRequest MRObj = TestFactory.createMedicationRequest(MedicationRec.Id, MRCase.Id, requestorAccount.Id, patientAccount.Id); 
        MRObj.Dosage__c = 300;
        MRObj.Dosage_Units__c = UOMRec.Id;
        MRObj.Requested_Frequency__c = 1;
        MRObj.Requested_Frequency_Unit__c = 'Weekly';
        MRObj.Requested_Funding_Duration__c = 1;
        MRObj.Requested_Funding_Duration_Unit__c = 'Weeks';
        MRObj.Medication_Information__c = MIRec.Id;
        Test.startTest();
        insert MRObj;
        MRObj.Requested_Funding_Duration_Unit__c = 'Months';
        Update MRObj;
        MRObj.Requested_Funding_Duration_Unit__c = 'Years';
        Update MRObj;
        Test.stopTest();
        Assert.areEqual([SELECT Id, Expenditure_Estimate__c FROM MedicationRequest WHERE Id =: MRObj.Id].get(0).Expenditure_Estimate__c, 5200, 'Calculation Failed');
        Assert.areNotEqual([SELECT Id, Expenditure_Estimate__c FROM MedicationRequest WHERE Id =: MRObj.Id].get(0).Expenditure_Estimate__c, NULL, 'Calculation Populated Blank value');
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
        Case MRCase = TestFactory.createEDRDCase(recordTypeCaseEDRD, RequestorAccount1.Id);
        MRCase.EDRD_MOHApproved_Dosage__c = 300;
        MRCase.EDRD_MOHApproved_Dosage_Unit__c = UOMRec.Id;
        MRCase.EDRD_MOHApproved_Frequency__c = 1;
        MRCase.EDRD_MOHApproved_Frequency_Unit__c = 'Weekly';
        MRCase.EDRD_MOHApproved_Funding_Duration__c = 1;
        MRCase.EDRD_MOHApproved_Funding_Duration_Unit__c = 'Weeks';
        insert MRCase;
        Medication MedicationRec = TestFactory.createMedication();
        insert MedicationRec;
        MedicinalIngredient MIRec = TestFactory.createMedicinalIngredient(MedicationRec.Id, UOMRec.Id);
        insert MIRec;
        MedicinalIngredient MIRec1 = TestFactory.createMedicinalIngredient(MedicationRec.Id, UOMRec.Id);
        insert MIRec1;
        MedicationRequest MRObj = TestFactory.createMedicationRequest(MedicationRec.Id, MRCase.Id, requestorAccount1.Id, patientAccount1.Id); 
        MRObj.Dosage__c = 300;
        MRObj.Dosage_Units__c = UOMRec.Id;
        MRObj.Requested_Frequency__c = 1;
        MRObj.Requested_Frequency_Unit__c = 'Weekly';
        MRObj.Requested_Funding_Duration__c = 1;
        MRObj.Requested_Funding_Duration_Unit__c = 'Weeks';
        MRObj.Medication_Information__c = MIRec.Id;
        insert MRObj;
        Test.startTest();
        MRObj.Medication_Information__c = MIRec1.Id;
        Update MRObj;
        Test.stopTest();
        Assert.areEqual([SELECT Id, Expenditure_Estimate__c, Case__r.EDRD_MOHDrug_Cost_Forecast__c FROM MedicationRequest WHERE Id =: MRObj.Id].get(0).Case__r.EDRD_MOHDrug_Cost_Forecast__c, 100, 'Calculation Failed');
        Assert.areNotEqual([SELECT Id, Expenditure_Estimate__c, Case__r.EDRD_MOHDrug_Cost_Forecast__c FROM MedicationRequest WHERE Id =: MRObj.Id].get(0).Case__r.EDRD_MOHDrug_Cost_Forecast__c, NULL, 'Calculation Populated Blank value');
    }
}