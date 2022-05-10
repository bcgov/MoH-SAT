@isTest
public with sharing class AutofaxControllerTest {
    
    @TestSetup
    static void makeData(){
        Drug__c drug = TestFactory.newDrug('Drug 1');
        insert drug;

        Account patient = TestFactory.newPatient('Patient 1');
        Account provider = TestFactory.newProvider('Provider 1');
        provider.Fax = '2500000000';
        insert new Account[] { patient, provider };

        
        Case case1 = TestFactory.newCase(drug, patient, provider, 'Case 1 for Drug 1');
        Case case2 = TestFactory.newCase(drug, patient, provider, 'Case 2 for Drug 2');
        Case case3 = TestFactory.newCase(drug, patient, provider, 'Case 3 for Drug 1');
        case1.Status = 'Approved';
        case2.Status = 'Approved';
        case3.Status = 'Approved';
        
        Id queueID = [select Id, DeveloperName from Group where DeveloperName = 'To_be_faxed_queue' limit 1].Id;
        case1.OwnerId = queueID;
        case2.OwnerId = queueID;
        case3.OwnerId = queueID;
        
        insert new Case[] { case1, case2, case3 };
    }

    @isTest()
    static void test_page_load() {
        ApexPages.StandardSetController setcontroller = 
            new ApexPages.StandardSetController([select Id from Case]);

        AutofaxController controller = new AutofaxController(setcontroller);
        
        system.assertEquals(false, controller.faxableCases.isEmpty());
    }

}
