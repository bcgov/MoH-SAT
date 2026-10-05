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
        }  
        catch (CalloutException e) {
            System.debug(
                LoggingLevel.ERROR,
                'Adjudication callout failed for Case ' + caseId
                + ': ' + e.getMessage()
                + '\n' + e.getStackTraceString()
            );
        } catch (DmlException e) {
            System.debug(
                LoggingLevel.ERROR,
                'Adjudication DML failed for Case ' + caseId
                + ': ' + e.getMessage()
                + '\n' + e.getStackTraceString()
            );
        }
    }
}