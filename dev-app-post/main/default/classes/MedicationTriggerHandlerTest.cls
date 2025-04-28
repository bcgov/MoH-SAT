/**********************************************************************************************
* @Author:      Deepak 
* @Date:        16 Dec 2023
* @Description: The purpose of this class is to cover Code coverage of MedicationTriggerHandler
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description] 
***********************************************************************************************/

@isTest
public class MedicationTriggerHandlerTest {
    
/**
* @author: Deepak
* @date: 16 Dec 2023
* @description: The purpose of this method is to cover Testcoverage of validateMedicationRequest & sendNotification.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/    
    @isTest
    public static void validateMedicationRequest_positive(){
        Profile profileObj = [SELECT Id FROM Profile WHERE Name = 'EDRD Prescriber Community User'];
        Account requestorAccount = TestFactory.newProvider('Provider Test');
        insert requestorAccount;
        Account patientAccount = TestFactory.newPatient('Patient Test');
        insert patientAccount;
        Id recordTypeCaseEDRD = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('EDRD').getRecordTypeId();
        List<Case> MRCaseList = TestFactory.createEDRDCase(1, recordTypeCaseEDRD, RequestorAccount.Id);
        MRCaseList.get(0).Type = 'New';
        Id ContactId = [SELECT Id FROM Contact WHERE AccountID =: requestorAccount.Id].get(0).Id;
        MRCaseList.get(0).Provider__c = ContactId;
        insert MRCaseList;
        User communityUser = TestFactory.createCommunityUser(ContactId, profileObj.Id, 'Test1', 'Test');
        insert communityUser;
        List<Medication> MedicationRecList = TestFactory.createMedication(1, 'Test Medication');
        insert MedicationRecList;
        List<MedicationRequest> MedicationRequestRecList = TestFactory.createMedicationRequest(1, MedicationRecList.get(0).id, MRCaseList.get(0).Id, requestorAccount.Id, patientAccount.Id); 
        insert MedicationRequestRecList;
        
        try{
            Test.startTest();
            MedicationRecList.get(0).Status = 'Inactive';
            update MedicationRecList;
            Test.stopTest();
            
            Case caseRec = [SELECT Id, Status FROM Case WHERE Id =: MRCaseList.get(0).Id];
            Assert.areEqual(caseRec.Status , 'Cancelled', 'Case has not been Closed');
            Assert.areNotEqual(caseRec.Status , NULL, 'Case Status is Received');
        }catch(exception ex){
            System.debug('Error While updating the MR'+ ex.getMessage());
        }         
    }
    
/**
* @author: Deepak
* @date: 25 Apr 2025
* @description: The purpose of this method is to cover Testcoverage of sendNotification.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/    
    @isTest
    public static void sendNotificationTest(){
        Profile profileObj = [SELECT Id FROM Profile WHERE Name = 'EDRD Prescriber Community User'];
        Account requestorAccount1 = TestFactory.newProvider('Provider Test');
        insert requestorAccount1;
        Account patientAccount = TestFactory.newPatient('Patient Test');
        insert patientAccount;
        Id ContactId = [SELECT Id FROM Contact WHERE AccountID =: requestorAccount1.Id].get(0).Id;
        Id recordTypeCaseEDRD = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('EDRD').getRecordTypeId();
        List<Case> MRCaseList = TestFactory.createEDRDCase(1, recordTypeCaseEDRD, RequestorAccount1.Id);
        MRCaseList.get(0).Type = 'New';
        MRCaseList.get(0).Provider__c = ContactId;
        insert MRCaseList;
        User communityUser = TestFactory.createCommunityUser(ContactId, profileObj.Id, 'Test1', 'Test');
        insert communityUser;
        List<Medication> MedicationRecList = TestFactory.createMedication(1, 'Test Medication');
        insert MedicationRecList;
        List<MedicationRequest> MedicationRequestRecList = TestFactory.createMedicationRequest(1, MedicationRecList.get(0).id, MRCaseList.get(0).Id, requestorAccount1.Id, patientAccount.Id); 
        insert MedicationRequestRecList;
        Map<Id, Map<String, String>> accountIdVsNotificationDetails = new Map<Id, Map<String, String>>();
        accountIdVsNotificationDetails.put(MedicationRequestRecList[0].Case__r.Provider__r.AccountId, 
                                                       new Map<String, String>{'PROVIDER_NAME' => MedicationRequestRecList[0].Case__r.Provider__r.Name, 
                                                           'CASE_NUMBER' =>  MedicationRequestRecList[0].Case__r.CaseNumber,
                                                           'MEDICATION_NAME' => MedicationRequestRecList[0].Medication.Name});
        try{
            Test.startTest();
            MedicationTriggerHandler.sendNotification(accountIdVsNotificationDetails);
            Test.stopTest();
            
        }catch(exception ex){
            System.debug('Error While Sending Notification to Provider'+ ex.getMessage());
        }         
    }
}