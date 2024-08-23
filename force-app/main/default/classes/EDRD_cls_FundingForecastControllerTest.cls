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
        Account providerAcnt = TestFactory.newProvider('Provider Test');
        insert providerAcnt;
        Account patientAcnt = TestFactory.newPatient('Patient Test');
        insert patientAcnt;
        UnitOfMeasure UOMRec = TestFactory.createUnitOfMeasure();
        insert UOMRec;        
        Id recordTypeCaseEDRD = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('EDRD').getRecordTypeId();
        List<Case> caseFYList = TestFactory.createEDRDCase(1, recordTypeCaseEDRD, providerAcnt.Id);
        caseFYList.get(0).Type = 'New';
        caseFYList.get(0).EDRD_MOHFunding_Decision__c = 'Approved';
        caseFYList.get(0).EDRD_MOHApproved_Dosage__c = 300;
        caseFYList.get(0).EDRD_MOHApproved_Dosage_Unit__c = UOMRec.Id;
        caseFYList.get(0).EDRD_MOHApproved_Frequency__c = 1;
        caseFYList.get(0).EDRD_MOHApproved_Frequency_Unit__c = 'Once';
        caseFYList.get(0).EDRD_MOHApproved_Funding_Duration__c = 1;
        caseFYList.get(0).EDRD_MOHApproved_Funding_Duration_Unit__c = 'Once';
        caseFYList.get(0).EDRD_MOHFunding_Start_Date__c = Date.newInstance(2024, 1, 1);
        insert caseFYList;
        List<Medication> MedicationList = TestFactory.createMedication(1, 'Test Medication');
        insert MedicationList;
        List<MedicinalIngredient> MedIList = TestFactory.createMedicinalIngredient(1, MedicationList.get(0).Id, UOMRec.Id);
        Id recordTypeEDRDMI = Schema.SObjectType.MedicinalIngredient.getRecordTypeInfosByDeveloperName().get('EDRD_Medicinal_Ingredient').getRecordTypeId();
        MedIList.get(0).RecordtypeId = recordTypeEDRDMI;
        insert MedIList;
        Id recordTypeMREDRD = Schema.SObjectType.MedicationRequest.getRecordTypeInfosByDeveloperName().get('EDRD_Medication_Request').getRecordTypeId();
        List<MedicationRequest> caseMRList = TestFactory.createMedicationRequest(1, MedicationList.get(0).Id, caseFYList.get(0).Id, providerAcnt.Id, patientAcnt.Id); 
        caseMRList.get(0).Dosage__c = 300;
        caseMRList.get(0).Dosage_Units__c = UOMRec.Id;
        caseMRList.get(0).Requested_Frequency__c = 1;
        caseMRList.get(0).Requested_Frequency_Unit__c = 'Once';
        caseMRList.get(0).Requested_Funding_Duration__c = 1;
        caseMRList.get(0).Requested_Funding_Duration_Unit__c = 'Once';
        caseMRList.get(0).Medication_Information__c = MedIList.get(0).Id;
        caseMRList.get(0).recordTypeId = recordTypeMREDRD;
        insert caseMRList;
    }
    
/**
* @author: Deepak
* @date: 22 Aug 2024
* @description: The purpose of this method is to cover Testcoverage of generateForecastRecords
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/    
    @isTest
    public static void generateForecastRecords_OncesTest(){
        
        List<Case> caseFYList_Once = [SELECT Id, Contact.AccountId, Medication_Name__c FROM Case 
                               WHERE EDRD_MOHFunding_Decision__c = 'Approved' LIMIT 1];
        
        Test.startTest();
        caseFYList_Once.get(0).EDRD_MOHFunding_Expiry_Date__c = Date.newInstance(2024, 1, 1);
        caseFYList_Once.get(0).Status = 'Funding Approved';
        update caseFYList_Once;
        Test.stopTest();
        
        List<MedicationDispense> forecastRecords = [SELECT Id, PatientId, Medication.Name FROM MedicationDispense WHERE Case__c =: caseFYList_Once[0].Id];
        Assert.areEqual(1, forecastRecords.size(), 'FY-MedicationDispense records should be created');
        Assert.areEqual(caseFYList_Once.get(0).Contact.AccountId, forecastRecords[0].PatientId, 'PatientId should match the case Contact\'s AccountId.');
        Assert.areEqual(caseFYList_Once.get(0).Medication_Name__c, forecastRecords[0].Medication.Name, 'Medication should match the case medication.');
        Assert.areNotEqual(0, forecastRecords.size(), 'Forecast records should be created');
    }
    
    @isTest
    public static void generateForecastRecords_DaysTest(){
        
        List<Case> caseFYList_days = [SELECT Id, Contact.AccountId, Medication_Name__c FROM Case 
                               WHERE EDRD_MOHFunding_Decision__c = 'Approved' LIMIT 1];
        
        Test.startTest();
        caseFYList_days.get(0).EDRD_MOHApproved_Frequency__c = 1;
        caseFYList_days.get(0).EDRD_MOHApproved_Frequency_Unit__c = 'Daily';
        caseFYList_days.get(0).EDRD_MOHApproved_Funding_Duration__c = 30;
        caseFYList_days.get(0).EDRD_MOHApproved_Funding_Duration_Unit__c = 'Days';
        caseFYList_days.get(0).Status = 'Funding Approved';
        update caseFYList_days;
        Test.stopTest();
        
        List<MedicationDispense> forecastRecords = [SELECT Id, PatientId, Medication.Name FROM MedicationDispense WHERE Case__c =: caseFYList_days[0].Id];
        Assert.areEqual(1, forecastRecords.size(), 'FY-MedicationDispense records should be created');
        Assert.areEqual(caseFYList_days.get(0).Contact.AccountId, forecastRecords[0].PatientId, 'PatientId should match the case Contact\'s AccountId.');
        Assert.areEqual(caseFYList_days.get(0).Medication_Name__c, forecastRecords[0].Medication.Name, 'Medication should match the case medication.');
        Assert.areNotEqual(0, forecastRecords.size(), 'Forecast records should be created');
    }
    
    @isTest
    public static void generateForecastRecords_WeeksTest(){
        
        List<Case> caseFYList_Weeks = [SELECT Id, Contact.AccountId, Medication_Name__c FROM Case
                               WHERE EDRD_MOHFunding_Decision__c = 'Approved' LIMIT 1];
        
        Test.startTest();
        caseFYList_Weeks.get(0).EDRD_MOHApproved_Frequency__c = 1;
        caseFYList_Weeks.get(0).EDRD_MOHApproved_Frequency_Unit__c = 'Weekly';
        caseFYList_Weeks.get(0).EDRD_MOHApproved_Funding_Duration__c = 52;
        caseFYList_Weeks.get(0).EDRD_MOHApproved_Funding_Duration_Unit__c = 'Weeks';
        caseFYList_Weeks.get(0).Status = 'Funding Approved';
        update caseFYList_Weeks;
        Test.stopTest();
        
        List<MedicationDispense> forecastRecords = [SELECT Id, PatientId, Medication.Name FROM MedicationDispense WHERE Case__c =: caseFYList_Weeks[0].Id];
        Assert.areEqual(2, forecastRecords.size(), 'FY-MedicationDispense records should be created');
        Assert.areEqual(caseFYList_Weeks.get(0).Contact.AccountId, forecastRecords[0].PatientId, 'PatientId should match the case Contact\'s AccountId.');
        Assert.areEqual(caseFYList_Weeks.get(0).Medication_Name__c, forecastRecords[0].Medication.Name, 'Medication should match the case medication.');
        Assert.areNotEqual(0, forecastRecords.size(), 'Forecast records should be created');
    }
    
    @isTest
    public static void generateForecastRecords_BiWeeksTest(){
        
        List<Case> caseList_BiWeeks = [SELECT Id, Contact.AccountId, Medication_Name__c FROM Case
                               WHERE EDRD_MOHFunding_Decision__c = 'Approved' LIMIT 1];
        
        Test.startTest();
        caseList_BiWeeks.get(0).EDRD_MOHApproved_Frequency__c = 0.5;
        caseList_BiWeeks.get(0).EDRD_MOHApproved_Frequency_Unit__c = 'Weekly';
        caseList_BiWeeks.get(0).EDRD_MOHApproved_Funding_Duration__c = 52;
        caseList_BiWeeks.get(0).EDRD_MOHApproved_Funding_Duration_Unit__c = 'Weeks';
        caseList_BiWeeks.get(0).Status = 'Funding Approved';
        update caseList_BiWeeks;
        Test.stopTest();
        
        List<MedicationDispense> forecastRecords = [SELECT Id, PatientId, Medication.Name FROM MedicationDispense WHERE Case__c =: caseList_BiWeeks[0].Id];
        Assert.areEqual(2, forecastRecords.size(), 'FY-MedicationDispense records should be created');
        Assert.areEqual(caseList_BiWeeks.get(0).Contact.AccountId, forecastRecords[0].PatientId, 'PatientId should match the case Contact\'s AccountId.');
        Assert.areEqual(caseList_BiWeeks.get(0).Medication_Name__c, forecastRecords[0].Medication.Name, 'Medication should match the case medication.');
        Assert.areNotEqual(0, forecastRecords.size(), 'Forecast records should be created');
    }
    
    @isTest
    public static void generateForecastRecords_MonthsTest(){
        
        List<Case> caseFYList_Months = [SELECT Id, Contact.AccountId, Medication_Name__c FROM Case
                               WHERE EDRD_MOHFunding_Decision__c = 'Approved' LIMIT 1];
        
        Test.startTest();
        caseFYList_Months.get(0).EDRD_MOHApproved_Frequency__c = 1;
        caseFYList_Months.get(0).EDRD_MOHApproved_Frequency_Unit__c = 'Monthly';
        caseFYList_Months.get(0).EDRD_MOHApproved_Funding_Duration__c = 24;
        caseFYList_Months.get(0).EDRD_MOHApproved_Funding_Duration_Unit__c = 'Months';
        caseFYList_Months.get(0).Status = 'Funding Approved';
        update caseFYList_Months;
        Test.stopTest();
        
        List<MedicationDispense> forecastRecords = [SELECT Id, PatientId, Medication.Name FROM MedicationDispense WHERE Case__c =: caseFYList_Months[0].Id];
        Assert.areEqual(3, forecastRecords.size(), 'FY-MedicationDispense records should be created');
        Assert.areEqual(caseFYList_Months.get(0).Contact.AccountId, forecastRecords[0].PatientId, 'PatientId should match the case Contact\'s AccountId.');
        Assert.areEqual(caseFYList_Months.get(0).Medication_Name__c, forecastRecords[0].Medication.Name, 'Medication should match the case medication.');
        Assert.areNotEqual(0, forecastRecords.size(), 'Forecast records should be created');
    }
    
    @isTest
    public static void generateForecastRecords_YearsTest(){
        
        List<Case> caseList_Year = [SELECT Id, Contact.AccountId, Medication_Name__c FROM Case
                               WHERE EDRD_MOHFunding_Decision__c = 'Approved' LIMIT 1];
        
        Test.startTest();
        caseList_Year.get(0).EDRD_MOHApproved_Frequency__c = 1;
        caseList_Year.get(0).EDRD_MOHApproved_Frequency_Unit__c = 'Yearly';
        caseList_Year.get(0).EDRD_MOHApproved_Funding_Duration__c = 3;
        caseList_Year.get(0).EDRD_MOHApproved_Funding_Duration_Unit__c = 'Years';
        caseList_Year.get(0).Status = 'Funding Approved';
        update caseList_Year;
        Test.stopTest();
        
        List<MedicationDispense> forecastRecords = [SELECT Id, PatientId, Medication.Name FROM MedicationDispense WHERE Case__c =: caseList_Year[0].Id];
        Assert.areEqual(4, forecastRecords.size(), 'FY-MedicationDispense records should be created');
        Assert.areEqual(caseList_Year.get(0).Contact.AccountId, forecastRecords[0].PatientId, 'PatientId should match the case Contact\'s AccountId.');
        Assert.areEqual(caseList_Year.get(0).Medication_Name__c, forecastRecords[0].Medication.Name, 'Medication should match the case medication.');
        Assert.areNotEqual(0, forecastRecords.size(), 'Forecast records should be created');
    }
}