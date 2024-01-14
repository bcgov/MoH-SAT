/**********************************************************************************************
* @Author:      Deepak 
* @Date:        23/02/2023
* @Description: The purpose of this class is to cover Code coverage of ESA_cls_caseTriggerHandler
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]  
                1 Dec23 -   EDRD-170        -   Rahul      -  Manage case assignment
                4 Dec23 -   EDRD-332        -  Accenture   -  Change case status according to RPH, SC, AC Review Field
               16 Dec23 -   EDRD-282         -  Accenture   -  Sync MR Fields values to Case Fields values
***********************************************************************************************/

@isTest
public class ESA_cls_caseTriggerHandlerTest {
    
/**
* @author: Deepak
* @date: 23 Feb 2023
* @description: The purpose of this method is to cover Testcoverage of populateTerminationDate
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/  
    
    @isTest
    public static void populateTerminationDate_positive(){
        
        List<Case> allCases = new List<Case>();     
        for(integer i=0; i<5; i++){
            Case c = new case();
            c.Termination_date__c = NULL;
            c.ESA_Approval_Time_Unit__c = ESA_cls_constants.CASE_APPROVAL_TIME_UNIT_WEEK;
            c.ESA_Approval_Time__c = 7;    
            allCases.add(c);
        }
        insert allCases;
        List<case> caseLst = [select id, termination_date__c from Case where id =: allCases[0].id]; 
        system.assertEquals(caseLst[0].termination_date__c, system.Today().addDays((7*7)+1));
        for(case c:allCases){
            c.ESA_Approval_Time_Unit__c = ESA_cls_constants.CASE_APPROVAL_TIME_UNIT_DAYS;
            c.ESA_Approval_Time__c = 7;    
        }
        Update allCases;
        caseLst = [select id, termination_date__c from Case where id =: allCases[0].id]; 
        system.assertEquals(caseLst[0].termination_date__c, system.Today().addDays(7+1));
        for(case c:allCases){
            c.ESA_Approval_Time_Unit__c = NULL;
            c.ESA_Approval_Time__c = NULL;    
        }
        Update allCases;
        caseLst = [select id, termination_date__c from Case where id =: allCases[0].id]; 
        system.assertEquals(caseLst[0].termination_date__c, NULL);
    }
    /**
* @author: Rahul
* @date: 04 Dec 2023
* @description: The purpose of this method is to cover Testcoverage of manageAssignmentRule
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/ 
    @isTest public static void manageAssignmentRuleTest(){
        Id caseRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('EDRD').getRecordTypeId();
        Case testCase = new Case(
            Subject = 'Test Case',
            Description ='Test');
        testCase.RecordTypeId = caseRecType;
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule = true;
        testCase.setOptions(dmo);
        insert testCase;
        Test.startTest();
        testCase.subject ='Test Case 1';
        update testCase;
        Test.stopTest();
        Case caCheck = [ SELECT Id,Owner.Name, OwnerId FROM Case WHERE Id =: testCase.Id ];
        Assert.areNotEqual(Userinfo.getUserId(), caCheck.OwnerId, 'Should be not be the user');
        Assert.areEqual('00G',String.valueOf(caCheck.OwnerId).substring(0,3));
    }
/**
* @author: Deepak
* @date: 04 Dec 2023
* @description: The purpose of this method is to cover Testcoverage of assignStatus
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/      
   @isTest
    public static void assignStatusTest(){
        List<Case> allCases = new List<Case>();  
        for(integer i=0; i<3; i++){
            Case caseObj = new case();
            caseObj.EDRD_RPH_Review_Pathway__c = '';
            caseObj.EDRD_SC_Review_Pathway__c = '';
            caseObj.EDRD_AC_Review_Pathway__c = '';
            allCases.add(caseObj);
        }
        insert allCases;        
        allCases[0].EDRD_RPH_Review_Pathway__c = 'Sent to SC';
        allCases[1].EDRD_SC_Review_Pathway__c = 'Sent to AC';
        allCases[2].EDRD_AC_Review_Pathway__c = 'Sent to MOH';
        Test.startTest();
        Update allCases;
        Test.stopTest();
        Assert.areEqual([SELECT Id, Status FROM Case WHERE Id =: allCases[0].id].Status, 'SC Review', 'Status has not updated as SC Review');
        Assert.areNotEqual([SELECT Id, Status FROM Case WHERE Id =: allCases[0].id].Status, NULL, 'Status has been updated as Null');
        Assert.areEqual([SELECT Id, Status FROM Case WHERE Id =: allCases[1].id].Status, 'AC Review', 'Status has not updated as AC Review');
        Assert.areNotEqual([SELECT Id, Status FROM Case WHERE Id =: allCases[1].id].Status, NULL, 'Status has been updated as Null');
        Assert.areEqual([SELECT Id, Status FROM Case WHERE Id =: allCases[2].id].Status, 'MOH Review', 'Status has not updated as MOH Review');
        Assert.areNotEqual([SELECT Id, Status FROM Case WHERE Id =: allCases[2].id].Status, NULL, 'Status has been updated as Null');
    }
    
/**
* @author: Deepak
* @date: 15 Dec 2023
* @description: The purpose of this method is to cover Testcoverage of syncCaseToMR
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/    
    @isTest
    public static void syncCaseToMR_positive(){
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
            MRCase.Status = 'Funding Approved';
            MRCase.Type = 'Renewal';
            MRCase.Priority = 'Routine';
            ESA_cls_caseTriggerHandler.firstrun = true;
            Update MRcase;
            Test.stopTest();
        } 
        catch(exception e){
            MedicationRequest MRRec =[SELECT Id, Status, Type, Priority, Case__c, Case__r.Status, Case__r.priority, Case__r.Type
                                      FROM MedicationRequest WHERE Id =: MedicationRequestRec.id];
            Assert.areEqual(MRRec.Status, MRRec.Case__r.Status, 'Status did not Match');
            Assert.areEqual(MRRec.Type, MRRec.Case__r.Type, 'Type did not Match');
            Assert.areEqual(MRRec.priority, MRRec.Case__r.priority, 'priority did not Match');
            Assert.areNotEqual(MRRec.Status, NULL, 'Status did not Match');
            Assert.areNotEqual(MRRec.Type, NULL, 'Type did not Match');
            Assert.areNotEqual(MRRec.priority, NULL, 'priority did not Match');
        }
    }
    @isTest
    public static void populateFundingExpiryDateTest(){
        Id recordTypeCaseEDRD = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('EDRD').getRecordTypeId();
        Case cs = TestFactory.createCaseEDRD(recordTypeCaseEDRD);
        insert cs;
        cs.EDRD_MOHApproved_Funding_Duration__c = 11.0;
        cs.EDRD_MOHApproved_Funding_Duration_Unit__c = 'Days';
        cs.EDRD_MOHFunding_Start_Date__c = system.today();
        test.startTest();
        update cs;
        test.stopTest();
        
    }
    
/**
* @author: Deepak
* @date: 14 Jan 2024
* @description: The purpose of this method is to cover Testcoverage of calDrugForecast
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/    
    @isTest
    public static void calDrugForecast_positive(){
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
        MRCase.EDRD_MOHApproved_Funding_Duration_Unit__c = 'Years';
        Update MRcase;
        Test.stopTest();
        Assert.areEqual([SELECT Id, EDRD_MOHDrug_Cost_Forecast__c FROM Case WHERE Id =: MRCase.Id].get(0).EDRD_MOHDrug_Cost_Forecast__c, 5200, 'Calculation Failed');
        Assert.areNotEqual([SELECT Id, EDRD_MOHDrug_Cost_Forecast__c FROM Case WHERE Id =: MRCase.Id].get(0).EDRD_MOHDrug_Cost_Forecast__c, NULL, 'Calculation Populated Blank value');
    }
}