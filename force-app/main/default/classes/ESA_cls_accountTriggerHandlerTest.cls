/**********************************************************************************************
* @Author:      Deepak 
* @Date:        09 Mar 2023
* @Description: The purpose of this class is to cover Code coverage of ESA_cls_accountTriggerHandler
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
***********************************************************************************************/

@isTest
public class ESA_cls_accountTriggerHandlerTest {
    
/**
* @author: Deepak
* @date: 09 Mar 2023
* @description: The purpose of this method is to cover Testcoverage
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
}