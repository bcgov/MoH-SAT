@isTest
public class CriteriaBasedAdjudicationTest {
    @TestSetup
    static void test_setup(){
        Drug__c drug = TestFactory.newDrug('Drug 1');
        drug.Adjudication_Strategy__c = 'Criteria';
        drug.Criteria_Logic__c = 'AND(1, 2)';
        insert drug;

        Adjudication_Criteria__c ac1 = TestFactory.newCriteria(drug, 1, 'Case', 'Origin', null, 'equals', 'Fax');
        Adjudication_Criteria__c ac2 = TestFactory.newCriteria(drug, 2, 'Case', 'Priority', null, 'equals', 'Medium');
        insert new Adjudication_Criteria__c[] {ac1, ac2};

        Case saCase = TestFactory.newCase(drug, 'Test case 1');
        saCase.Origin = 'Fax';
        saCase.Priority = 'Low';
        insert saCase;
    }

    @isTest
    static void test_evaluate() {
        Case saCase = queryCase('Test case 1');
        saCase.Priority = 'Medium';
        update saCase;

        SpecialAuthorityRequest sar = SpecialAuthorityRequest.build(saCase.Id);
        
        Test.startTest();
        AdjudicationStrategy strategy = new CriteriaBasedAdjudication(sar);
        strategy.evaluate();
        Test.stopTest();

        system.assertEquals('Approved', sar.saCase.Status);
    }

    @isTest
    static void test_evaluate_negative() {
        Case saCase = queryCase('Test case 1');
        saCase.Priority = 'Low';
        update saCase;
        
        SpecialAuthorityRequest sar = SpecialAuthorityRequest.build(saCase.Id);
        
        Test.startTest();
        AdjudicationStrategy strategy = new CriteriaBasedAdjudication(sar);
        strategy.evaluate();
        Test.stopTest();

        system.assertNotEquals('Approved', sar.saCase.Status);
    }

    private static Case queryCase(String subject) {
        return [
            select Id
            from Case
            where Subject = :subject
            limit 1
        ][0];
    }
}
