public with sharing class AdjudicationStrategyFactory {

    @TestVisible
    private static AdjudicationStrategy mockStrategy;

    public static AdjudicationStrategy getStrategy(SpecialAuthorityRequest sar) {
        AdjudicationStrategy strategy;
        
        switch on sar.getAdjudicationStrategy() {
            when 'Criteria' {
                strategy = new CriteriaBasedAdjudication(sar);
            } when 'Apex' {
                strategy = new ApexBasedAdjudication(sar);
            } when else {
                strategy = new AdjudicationStrategy(sar);
            }
        }
        
        return mockStrategy == null ? strategy : mockStrategy;
    }

}
