public with sharing class AdjudicationService {
    
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
        AdjudicationStrategy strategy = AdjudicationStrategyFactory.getStrategy(sar);
        
        strategy.runEvaluate();

        if (assignOwner) {
            sar.saCase.OwnerId = sar.getDefaultOwnerId();
        }
    }

}
