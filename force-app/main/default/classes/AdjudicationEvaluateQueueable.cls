public class AdjudicationEvaluateQueueable implements Queueable, Database.AllowsCallouts {
    private Id caseId;
    private Boolean assignOwner;

    public AdjudicationEvaluateQueueable(Id caseId, Boolean assignOwner) {
        this.caseId = caseId;
        this.assignOwner = assignOwner;
    }

    public void execute(QueueableContext context) {
        if (caseId == null) {
            return;
        }
        try {
            AdjudicationService.evaluate(caseId, assignOwner);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR,
                'AdjudicationEvaluateQueueable failed for Case ' + caseId
                + ': ' + e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
}