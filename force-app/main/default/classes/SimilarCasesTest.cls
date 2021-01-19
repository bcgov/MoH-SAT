@isTest
public with sharing class SimilarCasesTest {

    @isTest
    static void test_find() {
        Drug__c drug1 = newDrug('Drug 1');
        Drug__c drug2 = newDrug('Drug 2');
        insert new Drug__c[] { drug1, drug2 };
        
        Case case1 = newCase(drug1, 'Case 1 for Drug 1');
        Case case2 = newCase(drug2, 'Case 2 for Drug 2');
        Case case3 = newCase(drug1, 'Case 3 for Drug 1');
        case1.Status = 'Approved';
        case2.Status = 'Approved';
        case3.Status = 'Received';
        insert new Case[] { case1, case2, case3 };

        Test.startTest();
        List<Case> similarCases = SimilarCases.find(case3.Id);
        Test.stopTest();

        system.assertEquals(2, similarCases.size());
        system.assertEquals(case1.Id, similarCases[0].Id);
        
    }

    private static Drug__c newDrug(String name) {
        Drug__c drug = new Drug__c();
        drug.Name = name;
        drug.Drug_Code__c = name;
        drug.Pharmanet_Code__c = name;
        return drug;
    }

    private static Case newCase(Drug__c drug, String subject) {
        Case c = new Case();
        c.Drug__c = drug.Id;
        c.Subject = subject;
        return c;
    }
}
