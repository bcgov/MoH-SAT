public with sharing class OwnerAssignment implements AdjudicationAction {
    public void execute(SpecialAuthorityRequest sar, StepAction actionParams) {
        system.debug('EXEC: Owner Assignment');
    }
}
