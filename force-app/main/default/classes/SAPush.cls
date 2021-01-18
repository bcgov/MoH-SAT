public class SAPush implements AdjudicationAction {
    public void execute(SpecialAuthorityRequest sar) {

        // TODO: Business rules

        Boolean boolean_success = ODRIntegration.postSAApproval(sar);

        if (boolean_success) {
            // Success
            sar.saCase.Pushed_to_Pnet__c = true;
            sar.saCase.Pushed_to_Pnet_Date__c = DateTime.now();
        }
    }
}