@isTest
public class AdjudicationStrategyTest {
    
    @TestSetup
    static void test_setup(){
        Drug__c drug = TestFactory.newDrug('Drug 1');
        insert drug;

        Case saCase = TestFactory.newCase(drug, 'Test case 1');
        insert saCase;
    }

    @isTest
    static void test_run_pre_adjudication_action() {
        Drug__c drug = queryDrug('Drug 1');
        drug.Pre_Adjudication_Apex__c = 'AdjudicationStrategyTest.MockAction';
        update drug;

        SpecialAuthorityRequest sar = new SobjectSarBuilder(queryCase('Test case 1').Id).build();
        new AdjudicationStrategy(sar, false).runEvaluate();
        system.assertEquals('Test case 1 +mock action executed', sar.saCase.Subject);
    }

    @isTest
    static void test_run_post_adjudication_action() {
        Drug__c drug = queryDrug('Drug 1');
        drug.Post_Adjudication_Apex__c = 'AdjudicationStrategyTest.MockAction';
        update drug;

        SpecialAuthorityRequest sar = new SobjectSarBuilder(queryCase('Test case 1').Id).build();
        new AdjudicationStrategy(sar, false).runEvaluate();
        system.assertEquals('Test case 1 +mock action executed', sar.saCase.Subject);
    }

    @isTest
    static void test_run_pre_post_adjudication_action() {
        Drug__c drug = queryDrug('Drug 1');
        drug.Pre_Adjudication_Apex__c = 'AdjudicationStrategyTest.MockAction';
        drug.Post_Adjudication_Apex__c = 'AdjudicationStrategyTest.MockAction';
        update drug;

        SpecialAuthorityRequest sar = new SobjectSarBuilder(queryCase('Test case 1').Id).build();
        new AdjudicationStrategy(sar, false).runEvaluate();
        system.assertEquals('Test case 1 +mock action executed +mock action executed', sar.saCase.Subject);
    }

    @isTest
    static void test_run_action_with_exception() {
        Drug__c drug = queryDrug('Drug 1');
        drug.Pre_Adjudication_Apex__c = 'AdjudicationStrategyTest.MockAdjudicationWithError';
        update drug;

        SpecialAuthorityRequest sar = new SobjectSarBuilder(queryCase('Test case 1').Id).build();
        
        try {
            new AdjudicationStrategy(sar, false).runEvaluate();
            system.assert(false, 'An expected exception was not thrown.');
        } catch (Exception e) {
            system.assert(e.getMessage().contains('mock exception'));
        }
    }

    private static Drug__c queryDrug(String name) {
        return [select Id, Name, Pre_Adjudication_Apex__c, Post_Adjudication_Apex__c from Drug__c where Name = :name limit 1][0];
    }

    private static Case queryCase(String subject) {
        return [select Id, Subject from Case where Subject = :subject limit 1][0];
    }

    public class MockAction implements Action {
        public void execute(SpecialAuthorityRequest sar, StepAction actionParams) {
            sar.saCase.Subject += ' +mock action executed';
        }
    }

    public class MockAdjudicationWithError implements Action {
        public void execute(SpecialAuthorityRequest sar, StepAction actionParams) {
            throw new MockException('mock exception');
        }
    }

    public class MockException extends Exception {}
}
