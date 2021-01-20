public class SAPush implements AdjudicationAction {
    public void execute(SpecialAuthorityRequest sar) {

        List<SAApprovalRequestResponse> responses = ODRIntegration.postSAApproval(sar);

        Boolean bAllValid = true;
        for (SAApprovalRequestResponse res: responses) {
            // Need to be all created!
            if (res.error.errorCode != 201) {
                bAllValid = false;
            }
        }

        if (bAllValid) {
            // Success
            sar.saCase.Pushed_to_Pnet__c = true;
            sar.saCase.Pushed_to_Pnet_Date__c = DateTime.now();
        }
    }
}