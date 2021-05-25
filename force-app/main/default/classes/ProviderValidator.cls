public class ProviderValidator implements Action {
    
    @TestVisible
    private Provider mockResult { get; set; }

    public void execute(SpecialAuthorityRequest sar, StepAction actionParams) {
        if (sar.saCase.Provider_Validated_Date__c != null) {
            return;
        }

        Provider p = callService(sar);

        if (p != null) {
            sar.saCase.Provider_Validated__c = p.verified;
            sar.saCase.Provider_Validated_Date__c = DateTime.now();
        }
    }

    private Provider callService(SpecialAuthorityRequest sar) {
        return Test.isRunningTest() ? mockResult : ODRIntegration.verifyCollegeInformation(sar.saCase.Id);
    }
}