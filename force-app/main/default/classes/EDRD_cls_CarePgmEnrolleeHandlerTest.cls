/**********************************************************************************************
* @Author:      Accenture
* @Date:        30/01/2024
* @Description: The purpose of this class is cover the coverage for EDRD_cls_CarePgmEnrolleeHandler
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]
***********************************************************************************************/
@isTest
public class EDRD_cls_CarePgmEnrolleeHandlerTest {
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
}