/**********************************************************************************************
* @Author:      Deepak 
* @Date:        07 Jan 2024
* @Description: The purpose of this class is to cover Code coverage of EDRD_cls_medicinalIngredientHandler
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description] 
***********************************************************************************************/

@isTest
public class EDRD_cls_medicinalIngredientHandlerTest {
    
/**
* @author: Deepak
* @date: 07 Jan 2024
* @description: The purpose of this method is to cover Testcoverage of updateOpenMedicationRequest.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/    
    @isTest
    public static void updateOpenMedicationRequest_positive(){
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
        MRObj.Requested_Frequency_Unit__c = 'Monthly';
        MRObj.Requested_Funding_Duration__c = 2;
        MRObj.Requested_Funding_Duration_Unit__c = 'Months';
        MRObj.Medication_Information__c = MIRec.Id;
        insert MRObj;
        Test.startTest();        
        MIRec.Unit_Price__c = 200;
        Update MIRec;
        Test.stopTest();
        Assert.areEqual([SELECT Id, Expenditure_Estimate__c FROM MedicationRequest WHERE Id =: MRObj.Id].get(0).Expenditure_Estimate__c, 400, 'Expenditure Estimate Calculation has Failed');
        Assert.areNotEqual([SELECT Id, Expenditure_Estimate__c FROM MedicationRequest WHERE Id =: MRObj.Id].get(0).Expenditure_Estimate__c, NULL, 'Expenditure Estimate Calculation has Populated Blank value');
    }
}