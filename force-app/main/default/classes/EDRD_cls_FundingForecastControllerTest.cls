/**********************************************************************************************
* @Author:      Deepak 
* @Date:        29 Jul 2024
* @Description: The purpose of this class is to cover Code coverage of EDRD_cls_FundingForecastController.
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]  
***********************************************************************************************/
@isTest
public class EDRD_cls_FundingForecastControllerTest {
    
    @TestSetUp
    public static void createTestData() {
        Account providerAccount = TestFactory.newProvider('Provider Test');
        insert providerAccount;
        Account patntAccount = TestFactory.newPatient('Patient Test');
        insert patntAccount;
        UnitOfMeasure UOMRec = TestFactory.createUnitOfMeasure();
        insert UOMRec;        
        Id recordTypeCaseEDRD = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('EDRD').getRecordTypeId();
        List<Case> caseList = TestFactory.createEDRDCase(1, recordTypeCaseEDRD, providerAccount.Id);
        caseList.get(0).Type = 'New';
        caseList.get(0).EDRD_MOHFunding_Decision__c = 'Approved';
        caseList.get(0).EDRD_MOHApproved_Dosage__c = 300;
        caseList.get(0).EDRD_MOHApproved_Dosage_Unit__c = UOMRec.Id;
        caseList.get(0).EDRD_MOHApproved_Frequency__c = 1;
        caseList.get(0).EDRD_MOHApproved_Frequency_Unit__c = 'Once';
        caseList.get(0).EDRD_MOHApproved_Funding_Duration__c = 1;
        caseList.get(0).EDRD_MOHApproved_Funding_Duration_Unit__c = 'Once';
        CaseList.get(0).EDRD_MOHFunding_Start_Date__c = Date.newInstance(2024, 1, 1);
        insert caseList;
        List<Medication> drugList = TestFactory.createMedication(1, 'Test Medication');
        insert drugList;
        List<MedicinalIngredient> MIList = TestFactory.createMedicinalIngredient(1, drugList.get(0).Id, UOMRec.Id);
        Id recordTypeEDRDMI = Schema.SObjectType.MedicinalIngredient.getRecordTypeInfosByDeveloperName().get('EDRD_Medicinal_Ingredient').getRecordTypeId();
        MIList.get(0).RecordtypeId = recordTypeEDRDMI;
        insert MIList;
        Id recordTypeMREDRD = Schema.SObjectType.MedicationRequest.getRecordTypeInfosByDeveloperName().get('EDRD_Medication_Request').getRecordTypeId();
        List<MedicationRequest> MRList = TestFactory.createMedicationRequest(1, drugList.get(0).Id, caseList.get(0).Id, providerAccount.Id, patntAccount.Id); 
        MRList.get(0).Dosage__c = 300;
        MRList.get(0).Dosage_Units__c = UOMRec.Id;
        MRList.get(0).Requested_Frequency__c = 1;
        MRList.get(0).Requested_Frequency_Unit__c = 'Once';
        MRList.get(0).Requested_Funding_Duration__c = 1;
        MRList.get(0).Requested_Funding_Duration_Unit__c = 'Once';
        MRList.get(0).Medication_Information__c = MIList.get(0).Id;
        MRList.get(0).recordTypeId = recordTypeMREDRD;
        insert MRList;
    }
    
/**
* @author: Deepak
* @date: 22 Aug 2024
* @description: The purpose of this method is to cover Testcoverage of generateForecastRecords
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/    
    @isTest
    public static void generateForecastRecords_OncesTest(){
        
        List<Case> caseList = [SELECT Id, Contact.AccountId, Medication_Name__c FROM Case 
                               WHERE EDRD_MOHFunding_Decision__c = 'Approved' LIMIT 1];
        
        Test.startTest();
        CaseList.get(0).EDRD_MOHFunding_Expiry_Date__c = Date.newInstance(2024, 1, 1);
        caseList.get(0).Status = 'Funding Approved';
        update caseList;
        Test.stopTest();
        
        List<MedicationDispense> forecastRecords = [SELECT Id, PatientId, Medication.Name FROM MedicationDispense WHERE Case__c =: caseList[0].Id];
        Assert.areEqual(1, forecastRecords.size(), 'FY-MedicationDispense records should be created');
        Assert.areEqual(caseList.get(0).Contact.AccountId, forecastRecords[0].PatientId, 'PatientId should match the case Contact\'s AccountId.');
        Assert.areEqual(caseList.get(0).Medication_Name__c, forecastRecords[0].Medication.Name, 'Medication should match the case medication.');
        Assert.areNotEqual(0, forecastRecords.size(), 'Forecast records should be created');
    }
    
    @isTest
    public static void generateForecastRecords_DaysTest(){
        
        List<Case> caseList = [SELECT Id, Contact.AccountId, Medication_Name__c FROM Case 
                               WHERE EDRD_MOHFunding_Decision__c = 'Approved' LIMIT 1];
        
        Test.startTest();
        caseList.get(0).EDRD_MOHApproved_Frequency__c = 1;
        caseList.get(0).EDRD_MOHApproved_Frequency_Unit__c = 'Daily';
        caseList.get(0).EDRD_MOHApproved_Funding_Duration__c = 30;
        caseList.get(0).EDRD_MOHApproved_Funding_Duration_Unit__c = 'Days';
        caseList.get(0).Status = 'Funding Approved';
        update caseList;
        Test.stopTest();
        
        List<MedicationDispense> forecastRecords = [SELECT Id, PatientId, Medication.Name FROM MedicationDispense WHERE Case__c =: caseList[0].Id];
        Assert.areEqual(1, forecastRecords.size(), 'FY-MedicationDispense records should be created');
        Assert.areEqual(caseList.get(0).Contact.AccountId, forecastRecords[0].PatientId, 'PatientId should match the case Contact\'s AccountId.');
        Assert.areEqual(caseList.get(0).Medication_Name__c, forecastRecords[0].Medication.Name, 'Medication should match the case medication.');
        Assert.areNotEqual(0, forecastRecords.size(), 'Forecast records should be created');
    }
    
    @isTest
    public static void generateForecastRecords_WeeksTest(){
        
        List<Case> caseList = [SELECT Id, Contact.AccountId, Medication_Name__c FROM Case
                               WHERE EDRD_MOHFunding_Decision__c = 'Approved' LIMIT 1];
        
        Test.startTest();
        caseList.get(0).EDRD_MOHApproved_Frequency__c = 1;
        caseList.get(0).EDRD_MOHApproved_Frequency_Unit__c = 'Weekly';
        caseList.get(0).EDRD_MOHApproved_Funding_Duration__c = 52;
        caseList.get(0).EDRD_MOHApproved_Funding_Duration_Unit__c = 'Weeks';
        caseList.get(0).Status = 'Funding Approved';
        update caseList;
        Test.stopTest();
        
        List<MedicationDispense> forecastRecords = [SELECT Id, PatientId, Medication.Name FROM MedicationDispense WHERE Case__c =: caseList[0].Id];
        Assert.areEqual(2, forecastRecords.size(), 'FY-MedicationDispense records should be created');
        Assert.areEqual(caseList.get(0).Contact.AccountId, forecastRecords[0].PatientId, 'PatientId should match the case Contact\'s AccountId.');
        Assert.areEqual(caseList.get(0).Medication_Name__c, forecastRecords[0].Medication.Name, 'Medication should match the case medication.');
        Assert.areNotEqual(0, forecastRecords.size(), 'Forecast records should be created');
    }
    
    @isTest
    public static void generateForecastRecords_BiWeeksTest(){
        
        List<Case> caseList = [SELECT Id, Contact.AccountId, Medication_Name__c FROM Case
                               WHERE EDRD_MOHFunding_Decision__c = 'Approved' LIMIT 1];
        
        Test.startTest();
        caseList.get(0).EDRD_MOHApproved_Frequency__c = 0.5;
        caseList.get(0).EDRD_MOHApproved_Frequency_Unit__c = 'Weekly';
        caseList.get(0).EDRD_MOHApproved_Funding_Duration__c = 52;
        caseList.get(0).EDRD_MOHApproved_Funding_Duration_Unit__c = 'Weeks';
        caseList.get(0).Status = 'Funding Approved';
        update caseList;
        Test.stopTest();
        
        List<MedicationDispense> forecastRecords = [SELECT Id, PatientId, Medication.Name FROM MedicationDispense WHERE Case__c =: caseList[0].Id];
        Assert.areEqual(2, forecastRecords.size(), 'FY-MedicationDispense records should be created');
        Assert.areEqual(caseList.get(0).Contact.AccountId, forecastRecords[0].PatientId, 'PatientId should match the case Contact\'s AccountId.');
        Assert.areEqual(caseList.get(0).Medication_Name__c, forecastRecords[0].Medication.Name, 'Medication should match the case medication.');
        Assert.areNotEqual(0, forecastRecords.size(), 'Forecast records should be created');
    }
    
    @isTest
    public static void generateForecastRecords_MonthsTest(){
        
        List<Case> caseList = [SELECT Id, Contact.AccountId, Medication_Name__c FROM Case
                               WHERE EDRD_MOHFunding_Decision__c = 'Approved' LIMIT 1];
        
        Test.startTest();
        caseList.get(0).EDRD_MOHApproved_Frequency__c = 1;
        caseList.get(0).EDRD_MOHApproved_Frequency_Unit__c = 'Monthly';
        caseList.get(0).EDRD_MOHApproved_Funding_Duration__c = 24;
        caseList.get(0).EDRD_MOHApproved_Funding_Duration_Unit__c = 'Months';
        caseList.get(0).Status = 'Funding Approved';
        update caseList;
        Test.stopTest();
        
        List<MedicationDispense> forecastRecords = [SELECT Id, PatientId, Medication.Name FROM MedicationDispense WHERE Case__c =: caseList[0].Id];
        Assert.areEqual(3, forecastRecords.size(), 'FY-MedicationDispense records should be created');
        Assert.areEqual(caseList.get(0).Contact.AccountId, forecastRecords[0].PatientId, 'PatientId should match the case Contact\'s AccountId.');
        Assert.areEqual(caseList.get(0).Medication_Name__c, forecastRecords[0].Medication.Name, 'Medication should match the case medication.');
        Assert.areNotEqual(0, forecastRecords.size(), 'Forecast records should be created');
    }
    
    @isTest
    public static void generateForecastRecords_YearsTest(){
        
        List<Case> caseList = [SELECT Id, Contact.AccountId, Medication_Name__c FROM Case
                               WHERE EDRD_MOHFunding_Decision__c = 'Approved' LIMIT 1];
        
        Test.startTest();
        caseList.get(0).EDRD_MOHApproved_Frequency__c = 1;
        caseList.get(0).EDRD_MOHApproved_Frequency_Unit__c = 'Yearly';
        caseList.get(0).EDRD_MOHApproved_Funding_Duration__c = 3;
        caseList.get(0).EDRD_MOHApproved_Funding_Duration_Unit__c = 'Years';
        caseList.get(0).Status = 'Funding Approved';
        update caseList;
        Test.stopTest();
        
        List<MedicationDispense> forecastRecords = [SELECT Id, PatientId, Medication.Name FROM MedicationDispense WHERE Case__c =: caseList[0].Id];
        Assert.areEqual(4, forecastRecords.size(), 'FY-MedicationDispense records should be created');
        Assert.areEqual(caseList.get(0).Contact.AccountId, forecastRecords[0].PatientId, 'PatientId should match the case Contact\'s AccountId.');
        Assert.areEqual(caseList.get(0).Medication_Name__c, forecastRecords[0].Medication.Name, 'Medication should match the case medication.');
        Assert.areNotEqual(0, forecastRecords.size(), 'Forecast records should be created');
    }
}