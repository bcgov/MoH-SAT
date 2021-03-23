public with sharing class AdjudicatorController {
    
    @AuraEnabled
    public static void runAdjudicator(Id caseId) {
        try {
            AdjudicationService.evaluate(caseId, false);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
}
