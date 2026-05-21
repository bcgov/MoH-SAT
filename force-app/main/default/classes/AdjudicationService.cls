public without sharing class AdjudicationService {
    
    private static Set<Id> queuedIds = new Set<Id>();

    public static void evaluateFuture(Id caseId, Boolean assignOwner) {
        if (queuedIds.contains(caseId)) return;

        runEvaluateFuture(caseId, assignOwner);
        
        queuedIds.add(caseId);
    }

    @future(callout=true)
    private static void runEvaluateFuture(Id caseId, Boolean assignOwner) {
        evaluate(caseId, assignOwner);
    }

    public static void evaluate(Id caseId) {
        evaluate(caseId, false);
    }

    public static void evaluate(Id caseId, Boolean assignOwner) {
        SpecialAuthorityRequest sar = new SobjectSarBuilder(caseId).build(); 
        evaluate(sar, assignOwner);
        
        // ADD DEBUGS
        System.debug('### AdjudicationService - Before update Status: ' 
            + sar.saCase.Status);
        System.debug('### AdjudicationService - Auto_Adjudicated_Date: ' 
            + sar.saCase.Auto_Adjudicated_Date__c);
        
        update sar.saCase;
    }

    private static void evaluate(SpecialAuthorityRequest sar, Boolean assignOwner) {
        queuedIds.add(sar.saCase.Id);
        
        AdjudicationStrategy strategy = AdjudicationStrategyFactory.getStrategy(sar, assignOwner);
        
        strategy.runEvaluate();
    }
    
    // NEW: Direct evaluate - use when already in @future context
    public static void evaluateDirect(Id caseId, Boolean assignOwner) {
        if (queuedIds.contains(caseId)) return;
        queuedIds.add(caseId);
        evaluate(caseId, assignOwner); // ← Calls directly, no @future
    }

}