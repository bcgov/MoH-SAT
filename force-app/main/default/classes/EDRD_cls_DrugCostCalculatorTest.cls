/**********************************************************************************************
* @Author:      Deepak 
* @Date:        15 Jan 2024
* @Description: The purpose of this class is to is to cover Code coverage of EDRD_cls_DrugCostCalculator.
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]  
***********************************************************************************************/
@isTest
public class EDRD_cls_DrugCostCalculatorTest {
    
/**
* @author: Deepak
* @date: 15 Jan 2024
* @description: The purpose of this method is to cover Testcoverage of populateMRExpenditureEstimate
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/    
    @isTest
    public static void populateMRExpenditureEstimate_positive(){
        Account reqAccount = TestFactory.newProvider('Provider Test');
        insert reqAccount;
        Account patntAccount = TestFactory.newPatient('Patient Test');
        insert patntAccount;
        Id recordTypeCaseEDRD = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('EDRD').getRecordTypeId();
        Case MRCase = TestFactory.createEDRDCase(recordTypeCaseEDRD, ReqAccount.Id);
        insert MRCase;
        Medication MedicationRec = TestFactory.createMedication();
        insert MedicationRec;
        UnitOfMeasure UOMRec = TestFactory.createUnitOfMeasure();
        insert UOMRec;
        MedicinalIngredient MInRec = TestFactory.createMedicinalIngredient(MedicationRec.Id, UOMRec.Id);
        insert MInRec;
        MedicationRequest MReqObj = TestFactory.createMedicationRequest(MedicationRec.Id, MRCase.Id, reqAccount.Id, patntAccount.Id); 
        MReqObj.Dosage__c = 300;
        MReqObj.Dosage_Units__c = UOMRec.Id;
        MReqObj.Requested_Frequency__c = 1;
        MReqObj.Requested_Frequency_Unit__c = 'Weekly';
        MReqObj.Requested_Funding_Duration__c = 1;
        MReqObj.Requested_Funding_Duration_Unit__c = 'Weeks';
        MReqObj.Medication_Information__c = MInRec.Id;
        Test.startTest();
        insert MReqObj;
        MReqObj.Requested_Funding_Duration_Unit__c = 'Months';
        Update MReqObj;
        MReqObj.Requested_Funding_Duration_Unit__c = 'Years';
        Update MReqObj;
        Test.stopTest();
        Assert.areEqual([SELECT Id, Expenditure_Estimate__c FROM MedicationRequest WHERE Id =: MReqObj.Id].get(0).Expenditure_Estimate__c, 5200, 'Calculation Failed');
        Assert.areNotEqual([SELECT Id, Expenditure_Estimate__c FROM MedicationRequest WHERE Id =: MReqObj.Id].get(0).Expenditure_Estimate__c, NULL, 'Calculation Populated Blank value');
    }

}