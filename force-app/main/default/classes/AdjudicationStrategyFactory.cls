public with sharing class AdjudicationStrategyFactory {

    @TestVisible
    private static AdjudicationStrategy mockStrategy;

    public static AdjudicationStrategy getStrategy(SpecialAuthorityRequest sar) {
        return mockStrategy == null ? new AdjudicationStrategy(sar) : mockStrategy;
    }

}
