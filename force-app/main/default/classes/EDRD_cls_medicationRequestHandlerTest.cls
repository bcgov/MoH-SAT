/**********************************************************************************************
* @Author:      Deepak 
* @Date:        14 Dec 2023
* @Description: The purpose of this class is to cover Code coverage of EDRD_cls_medicationRequestHandler
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description] 
***********************************************************************************************/

@isTest
public class EDRD_cls_medicationRequestHandlerTest {
    
/**
* @author: Deepak
* @date: 14 Dec 2023
* @description: The purpose of this method is to cover Testcoverage of validateMedicationRequest
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/    
    @isTest
    public static void validateMedicationRequest_positive(){
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
            MedicationRequest MedicationRequestRec2 = TestFactory.createMedicationRequest(MedicationRec.Id, MRCase.Id, requestorAccount.Id, patientAccount.Id);
            insert MedicationRequestRec2;
            Test.stopTest();
        } 
        catch(exception e){
            Assert.areEqual(e.getMessage().containsIgnoreCase(label.EDRD_label_MR_duplicateCase), True, 'Duplicate Record Created');
            Assert.areNotEqual(e.getMessage().containsIgnoreCase(label.EDRD_label_MR_duplicateCase), False, 'Validation Failed');
        }
    }
}