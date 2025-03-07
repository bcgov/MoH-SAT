/**********************************************************************************************
* @Author:      Deepak 
* @Date:        23/02/2023
* @Description: The purpose of this class is to cover Code coverage of ESA_cls_caseTriggerHandler
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]  
                1 Dec23 -   EDRD-170        -   Rahul      -  Manage case assignment
                4 Dec23 -   EDRD-332        -  Accenture   -  Change case status according to RPH, SC, AC Review Field
               16 Dec23 -   EDRD-282        -  Accenture   -  Sync MR Fields values to Case Fields values
                09 Jan -    EDRD-139        -  Accenture   -  calculate DrugForecast on Case
                15 Jan -    EDRD-525        -  Accenture   -  Update AC Recommendation Review
                19 Jan-     EDRD-338        -  Accenture   -  Update Funding Expiry Date
                20 Jun-     EDRD-764        -  Accenture   -  Populate EDRD Reference number
                08 Aug-     EDRD-679        -  Accenture   -  Generate FY forecasting records
                17 Oct-     EDRD-1010		-  Accenture   -  Update Provider's - EDRD Checkbox On EDRD Case Insert
***********************************************************************************************/

@isTest
public class ESA_cls_caseTriggerHandlerTest {
    
/**
* @author: Deepak
* @date: 23 Feb 2023
* @description: The purpose of this method is to cover Testcoverage of populateTerminationDate
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/  
    
    @isTest
    public static void populateTerminationDate_positive(){
        
        List<Case> allCases = new List<Case>();
       Id saRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Special_Authority_Request').getRecordTypeId();
        for(integer i=0; i<5; i++){
            Case c = new case();
            c.Termination_date__c = NULL;
            c.ESA_Approval_Time_Unit__c = ESA_cls_constants.CASE_APPROVAL_TIME_UNIT_WEEK;
            c.ESA_Approval_Time__c = 7; 
            c.RecordTypeId = saRecordTypeId;
            allCases.add(c);
        }
        insert allCases;
        List<case> caseLst = [select id, termination_date__c from Case where id =: allCases[0].id]; 
        
        for(case c:allCases){
            c.ESA_Approval_Time_Unit__c = ESA_cls_constants.CASE_APPROVAL_TIME_UNIT_DAYS;
            c.ESA_Approval_Time__c = 7;    
        }
        Update allCases;
        caseLst = [select id, termination_date__c from Case where id =: allCases[0].id]; 
        
        for(case c:allCases){
            c.ESA_Approval_Time_Unit__c = NULL;
            c.ESA_Approval_Time__c = NULL;    
        }
        Update allCases;
        caseLst = [select id, termination_date__c from Case where id =: allCases[0].id]; 
        
    }
    /**
* @author: Rahul
* @date: 04 Dec 2023
* @description: The purpose of this method is to cover Testcoverage of manageAssignmentRule
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/ 
    @isTest (seeAllData=true) public static void manageAssignmentRuleTest(){
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
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/      
   @isTest
    public static void assignStatusTest(){
        List<Case> allCases = new List<Case>();  
        for(integer i=0; i<3; i++){
            Case caseObj = new case();
            caseObj.EDRD_RPH_Review_Pathway__c = '';
            caseObj.EDRD_SC_Review_Pathway__c = '';
            caseObj.EDRD_AC_Review_Pathway__c = '';
            caseObj.EDRD_Bypass_Eligibility_Form__c = true;
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
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/    
    @isTest
    public static void syncCaseToMR_positive(){
        Account requestorAcc = TestFactory.newProvider('Provider Test');
        insert requestorAcc;
        Account patientAcc = TestFactory.newPatient('Patient Test');
        insert patientAcc;
        Id recordTypeCaseEDRD = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('EDRD').getRecordTypeId();
        List<Case> caseMRList = TestFactory.createEDRDCase(1, recordTypeCaseEDRD, RequestorAcc.Id);
        insert caseMRList;
        List<Medication> MediRecList = TestFactory.createMedication(1, 'Test Medication');
        insert MediRecList;
        List<MedicationRequest> MedicationRequestList = TestFactory.createMedicationRequest(1, MediRecList.get(0).Id, caseMRList.get(0).Id, requestorAcc.Id, patientAcc.Id); 
        insert MedicationRequestList;
        try{
            Test.startTest();
            Case CaseList = [SELECT Id, Status, Priority, Type from Case Where id =:caseMRList.get(0).Id ];
            caseMRList.get(0).EDRD_Bypass_Eligibility_Form__c = TRUE;
            caseMRList.get(0).EDRD_MOHFunding_Decision__c = 'Approved';
            caseMRList.get(0).Status = 'MOH Review';
            caseMRList.get(0).Type = 'Renewal';
            caseMRList.get(0).Priority = 'Routine';
            caseMRList.get(0).EDRD_MOHIndefinite_Funding__c = false;
            ESA_cls_caseTriggerHandler.firstrun = false;
            Update caseMRList;
            Test.stopTest();
        } 
        catch(exception e){
            MedicationRequest MRRec =[SELECT Id, Status, Type, Priority, Case__c, Case__r.Status, Case__r.priority, Case__r.Type
                                      FROM MedicationRequest WHERE Id =: MedicationRequestList.get(0).id AND Case__c =:caseMRList.get(0).Id];
            Assert.areEqual(MRRec.Status, 'Active', 'Status did not Match');
            Assert.areEqual(MRRec.Type, MRRec.Case__r.Type, 'Type did not Match');
            Assert.areEqual(MRRec.priority, MRRec.Case__r.priority, 'priority did not Match');
            Assert.areNotEqual(MRRec.Status, NULL, 'Status did not Match');
            Assert.areNotEqual(MRRec.Type, NULL, 'Type did not Match');
            Assert.areNotEqual(MRRec.priority, NULL, 'priority did not Match');
        }
    }
    
/**
* @author: Deepak
* @date: 14 Jan 2024
* @description: The purpose of this method is to cover Testcoverage of calDrugForecast
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/    
    @isTest
    public static void calDrugForecast_positive(){
        Account reqstAccount1 = TestFactory.newProvider('Provider Test');
        insert reqstAccount1;
        Account patntAccount1 = TestFactory.newPatient('Patient Test');
        insert patntAccount1;
        UnitOfMeasure UOMRec = TestFactory.createUnitOfMeasure();
        insert UOMRec;
        Id recordTypeCaseEDRD = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('EDRD').getRecordTypeId();
        List<Case> caseMReqList = TestFactory.createEDRDCase(1, recordTypeCaseEDRD, reqstAccount1.Id);
        caseMReqList.get(0).EDRD_MOHApproved_Dosage__c = 300;
        caseMReqList.get(0).EDRD_MOHApproved_Dosage_Unit__c = UOMRec.Id;
        caseMReqList.get(0).EDRD_MOHApproved_Frequency__c = 1;
        caseMReqList.get(0).EDRD_MOHApproved_Frequency_Unit__c = 'Weekly';
        caseMReqList.get(0).EDRD_MOHApproved_Funding_Duration__c = 1;
        caseMReqList.get(0).EDRD_MOHApproved_Funding_Duration_Unit__c = 'Weeks';
        insert caseMReqList;
        List<Medication> MedicationRecList = TestFactory.createMedication(1, 'Test Medication');
        insert MedicationRecList;
        List<MedicinalIngredient> MIRecList = TestFactory.createMedicinalIngredient(1, MedicationRecList.get(0).Id, UOMRec.Id);
        Id recordTypeEDRDMI = Schema.SObjectType.MedicinalIngredient.getRecordTypeInfosByDeveloperName().get('EDRD_Medicinal_Ingredient').getRecordTypeId();
        MIRecList.get(0).RecordtypeId = recordTypeEDRDMI;
        insert MIRecList;
        List<MedicationRequest> MRList = TestFactory.createMedicationRequest(1, MedicationRecList.get(0).Id, caseMReqList.get(0).Id, reqstAccount1.Id, patntAccount1.Id); 
        MRList.get(0).Dosage__c = 300;
        MRList.get(0).Dosage_Units__c = UOMRec.Id;
        MRList.get(0).Requested_Frequency__c = 1;
        MRList.get(0).Requested_Frequency_Unit__c = 'Weekly';
        MRList.get(0).Requested_Funding_Duration__c = 1;
        MRList.get(0).Requested_Funding_Duration_Unit__c = 'Weeks';
        MRList.get(0).Medication_Information__c = MIRecList.get(0).Id;
        Id recordTypeMREDRD = Schema.SObjectType.MedicationRequest.getRecordTypeInfosByDeveloperName().get('EDRD_Medication_Request').getRecordTypeId();
        MRList.get(0).recordTypeId = recordTypeMREDRD;
        insert MRList;
        Test.startTest();
        caseMReqList.get(0).EDRD_MOHApproved_Funding_Duration_Unit__c = 'Years';
        Update caseMReqList;
        Test.stopTest();
        Assert.areEqual([SELECT Id, EDRD_MOHDrug_Cost_Forecast__c FROM Case WHERE Id =: caseMReqList.get(0).Id].get(0).EDRD_MOHDrug_Cost_Forecast__c, 5200, 'Calculation Failed');
        Assert.areNotEqual([SELECT Id, EDRD_MOHDrug_Cost_Forecast__c FROM Case WHERE Id =: caseMReqList.get(0).Id].get(0).EDRD_MOHDrug_Cost_Forecast__c, NULL, 'Calculation Populated Blank value');
    }
    
/**
* @author: Deepak
* @date: 15 Jan 2024
* @description: The purpose of this method is to cover Testcoverage of assignACRecReview
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/    
    @isTest
    public static void assignACRecReview_positive(){
        Account reqstAcc = TestFactory.newProvider('Provider Test');
        insert reqstAcc;
        Account patntAcc = TestFactory.newPatient('Patient Test');
        insert patntAcc;
        Id recordTypeCaseEDRD = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('EDRD').getRecordTypeId();
        List<Case> caseRecList = TestFactory.createEDRDCase(1, recordTypeCaseEDRD, reqstAcc.Id);
        caseRecList.get(0).EDRD_Bypass_Eligibility_Form__c=true;
        insert caseRecList;
        Test.startTest();
        caseRecList.get(0).EDRD_SC_Review_Pathway__c = 'Sent to AC';
        Update caseRecList;
        caseRecList.get(0).EDRD_SC_Review_Pathway__c = 'Sent to MOH';
        Update caseRecList;
        Test.stopTest();
        Assert.areEqual([SELECT Id, EDRD_AC_Recommendation_Review__c FROM Case WHERE Id =: caseRecList.get(0).Id].get(0).EDRD_AC_Recommendation_Review__c, 'Not Applicable', 'AC Recommendation Review update Failed');
        Assert.areNotEqual([SELECT Id, EDRD_AC_Recommendation_Review__c FROM Case WHERE Id =: caseRecList.get(0).Id].get(0).EDRD_AC_Recommendation_Review__c, NULL, 'AC Recommendation Review Populated Blank value');
    }
    
/**
* @author: Rahul
* @date: 19 Jan 2024
* @description: The purpose of this method is to cover Testcoverage of calculateFundingExpiry
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/    
    @isTest
    public static void populateFundingExpiryDateTest(){
        Account account1 = TestFactory.newProvider('Provider Test');
        insert account1;
        Id recordTypeCaseEDRD = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('EDRD').getRecordTypeId();
        List<Case> cases = TestFactory.createEDRDCase(3, recordTypeCaseEDRD, account1.Id);
        insert cases;
        cases[0].EDRD_MOHFunding_Start_Date__c = system.Today();
        cases[0].EDRD_MOHFunding_Decision__c = 'Approved';
        cases[0].EDRD_MOHApproved_Funding_Duration__c = 7.0;
        cases[0].EDRD_MOHApproved_Funding_Duration_Unit__c = 'Days';
        cases[0].EDRD_MOHIndefinite_Funding__c = false;
        cases[1].EDRD_MOHFunding_Start_Date__c = system.Today();
        cases[1].EDRD_MOHFunding_Decision__c = 'Extended';
        cases[1].EDRD_MOHApproved_Funding_Duration__c = 7.0;
        cases[1].EDRD_MOHApproved_Funding_Duration_Unit__c = 'Days';
        cases[1].EDRD_MOHIndefinite_Funding__c = false;
        test.startTest();
        update cases;
        test.stopTest();
        Assert.areEqual([SELECT Id, EDRD_MOHFunding_Expiry_Date__c FROM Case WHERE Id =: cases.get(0).Id].get(0).EDRD_MOHFunding_Expiry_Date__c, system.Today()+6, 'Funding expiry date updated');
        Assert.areNotEqual([SELECT Id, EDRD_MOHFunding_Expiry_Date__c FROM Case WHERE Id =: cases.get(0).Id].get(0).EDRD_MOHFunding_Expiry_Date__c, NULL, 'Funding expiry conains value');
        Assert.areEqual([SELECT Id, EDRD_MOHFunding_Extension_Date__c FROM Case WHERE Id =: cases.get(1).Id].get(0).EDRD_MOHFunding_Extension_Date__c, system.Today()+6, 'Funding expiry Extension date updated');
        Assert.areNotEqual([SELECT Id, EDRD_MOHFunding_Extension_Date__c FROM Case WHERE Id =: cases.get(1).Id].get(0).EDRD_MOHFunding_Extension_Date__c, NULL, 'Funding expiry extension conains value');
    }

/**
* @author: Suman
* @date: 14 Feb 2024
* @description: The purpose of this method is to cover Negative scenario for validateAttachmentForMOHReview
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/
    @isTest
    public static void validateAttachmentTestNegative() {
        Account account1 = TestFactory.newProvider('Provider Test');
        insert account1;
        Id recordTypeCaseEDRD = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('EDRD').getRecordTypeId();
        List<Case> cases = TestFactory.createEDRDCase(1, recordTypeCaseEDRD, account1.Id);
        insert cases;
        cases[0].Status = 'MOH Review';
        test.startTest();
        try{
            update cases[0];
        }catch(Exception e){
            Assert.isTrue(e.getMessage().contains(Label.Validation_Error_AttachDocumentMOHReview), 'Expected error');
        }
        test.stopTest();
    }
    
/**
* @author: Deepak
* @date: 20 Jun 2024
* @description: The purpose of this method is to cover Testcoverage of populateEDRDRefNumber.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/
    @isTest
    public static void populateEDRDRefNumber_Test(){
        Account physicianAccount = TestFactory.newProvider('Provider Test');
        insert physicianAccount;
        Account patientAcc = TestFactory.newPatient('Test');
        insert patientAcc;
        Id patientContactId = [SELECT Id FROM Contact WHERE AccountId =: patientAcc.Id].Id;
        String caseRecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('EDRD').getRecordTypeId();
        List<Case> EDRDCaseList = TestFactory.createEDRDCase(1, caseRecordTypeID, physicianAccount.Id);
        EDRDCaseList[0].contactId = patientContactId;
        careProgram careProgramRec = TestFactory.createCareProgram('EDRD');
        insert careProgramRec;
        CareProgramEnrollee CareProgramEnrolleeRec = TestFactory.createCareProgramEnrollee('TEST', patientAcc.Id, careProgramRec.Id);
        insert CareProgramEnrolleeRec;
        Test.startTest();
        insert EDRDCaseList;
        Test.stopTest();
        Assert.areEqual([SELECT Id, EDRD_Ref_No__c FROM Case WHERE Id =: EDRDCaseList].get(0).EDRD_Ref_No__c, '00001-TT', 'EDRD Reference Number & Name should match');
        Assert.areNotEqual([SELECT Id, EDRD_Ref_No__c FROM Case WHERE Id =: EDRDCaseList].get(0).EDRD_Ref_No__c, NULL, 'EDRD Reference Number is null');
    }

/**
* @author: Deepak
* @date: 18 Aug 2024
* @description: The purpose of this method is to cover Testcoverage of forecastDrugCost
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/    
    @isTest
    public static void forecastDrugCost_Test(){
        Account physicianAccount = TestFactory.newProvider('Provider Test');
        insert physicianAccount;
        Account patntAccount = TestFactory.newPatient('Patient Test');
        insert patntAccount;
        UnitOfMeasure UOMRec = TestFactory.createUnitOfMeasure();
        insert UOMRec;        
        Id recordTypeCaseEDRD = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('EDRD').getRecordTypeId();
        List<Case> casesList = TestFactory.createEDRDCase(1, recordTypeCaseEDRD, physicianAccount.Id);
        casesList.get(0).Type = 'New';
        casesList.get(0).EDRD_MOHFunding_Decision__c = 'Approved';
        casesList.get(0).EDRD_MOHApproved_Dosage__c = 300;
        casesList.get(0).EDRD_MOHApproved_Dosage_Unit__c = UOMRec.Id;
        casesList.get(0).EDRD_MOHApproved_Frequency__c = 1;
        casesList.get(0).EDRD_MOHApproved_Frequency_Unit__c = 'Weekly';
        casesList.get(0).EDRD_MOHApproved_Funding_Duration__c = 6;
        casesList.get(0).EDRD_MOHApproved_Funding_Duration_Unit__c = 'Months';
        casesList.get(0).EDRD_MOHFunding_Start_Date__c = Date.newInstance(2024, 1, 1);
        insert casesList;
        List<Medication> drugList = TestFactory.createMedication(1, 'Test Medication');
        insert drugList;
        List<MedicinalIngredient> MIList = TestFactory.createMedicinalIngredient(1, drugList.get(0).Id, UOMRec.Id);
        Id recordTypeEDRDMI = Schema.SObjectType.MedicinalIngredient.getRecordTypeInfosByDeveloperName().get('EDRD_Medicinal_Ingredient').getRecordTypeId();
        MIList.get(0).RecordtypeId = recordTypeEDRDMI;
        insert MIList;
        Id recordTypeMREDRD = Schema.SObjectType.MedicationRequest.getRecordTypeInfosByDeveloperName().get('EDRD_Medication_Request').getRecordTypeId();
        List<MedicationRequest> MRList = TestFactory.createMedicationRequest(1, drugList.get(0).Id, casesList.get(0).Id, physicianAccount.Id, patntAccount.Id); 
        MRList.get(0).Dosage__c = 300;
        MRList.get(0).Dosage_Units__c = UOMRec.Id;
        MRList.get(0).Requested_Frequency__c = 1;
        MRList.get(0).Requested_Frequency_Unit__c = 'Weekly';
        MRList.get(0).Requested_Funding_Duration__c = 6;
        MRList.get(0).Requested_Funding_Duration_Unit__c = 'Months';
        MRList.get(0).Medication_Information__c = MIList.get(0).Id;
        MRList.get(0).recordTypeId = recordTypeMREDRD;
        insert MRList;
                
        Test.startTest();
        casesList.get(0).Status = 'Funding Approved';
        update casesList.get(0);
        Test.stopTest();
        
        List<MedicationDispense> forecastRecords = [SELECT Id FROM MedicationDispense WHERE Case__c =: casesList.get(0).Id];
        Assert.areEqual(2, forecastRecords.size(), 'FY-MedicationDispense records should be created');
        Assert.areNotEqual(0, forecastRecords.size(), 'Forecast records should not be created');
    }
    
/**
* @author: Deepak
* @date: 22 Aug 2024
* @description: The purpose of this method is to cover Testcoverage of delete forecastDrugCost
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/    
    @isTest
    public static void forecastDrugCost_deleteTest(){
        Account pntAccount = TestFactory.newPatient('Patient Test');
        insert pntAccount;
        Account providerAccount = TestFactory.newProvider('Provider Test');
        insert providerAccount;
        UnitOfMeasure UOMRec = TestFactory.createUnitOfMeasure();
        insert UOMRec;        
        Id recordTypeCaseEDRD = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('EDRD').getRecordTypeId();
        List<Case> caseRec = TestFactory.createEDRDCase(1, recordTypeCaseEDRD, providerAccount.Id);
        caseRec.get(0).Type = 'New';
        caseRec.get(0).EDRD_MOHFunding_Decision__c = 'Approved';
        caseRec.get(0).EDRD_MOHApproved_Dosage__c = 300;
        caseRec.get(0).EDRD_MOHApproved_Dosage_Unit__c = UOMRec.Id;
        caseRec.get(0).EDRD_MOHApproved_Frequency__c = 1;
        caseRec.get(0).EDRD_MOHApproved_Frequency_Unit__c = 'Weekly';
        caseRec.get(0).EDRD_MOHApproved_Funding_Duration__c = 6;
        caseRec.get(0).EDRD_MOHApproved_Funding_Duration_Unit__c = 'Months';
        caseRec.get(0).EDRD_MOHFunding_Start_Date__c = Date.newInstance(2024, 1, 1);
        insert caseRec;
        List<Medication> medList = TestFactory.createMedication(1, 'Test Medication');
        insert medList;
        List<MedicinalIngredient> MIList = TestFactory.createMedicinalIngredient(1, medList.get(0).Id, UOMRec.Id);
        Id recordTypeEDRDMI = Schema.SObjectType.MedicinalIngredient.getRecordTypeInfosByDeveloperName().get('EDRD_Medicinal_Ingredient').getRecordTypeId();
        MIList.get(0).RecordtypeId = recordTypeEDRDMI;
        insert MIList;
        Id recordTypeMREDRD = Schema.SObjectType.MedicationRequest.getRecordTypeInfosByDeveloperName().get('EDRD_Medication_Request').getRecordTypeId();
        List<MedicationRequest> MedRList = TestFactory.createMedicationRequest(1, medList.get(0).Id, caseRec.get(0).Id, providerAccount.Id, pntAccount.Id); 
        MedRList.get(0).Dosage__c = 300;
        MedRList.get(0).Dosage_Units__c = UOMRec.Id;
        MedRList.get(0).Requested_Frequency__c = 1;
        MedRList.get(0).Requested_Frequency_Unit__c = 'Weekly';
        MedRList.get(0).Requested_Funding_Duration__c = 6;
        MedRList.get(0).Requested_Funding_Duration_Unit__c = 'Months';
        MedRList.get(0).Medication_Information__c = MIList.get(0).Id;
        MedRList.get(0).recordTypeId = recordTypeMREDRD;
        insert MedRList;
        caseRec.get(0).Status = 'Funding Approved';
        update caseRec.get(0);
                
        Test.startTest();
        ESA_cls_caseTriggerHandler.FYOnce = true;
        caseRec.get(0).EDRD_MOHFunding_Expiry_Date__c = Date.newInstance(2029, 12, 31);
        update caseRec.get(0);
        Test.stopTest();
        
        List<MedicationDispense> forecastRecords = [SELECT Id FROM MedicationDispense WHERE Case__c =: caseRec.get(0).Id];
        Assert.areEqual(7, forecastRecords.size(), 'FY-MedicationDispense records should be created');
        Assert.areNotEqual(0, forecastRecords.size(), 'Forecast records should not be created');
    }
    
/**
* @author: Deepak
* @date: 17 Oct 2024
* @description: The purpose of this method is to cover Testcoverage of delete UpdateProviderOnEDRDCase
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/    
    @isTest
    public static void UpdateProviderOnEDRDCaseTest(){
        Account providerAccount = TestFactory.newProvider('Provider Test');
        providerAccount.Is_EDRD_Provider__pc = FALSE;
        insert providerAccount;
        Id recordTypeCaseEDRD = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('EDRD').getRecordTypeId();
        List<Contact> conList = [SELECT Id FROM Contact WHERE accountID =: providerAccount.Id LIMIT 1];
        List<Case> caseRec = TestFactory.createEDRDCase(1, recordTypeCaseEDRD, providerAccount.Id);
        caseRec.get(0).provider__c = conList.get(0).Id;
                
        Test.startTest();
        insert caseRec;
        Test.stopTest();
        
        List<Account> providerRecords = [SELECT Id, Is_EDRD_Provider__pc FROM Account WHERE Id =: providerAccount.Id];
        Assert.areEqual(TRUE, providerRecords.get(0).Is_EDRD_Provider__pc, 'Is EDRD Provider Field should be True');
        Assert.areNotEqual(FALSE, providerRecords.get(0).Is_EDRD_Provider__pc, 'Is EDRD Provider Field cannot be False');    
    }
}