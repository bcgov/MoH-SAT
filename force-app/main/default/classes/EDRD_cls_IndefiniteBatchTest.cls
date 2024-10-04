/**********************************************************************************************
* @Author:      Deepak 
* @Date:        25 Aug 2024
* @Description: The purpose of this class is to cover Code coverage of EDRD_cls_IndefiniteBatchTest.
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]  
***********************************************************************************************/
@isTest
public class EDRD_cls_IndefiniteBatchTest {
    
    @TestSetUp
    public static void createTestData() {
        Account prvderAcc = TestFactory.newProvider('Provider Test');
        insert prvderAcc;
        Account patientAcc = TestFactory.newPatient('Patient Test');
        patientAcc.Patient_is_Deceased__pc = false;
        insert patientAcc;
        careProgram carePrgmRec = TestFactory.createCareProgram('EDRD');
        insert carePrgmRec;
        CareProgramEnrollee cPERec = TestFactory.createCareProgramEnrollee('TEST', patientAcc.Id, carePrgmRec.Id);
        test.startTest();
        insert cPERec;
        test.stopTest();
        UnitOfMeasure UOMRec = TestFactory.createUnitOfMeasure();
        insert UOMRec;        
        Id recordTypeCaseEDRD = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('EDRD').getRecordTypeId();
        List<Case> batchCaseFYList = TestFactory.createEDRDCase(1, recordTypeCaseEDRD, prvderAcc.Id);
        batchCaseFYList.get(0).Type = 'New';
        batchCaseFYList.get(0).EDRD_MOHFunding_Decision__c = 'Approved';
        batchCaseFYList.get(0).EDRD_MOHApproved_Dosage__c = 300;
        batchCaseFYList.get(0).EDRD_MOHApproved_Dosage_Unit__c = UOMRec.Id;
        batchCaseFYList.get(0).EDRD_MOHApproved_Frequency__c = 1;
        batchCaseFYList.get(0).EDRD_MOHApproved_Frequency_Unit__c = 'Once';
        batchCaseFYList.get(0).EDRD_MOHApproved_Funding_Duration__c = 1;
        batchCaseFYList.get(0).EDRD_MOHApproved_Funding_Duration_Unit__c = 'Once';
        batchCaseFYList.get(0).EDRD_MOHFunding_Start_Date__c = Date.newInstance(System.Today().Year()-10, 1, 1);
        batchCaseFYList.get(0).EDRD_MOHIndefinite_Funding__c = true;
        insert batchCaseFYList;
        List<Medication> MedicList = TestFactory.createMedication(1, 'Test Medication');
        insert MedicList;
        List<MedicinalIngredient> MedIList = TestFactory.createMedicinalIngredient(1, MedicList.get(0).Id, UOMRec.Id);
        Id recordTypeEDRDMI = Schema.SObjectType.MedicinalIngredient.getRecordTypeInfosByDeveloperName().get('EDRD_Medicinal_Ingredient').getRecordTypeId();
        MedIList.get(0).RecordtypeId = recordTypeEDRDMI;
        insert MedIList;
        Id recordTypeMREDRD = Schema.SObjectType.MedicationRequest.getRecordTypeInfosByDeveloperName().get('EDRD_Medication_Request').getRecordTypeId();
        List<MedicationRequest> batchMRList = TestFactory.createMedicationRequest(1, MedicList.get(0).Id, batchCaseFYList.get(0).Id, prvderAcc.Id, patientAcc.Id); 
        batchMRList.get(0).Dosage__c = 300;
        batchMRList.get(0).Dosage_Units__c = UOMRec.Id;
        batchMRList.get(0).Requested_Frequency__c = 1;
        batchMRList.get(0).Requested_Frequency_Unit__c = 'Once';
        batchMRList.get(0).Requested_Funding_Duration__c = 1;
        batchMRList.get(0).Requested_Funding_Duration_Unit__c = 'Once';
        batchMRList.get(0).Medication_Information__c = MedIList.get(0).Id;
        batchMRList.get(0).recordTypeId = recordTypeMREDRD;
        insert batchMRList;
    }
    
/**
* @author: Deepak
* @date: 25 Aug 2024
* @description: The purpose of this method is to cover Testcoverage of generateForecastRecords
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/    
    @isTest
    public static void EDRD_cls_IndefiniteBatchExecute_Test(){
        
        List<Case> batchCaseList = [SELECT Id, Contact.AccountId, Medication_Name__c FROM Case 
                                    WHERE EDRD_MOHFunding_Decision__c = 'Approved' LIMIT 1];
        
        batchCaseList.get(0).Status = 'Funding Approved';
        update batchCaseList;
        
        Test.startTest();
        EDRD_cls_IndefiniteBatch iBObj = new EDRD_cls_IndefiniteBatch();
        iBObj.execute(NULL);
        Test.stopTest();
        
        List<MedicationDispense> forecastRecords = [SELECT Id, PatientId, Medication.Name, EDRD_END_Date__c FROM MedicationDispense WHERE Case__c =: batchCaseList[0].Id ORDER BY EDRD_END_Date__c DESC];
        Assert.areEqual(batchCaseList.get(0).Contact.AccountId, forecastRecords[0].PatientId, 'PatientId should match the case Contact\'s AccountId.');
        Assert.areEqual(batchCaseList.get(0).Medication_Name__c, forecastRecords[0].Medication.Name, 'Medication should match the case medication.');
        Assert.areNotEqual(0, forecastRecords.size(), 'Forecast records should be created');
    }

}