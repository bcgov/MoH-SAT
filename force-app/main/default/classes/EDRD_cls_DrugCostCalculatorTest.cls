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
        List<Case> MRCaseList = TestFactory.createEDRDCase(1, recordTypeCaseEDRD, ReqAccount.Id);
        insert MRCaseList;
        List<Medication> MedicationRecList = TestFactory.createMedication(1, 'Test Medication');
        insert MedicationRecList;
        UnitOfMeasure UOMRec = TestFactory.createUnitOfMeasure();
        insert UOMRec;
        List<MedicinalIngredient> MInRecList = TestFactory.createMedicinalIngredient(1, MedicationRecList.get(0).Id, UOMRec.Id);
        insert MInRecList;
        List<MedicationRequest> MReqObjList = TestFactory.createMedicationRequest(1, MedicationRecList.get(0).Id, MRCaseList.get(0).Id, reqAccount.Id, patntAccount.Id); 
        MReqObjList.get(0).Dosage__c = 300;
        MReqObjList.get(0).Dosage_Units__c = UOMRec.Id;
        MReqObjList.get(0).Requested_Frequency__c = 1;
        MReqObjList.get(0).Requested_Frequency_Unit__c = 'Weekly';
        MReqObjList.get(0).Requested_Funding_Duration__c = 1;
        MReqObjList.get(0).Requested_Funding_Duration_Unit__c = 'Weeks';
        MReqObjList.get(0).Medication_Information__c = MInRecList.get(0).Id;
        Test.startTest();
        insert MReqObjList;
        MReqObjList.get(0).Requested_Funding_Duration_Unit__c = 'Months';
        Update MReqObjList;
        MReqObjList.get(0).Requested_Funding_Duration_Unit__c = 'Years';
        Update MReqObjList;
        Test.stopTest();
        Assert.areEqual([SELECT Id, Expenditure_Estimate__c FROM MedicationRequest WHERE Id =: MReqObjList.get(0).Id].get(0).Expenditure_Estimate__c, 5200, 'Calculation Failed');
        Assert.areNotEqual([SELECT Id, Expenditure_Estimate__c FROM MedicationRequest WHERE Id =: MReqObjList.get(0).Id].get(0).Expenditure_Estimate__c, NULL, 'Calculation Populated Blank value');
    }

}