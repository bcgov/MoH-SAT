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
    static void test_run_mock_action() {
        Drug__c drug = queryDrug('Drug 1');
        drug.Auto_Run_Apex__c = 'AdjudicationStrategyTest.MockAdjudicationAction';
        update drug;

        SpecialAuthorityRequest sar = SpecialAuthorityRequest.build(queryCase('Test case 1').Id);
        AdjudicationStrategy strategy = new AdjudicationStrategy(sar);
        strategy.runEvaluate();
        system.assertEquals('mock action executed', sar.saCase.Subject );
    }

    private static Drug__c queryDrug(String name) {
        return [select Id, Name, Auto_Run_Apex__c from Drug__c where Name = :name limit 1][0];
    }

    private static Case queryCase(String subject) {
        return [select Id, Subject from Case where Subject = :subject limit 1][0];
    }

    public class MockAdjudicationAction implements AdjudicationAction {
        public void execute(SpecialAuthorityRequest sar) {
            sar.saCase.Subject = 'mock action executed';
        }
    }
}
