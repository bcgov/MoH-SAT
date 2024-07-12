/**********************************************************************************************
* @Author:      Accenture
* @Date:        30/01/2024
* @Description: The purpose of this class is cover the coverage for CarePgmEnrolleeTriggerHandler
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]
               30-Jan24     EDRD-624           Accenture      Added updateNameTest
               11-Jul24     EDRD-764           Accenture      Added updateEnrolleeNameOnAccTest
***********************************************************************************************/
@isTest
public class CarePgmEnrolleeTriggerHandlerTest {
/**
* @author: Accenture
* @date: 30/01/2024
* @description: The purpose of this method is to cover Testcoverage of updateEnrolleeName
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/  
    @isTest
    public static void updateNameTest(){
        Account patientAccount = TestFactory.newPatient('Patient Test');
        insert patientAccount;
        careProgram careProgramRec = TestFactory.createCareProgram('EDRD');
        insert careProgramRec;
        CareProgramEnrollee CareProgramEnrolleeRec = TestFactory.createCareProgramEnrollee('TEST', patientAccount.Id, careProgramRec.Id);
        test.startTest();
        insert CareProgramEnrolleeRec;
        test.stopTest();
        Assert.areEqual([SELECT Id, Name  FROM CareProgramEnrollee WHERE Id =: CareProgramEnrolleeRec.Id].get(0).Name, '00001-PT', 'Name matched');
        Assert.areNotEqual([SELECT Id, Name  FROM CareProgramEnrollee WHERE Id =: CareProgramEnrolleeRec.Id].get(0).Name, NULL, 'Name should not be null');
        
    }
    
/**
* @author: Deepak
* @date: 11/07/2024
* @description: The purpose of this method is to cover Testcoverage of updateEnrolleeNameOnAcc
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/  
    @isTest
    public static void updateEnrolleeNameOnAccTest(){
        Account patientAcc = TestFactory.newPatient('Patient Test');
        insert patientAcc;
        careProgram careProgramRec = TestFactory.createCareProgram('EDRD');
        insert careProgramRec;
        CareProgramEnrollee CareProgramEnrolleeRec = TestFactory.createCareProgramEnrollee('TEST', patientAcc.Id, careProgramRec.Id);
        test.startTest();
        insert CareProgramEnrolleeRec;
        test.stopTest();
        Assert.areEqual([SELECT Id, EDRD_Ref_No__pc FROM Account WHERE Id =: patientAcc.Id].get(0).EDRD_Ref_No__pc, [SELECT Id, Name FROM CareProgramEnrollee WHERE Id =: CareProgramEnrolleeRec.Id].get(0).Name, 'Name should match');
        Assert.areNotEqual([SELECT Id, EDRD_Ref_No__pc FROM Account WHERE Id =: patientAcc.Id].get(0).EDRD_Ref_No__pc, NULL, 'Name should not be null');
    }
}