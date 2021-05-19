public with sharing class OwnerAssignment implements Action {
    public void execute(SpecialAuthorityRequest sar, StepAction actionParams) {
        sar.saCase.OwnerId = actionParams.ownerId;
    }
}
