public class SAPush implements AdjudicationAction {
    public void execute(SpecialAuthorityRequest sar) {

        // TODO: Business rules

        SAApprovalRequestResponse saarr = ODRIntegration.postSAApproval(sar);

        if (saarr.error != null) {
            // Success
            sar.saCase.Pushed_to_Pnet__c = true;
            sar.saCase.Pushed_to_Pnet_Date__c = DateTime.now();
        }
    }
}