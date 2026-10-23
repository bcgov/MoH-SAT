public class AdjudicationEvaluateQueueable implements Queueable, Database.AllowsCallouts {
    private Id caseId;
    private Boolean assignOwner;
    private static final String FAILURE_MSG = 'Adjudication failed for Case ';

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
         catch (DmlException e) {
            logFailure(e);
         	throw e;
         }
        catch (QueryException  e) {
            logFailure(e);
          	throw e;
         }
        catch (Exception e) {
            logFailure(e);
            throw e;
        }
    }
    
    private void logFailure(Exception e) {
        System.debug(LoggingLevel.ERROR,FAILURE_MSG + caseId + ' (' + e.getTypeName() + '): ' + e.getMessage() + '\n' + e.getStackTraceString());
    }
}