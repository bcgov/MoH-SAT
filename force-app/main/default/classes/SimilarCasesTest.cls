@isTest
public with sharing class SimilarCasesTest {

    @isTest
    static void test_find() {
        Drug__c drug1 = newDrug('Drug 1');
        Drug__c drug2 = newDrug('Drug 2');
        insert new Drug__c[] { drug1, drug2 };
        
        Case case1 = TestFactory.newCase(drug1, 'Case 1 for Drug 1');
        Case case2 = TestFactory.newCase(drug2, 'Case 2 for Drug 2');
        Case case3 = TestFactory.newCase(drug1, 'Case 3 for Drug 1');
        case1.Status = 'Approved';
        case2.Status = 'Approved';
        case3.Status = 'Received';
        insert new Case[] { case1, case2, case3 };

        Test.startTest();
        List<Case> similarCases = SimilarCases.find(case3.Id);
        Test.stopTest();

        system.assertEquals(1, similarCases.size());
        system.assertEquals(case1.Id, similarCases[0].Id);
        
    }

    @isTest
    static void test_get_active_cases() {
        Drug__c drug1 = newDrug('Drug 1');
        Drug__c drug2 = newDrug('Drug 2');
        insert new Drug__c[] { drug1, drug2 };
        
        Contact contact = new Contact(Firstname='Test', Lastname='Contact');
        insert contact;

        Case case1 = TestFactory.newCase(drug1, 'Case 1 for Drug 1');
        Case case2 = TestFactory.newCase(drug2, 'Case 2 for Drug 2');
        Case case3 = TestFactory.newCase(drug1, 'Case 3 for Drug 1');
        case1.Status = 'Approved';
        case2.Status = 'Approved';
        case3.Status = 'Received';
        case1.ContactId = contact.Id;
        case2.ContactId = contact.Id;
        case3.ContactId = contact.Id;
        insert new Case[] { case1, case2, case3 };

        Test.startTest();
        List<Case> activeCases = SimilarCases.getActiveSaRequests(contact.Id, drug1.Id);
        Test.stopTest();

        system.assertEquals(2, activeCases.size());
    }

    private static Drug__c newDrug(String name) {
        Drug__c drug = new Drug__c();
        drug.Name = name;
        drug.Drug_Code__c = name;
        return drug;
    }
}
