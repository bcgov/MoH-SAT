public with sharing class AdjudicationStrategyFactory {

    @TestVisible
    private static AdjudicationStrategy mockStrategy;

    public static AdjudicationStrategy getStrategy(SpecialAuthorityRequest sar, Boolean assignOwner) {
        return mockStrategy == null ? new AdjudicationStrategy(sar, assignOwner) : mockStrategy;
    }

}
