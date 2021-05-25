public class ProviderValidator implements Action {
    public void execute(SpecialAuthorityRequest sar, StepAction actionParams) {
        if (sar.saCase.Provider_Validated_Date__c != null) {
            return;
        }

        Provider p = ODRIntegration.verifyCollegeInformation(sar.saCase.Id);

        if (p != null) {
            sar.saCase.Provider_Validated__c = p.verified;
            sar.saCase.Provider_Validated_Date__c = DateTime.now();
        }
    }
}