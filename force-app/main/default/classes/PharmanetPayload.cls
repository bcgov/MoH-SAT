public with sharing class PharmanetPayload implements Action {
    public void execute(SpecialAuthorityRequest sar, StepAction actionParams) {
        system.debug('EXEC: Pharmanet Payload.');
        
        sar.setEffectiveDate();

        sar.addSaApprovalRequest(actionParams);
    }
}
