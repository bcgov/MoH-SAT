@isTest
public class PatientRelatedCasesTest {
    @isTest
    static void test_find() {
        Drug__c drug = TestFactory.newDrug('Drug 1');
        insert drug;

        Account patient = TestFactory.newPatient('Patient 1');
        Account provider = TestFactory.newProvider('Provider 1');
        insert new Account[] { patient, provider };

        Case case1 = TestFactory.newCase(drug, patient, provider, 'Case 1 for Drug 1');
        Case case2 = TestFactory.newCase(drug, patient, provider, 'Case 2 for Drug 2');
        Case case3 = TestFactory.newCase(drug, patient, provider, 'Case 3 for Drug 1');
        case1.Status = 'Approved';
        case2.Status = 'Approved';
        case3.Status = 'Received';
        insert new Case[] { case1, case2, case3 };

        Test.startTest();
        List<Case> relatedCases = PatientRelatedCases.query(case1.Id);
        List<Case> relatedCasesCount2 = PatientRelatedCases.query(case3.Id);
        Test.stopTest();

        Assert.areEqual(1, relatedCases.size(), 'Related cases should be 1');
        Assert.areNotEqual(1, relatedCasesCount2.size(), 'Related cases should be not give any record');
        
    }
    
}