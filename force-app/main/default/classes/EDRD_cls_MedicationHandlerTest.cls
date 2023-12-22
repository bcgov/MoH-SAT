/**********************************************************************************************
* @Author:      Deepak 
* @Date:        16 Dec 2023
* @Description: The purpose of this class is to cover Code coverage of EDRD_cls_MedicationHandler
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description] 
***********************************************************************************************/

@isTest
public class EDRD_cls_MedicationHandlerTest {
    
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
        Case MRCase = TestFactory.createEDRDCase(recordTypeCaseEDRD, RequestorAccount.Id);
        MRCase.Type = 'New';
        Id ContactId = [SELECT Id FROM Contact WHERE AccountID =: requestorAccount.Id].get(0).Id;
        MRCase.Provider__c = ContactId;
        insert MRCase;
        User communityUser = TestFactory.createCommunityUser(ContactId, profileObj.Id, 'Test1', 'Test');
        insert communityUser;
        Medication MedicationRec = TestFactory.createMedication();
        insert MedicationRec;
        MedicationRequest MedicationRequestRec = TestFactory.createMedicationRequest(MedicationRec.id, MRCase.Id, requestorAccount.Id, patientAccount.Id); 
        insert MedicationRequestRec;
        Test.startTest();
        MedicationRec.Status = 'Inactive';
        update MedicationRec;
        Test.stopTest();
        Case caseRec = [SELECT Id, Status FROM Case WHERE Id =: MRCase.Id];
        Assert.areEqual(caseRec.Status , 'Cancelled', 'Case has not been Closed');
        Assert.areNotEqual(caseRec.Status , NULL, 'Case Status is Received');
    }
}