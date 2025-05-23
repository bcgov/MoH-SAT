public with sharing class Adjudication implements Action {
    public ActionResult execute(SpecialAuthorityRequest sar, StepAction actionParams) {
        sar.saCase.Status = actionParams.adjudicationStatus;
        sar.saCase.Auto_Adjudicated_Date__c = Datetime.now();

        return new ActionResult();
    }
}