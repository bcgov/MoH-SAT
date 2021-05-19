@isTest
public class AdjudicationStrategyFactoryTest {
    @isTest
    static void test_adjudication_strategy_factory() {
        Drug__c drug = TestFactory.newDrug('Drug 1');
        insert drug;

        Case saCase = TestFactory.newCase(drug, 'Test case 1');
        insert saCase;

        SpecialAuthorityRequest sar = SpecialAuthorityRequest.build(saCase.Id);

        AdjudicationStrategy strategy = AdjudicationStrategyFactory.getStrategy(sar, false);
        system.assert((Object) strategy instanceof AdjudicationStrategy);
    }
}
