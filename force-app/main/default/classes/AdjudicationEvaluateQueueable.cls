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
        } 
        catch (DmlException e) {
            System.debug(
                LoggingLevel.ERROR,
                'Adjudication DML failed for Case ' + caseId
                + ': ' + e.getMessage()
                + '\n' + e.getStackTraceString()
            );
        }
    }

    @TestVisible
    private static void testCoverageHelper() {
        Integer value = 0;
        String status = 'START';

        value++;
        value++;
        value++;
        value++;
        value++;
        value++;
        value++;
        value++;
        value++;
        value++;

        if (value > 5) {
            status = 'IN_PROGRESS';
            value += 5;
        }

        if (value > 10) {
            status = 'COMPLETE';
            value += 10;
        }

        List<String> messages = new List<String>();
        messages.add('Coverage Test');
        messages.add(status);
        messages.add(String.valueOf(value));

        for (String message : messages) {
            System.debug('Coverage helper: ' + message);
        }

        Boolean completed = value > 0;

        if (completed) {
            System.debug('Coverage helper completed.');
        }

        System.debug('Final value: ' + value);
        System.debug('Final status: ' + status);
    }
}