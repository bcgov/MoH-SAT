public with sharing class AdjudicationService {
    
    @TestVisible
    private static AdjudicationStrategy ADJUDICATION_STRATEGY = new AdjudicationStrategy();
    
    public static void evaluate(Id caseId) {
        evaluate(caseId, false);
    }

    public static void evaluate(Id caseId, Boolean assignOwner) {
        SpecialAuthorityRequest sar = SpecialAuthorityRequest.build(caseId); 
        
        evaluate(sar, assignOwner);
        
        update sar.saCase;
    }

    public static void evaluate(Case saCase) {
        evaluate(saCase, false);
    }

    public static void evaluate(Case saCase, Boolean assignOwner) {
        evaluate(SpecialAuthorityRequest.build(saCase), assignOwner);
    }

    private static void evaluate(SpecialAuthorityRequest sar, Boolean assignOwner) {
        AdjudicationStrategy strategy = buildAdjudicationStrategy(sar.getAdjudicationStrategy());
        
        system.debug(String.valueOf(strategy).split(':')[0]);

        strategy.runEvaluate(sar);

        if (assignOwner) {
            sar.saCase.OwnerId = sar.getDefaultOwnerId();
        }
    }

    @TestVisible
    private static AdjudicationStrategy buildAdjudicationStrategy(String drugStrategy) {
        switch on drugStrategy {
            when 'Criteria' {
                ADJUDICATION_STRATEGY = new CriteriaBasedAdjudication();
            }
            when 'Apex' {
                ADJUDICATION_STRATEGY = new ApexBasedAdjudication();
            } 
        }
        
        return ADJUDICATION_STRATEGY;
    }

}
