public with sharing class PharmanetSubmission implements Action {
    public void execute(SpecialAuthorityRequest sar, StepAction actionParams) {
        system.debug('EXEC: Pharmanet Submission.');
        
        sar.setEffectiveDate();

        sar.addSaApprovalRequest(actionParams);
    }
}
