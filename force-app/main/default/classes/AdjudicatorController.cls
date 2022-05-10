public with sharing class AdjudicatorController {
    
    @AuraEnabled
    public static void runAdjudicator(Id caseId, Boolean assignOwner) {
        try {
            AdjudicationService.evaluate(caseId, assignOwner);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
}
