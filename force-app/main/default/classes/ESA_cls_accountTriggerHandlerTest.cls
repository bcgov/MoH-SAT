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
        Account providerAccount = TestFactory.newProvider('Test');
        insert providerAccount;
        String caseRecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('EDRD').getRecordTypeId();
        List<Case> EDRDCaseList = TestFactory.createEDRDCase(1, caseRecordTypeID, providerAccount.Id);
        insert EDRDCaseList;
        careProgram careProgramRec = TestFactory.createCareProgram('EDRD');
        insert careProgramRec;
        CareProgramEnrollee CareProgramEnrolleeRec = TestFactory.createCareProgramEnrollee('TEST', providerAccount.Id, careProgramRec.Id);
        insert CareProgramEnrolleeRec;
        Test.startTest();
        providerAccount.Patient_is_Deceased__pc = true;
        Update providerAccount;
        Test.stopTest(); 
        
        Assert.areEqual([SELECT Id FROM Case WHERE isClosed = false].isEmpty(), True, 'Cases are not closed');
        Assert.areNotEqual([SELECT Id FROM Case WHERE isClosed = true].isEmpty(), True, 'Cases are not closed');
    }
}