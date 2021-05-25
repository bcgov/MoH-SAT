public with sharing class PharmanetPayload implements Action {
    public void execute(SpecialAuthorityRequest sar, StepAction actionParams) {
        sar.setEffectiveDate();

        sar.addSaApprovalRequest(actionParams);
    }
}
