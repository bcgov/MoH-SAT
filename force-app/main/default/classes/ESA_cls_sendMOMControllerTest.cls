/**********************************************************************************************
* @Author:      Deepak 
* @Date:        26th Sept 2023
* @Description: The purpose of this class is to cover Code coverage of ESA_cls_sendMOMController
***********************************************************************************************/
@isTest
public class ESA_cls_sendMOMControllerTest {
    @TestSetup static void dataSetup() { 
        Account acc = TestFactory.newAccount('Test Account');
        insert acc;
        Contact con = TestFactory.newContact('Test Contact', 'testemail@test.com', acc.Id);
        insert con;
        Drug__c drug = TestFactory.newDrug('testdrug');
        insert drug;
        External_Committee__c ec = TestFactory.newExternalCommittee('IBD DBAAC 3000-01-01', 'IBD DBAAC', acc.Id);
        insert ec;
        Case ca = TestFactory.newCase(drug, 'Test Case', ec);
        insert ca;   
    }
    
    @istest
    public static void sendMOMTest(){
        List<External_Committee__c> externalCommitteList = [SELECT Id, NAME, EC_To_Account__c FROM External_Committee__c 
                                                            LIMIT 1];
                
        List<String> returnString = new List<String>();
        List<String> returnStringNegative = new List<String>();
        Test.startTest();
        returnStringNegative = ESA_cls_sendMOMController.sendMOM(NULL);
        returnString = ESA_cls_sendMOMController.sendMOM(new List<Id>{externalCommitteList[0].Id});
        Test.stopTest();
        Integer afterInvocations = Limits.getEmailInvocations();
        Assert.areEqual(1, afterInvocations, 'Email has not been sent');
        Assert.areNotEqual(TRUE, returnStringNegative.isEmpty(), 'Exception occured in Negative');
    }
    
}