public with sharing class PharmanetPayload implements Action {
    public ActionResult execute(SpecialAuthorityRequest sar, StepAction actionParams) {
        sar.setEffectiveDate();

        sar.addSaApprovalRequest(actionParams);

        return new ActionResult();
    }
}
