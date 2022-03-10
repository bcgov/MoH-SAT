public class ProviderValidator implements Action {
    
    @TestVisible
    private Provider mockResult { get; set; }

    public ActionResult execute(SpecialAuthorityRequest sar, StepAction actionParams) {
        // if (sar.saCase.Provider_Validated_Date__c != null) {
        //     return;
        // }
        if (sar.saCase.Provider_Validated__c) {
            return new ActionResult().setValidationResult(true);
        }

        Provider p = callService(sar);

        if (p != null) {
            sar.saCase.Provider_Validated__c = p.verified;
            sar.saCase.Provider_Validated_Date__c = DateTime.now();
            return new ActionResult().setValidationResult(p.verified);
        }

        return new ActionResult().setValidationResult(false);
    }

    private Provider callService(SpecialAuthorityRequest sar) {
        return Test.isRunningTest() ? mockResult : ODRIntegration.verifyCollegeInformation(sar.saCase.Id);
    }
}