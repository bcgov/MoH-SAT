@isTest
public class ESA_cls_ExternalCommitteeTriggerTest {
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
    
    @isTest 
    public static void testExternalCommitteClone(){
        External_Committee__c ec = [SELECT id, External_Committee_Type__c 
                                    FROM External_Committee__c 
                                    LIMIT 1];
        Test.startTest();
        External_Committee__c eccopy = ec.clone();
        insert eccopy;
        Assert.areEqual(ec.External_Committee_Type__c,eccopy.External_Committee_Type__c	, 'External Committee type should not be modfified'); 
        Assert.areNotEqual(NULL,eccopy.Id, 'External Committee insert failed'); 
        
        Test.stopTest();
        
    }
}