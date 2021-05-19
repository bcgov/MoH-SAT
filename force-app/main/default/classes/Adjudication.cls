public with sharing class Adjudication implements Action {
    public void execute(SpecialAuthorityRequest sar, StepAction actionParams) {
        sar.saCase.Status = actionParams.adjudicationStatus;
    }
}
