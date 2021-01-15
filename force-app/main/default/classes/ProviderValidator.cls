public abstract class ProviderValidator implements AdjudicationAction {
    public void execute(SpecialAuthorityRequest sar) {
        if (sar.saCase.Provider_Validated_Date__c != null) {
            // Skip
            return;
        }

        Provider p = ODRIntegration.verifyCollegeInformation(sar.provider.Id, false);

        sar.saCase.Provider_Validated__c = p.verified;
        sar.saCase.Provider_Validated_Date__c = DateTime.now();
    }
}