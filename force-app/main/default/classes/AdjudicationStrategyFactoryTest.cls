@isTest
public class AdjudicationStrategyFactoryTest {
    @isTest
    static void test_adjudication_strategy_factory() {
        Drug__c drug = TestFactory.newDrug('Drug 1');
        drug.Adjudication_Strategy__c = null;
        insert drug;

        Case saCase = TestFactory.newCase(drug, 'Test case 1');
        insert saCase;

        SpecialAuthorityRequest sar = SpecialAuthorityRequest.build(saCase.Id);

        AdjudicationStrategy strategy = AdjudicationStrategyFactory.getStrategy(sar);
        system.assert((Object) strategy instanceof AdjudicationStrategy);

        drug.Adjudication_Strategy__c = 'Criteria';
        update drug;
        sar = SpecialAuthorityRequest.build(saCase.Id);
        strategy = AdjudicationStrategyFactory.getStrategy(sar);
        system.assert(strategy instanceof CriteriaBasedAdjudication);
        
        drug.Adjudication_Strategy__c = 'Apex';
        update drug;
        sar = SpecialAuthorityRequest.build(saCase.Id);
        strategy = AdjudicationStrategyFactory.getStrategy(sar);
        system.assert(strategy instanceof ApexBasedAdjudication);
    }
}
