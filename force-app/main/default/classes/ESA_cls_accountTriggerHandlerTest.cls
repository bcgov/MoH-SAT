/**********************************************************************************************
* @Author:      Deepak 
* @Date:        09 Mar 2023
* @Description: The purpose of this class is to cover Code coverage of ESA_cls_accountTriggerHandler
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
                11 Nov -  EDRD-82           -  Accenture   -  Added Close Case method on Account Inactive
***********************************************************************************************/

@isTest
public class ESA_cls_accountTriggerHandlerTest {
    
/**
* @author: Deepak
* @date: 09 Mar 2023
* @description: The purpose of this method is to cover Testcoverage of populateSpecialty
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/  
    
    @isTest
    public static void populateSpecialty_positive(){
        Account providerAccount = TestFactory.newProvider('Test');
        providerAccount.Provider_Specialty__pc = 'Anesthesiology';
        Test.startTest();
        insert providerAccount;
        List<Contact> conList =[Select Id, account.Provider_Specialty__pc, Provider_Specialty__c from Contact Where accountID =:providerAccount.id];
        Assert.areEqual(conList.get(0).Provider_Specialty__c, conList.get(0).account.Provider_Specialty__pc,'Speciality does not matches');
        providerAccount.Provider_Specialty__pc = 'Bacteriology';
        Update providerAccount;
        Test.stopTest();
        conList =[Select Id, account.Provider_Specialty__pc, Provider_Specialty__c from Contact Where accountID =:providerAccount.id];
        Assert.areEqual(conList.get(0).Provider_Specialty__c, conList.get(0).account.Provider_Specialty__pc,'Speciality does not matches');
    }

/**
* @author: Deepak
* @date: 14 Nov 2023
* @description: The purpose of this method is to cover Testcoverage of closeCaseOnAccInactive
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/    
    @isTest
    public static void closeCaseOnAccDeceased_positive(){
        Account patientAccount = TestFactory.newPatient('Test');
        insert patientAccount;
        Account providerAccount = TestFactory.newProvider('Provider Test');
        insert providerAccount;
        UnitOfMeasure UOMRec = TestFactory.createUnitOfMeasure();
        insert UOMRec;
        String caseRecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('EDRD').getRecordTypeId();
        List<Case> EDRDCaseList = TestFactory.createEDRDCase(3, caseRecordTypeID, patientAccount.Id);
        EDRDCaseList.get(0).Type = 'New';
        EDRDCaseList.get(1).Type = 'New';
        EDRDCaseList.get(1).EDRD_MOHFunding_Decision__c = 'Approved';
        EDRDCaseList.get(1).EDRD_MOHApproved_Dosage__c = 300;
        EDRDCaseList.get(1).EDRD_MOHApproved_Dosage_Unit__c = UOMRec.Id;
        EDRDCaseList.get(1).EDRD_MOHApproved_Frequency__c = 1;
        EDRDCaseList.get(1).EDRD_MOHApproved_Frequency_Unit__c = 'Monthly';
        EDRDCaseList.get(1).EDRD_MOHApproved_Funding_Duration__c = 6;
        EDRDCaseList.get(1).EDRD_MOHApproved_Funding_Duration_Unit__c = 'Months';
        EDRDCaseList.get(1).EDRD_MOHFunding_Start_Date__c = System.Today();
        EDRDCaseList.get(1).EDRD_MOHFunding_Expiry_Date__c = System.Today().addMonths(6);
		EDRDCaseList.get(1).Status = 'Funding Approved';
        EDRDCaseList.get(2).Type = 'New';
        EDRDCaseList.get(2).EDRD_MOHFunding_Decision__c = 'Extended';
        EDRDCaseList.get(2).EDRD_MOHApproved_Dosage__c = 300;
        EDRDCaseList.get(2).EDRD_MOHApproved_Dosage_Unit__c = UOMRec.Id;
        EDRDCaseList.get(2).EDRD_MOHApproved_Frequency__c = 1;
        EDRDCaseList.get(2).EDRD_MOHApproved_Frequency_Unit__c = 'Monthly';
        EDRDCaseList.get(2).EDRD_MOHApproved_Funding_Duration__c = 6;
        EDRDCaseList.get(2).EDRD_MOHApproved_Funding_Duration_Unit__c = 'Months';
        EDRDCaseList.get(2).EDRD_MOHFunding_Start_Date__c = System.Today();
        EDRDCaseList.get(2).EDRD_MOHFunding_Expiry_Date__c = System.Today().addMonths(6);
		EDRDCaseList.get(2).Status = 'Funding Approved';
        insert EDRDCaseList;
        careProgram careProgramRec = TestFactory.createCareProgram('EDRD');
        insert careProgramRec;
        CareProgramEnrollee CareProgramEnrolleeRec = TestFactory.createCareProgramEnrollee('TEST', patientAccount.Id, careProgramRec.Id);
        insert CareProgramEnrolleeRec;
        Test.startTest();
        patientAccount.Patient_is_Deceased__pc = true;
        Update patientAccount;
        Test.stopTest(); 
        
        List<Case> caseList = [SELECT Id, EDRD_MOHFunding_Expiry_Date__c FROM Case WHERE Id =: EDRDCaseList.get(1).Id];
        Assert.areEqual([SELECT Id FROM Case WHERE isClosed = false].isEmpty(), True, 'Cases are not closed');
        Assert.areNotEqual([SELECT Id FROM Case WHERE isClosed = true].isEmpty(), True, 'Cases are not closed');
        Assert.areEqual(caseList.get(0).EDRD_MOHFunding_Expiry_Date__c, System.Today(), 'Date should be Today');
        Assert.areNotEqual(caseList.get(0).EDRD_MOHFunding_Expiry_Date__c, NULL, 'Date cannot be Null');
    }
}