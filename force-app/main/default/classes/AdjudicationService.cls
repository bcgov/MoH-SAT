public with sharing class AdjudicationService {
    
    @TestVisible
    private static AdjudicationStrategy ADJUDICATION_STRATEGY = new AdjudicationStrategy();

    public static void evaluate(Id caseId) {
        SpecialAuthorityRequest sar = SpecialAuthorityRequest.build(caseId); 
        
        evaluate(sar);
        
        update sar.saCase;
    }

    public static void evaluate(Case saCase) {
        evaluate(SpecialAuthorityRequest.build(saCase));
    }

    private static void evaluate(SpecialAuthorityRequest sar) {
        if (sar.drug == null || sar.saCase.isClosed) return;

        AdjudicationStrategy strategy = buildAdjudicationStrategy(sar.getAdjudicationStrategy());
        
        strategy.runEvaluate(sar);
    }
    
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
