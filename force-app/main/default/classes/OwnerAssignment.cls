public with sharing class OwnerAssignment implements Action {
    public ActionResult execute(SpecialAuthorityRequest sar, StepAction actionParams) {
        sar.saCase.OwnerId = actionParams.ownerId;

        return new ActionResult();
    }
}
