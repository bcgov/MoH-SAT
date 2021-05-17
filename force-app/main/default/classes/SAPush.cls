public class SAPush implements Action {
    public void execute(SpecialAuthorityRequest sar, StepAction actionParams) {

        // Only push if case is approved and not already sent to pnet.
        if (sar.saCase.status =='Approved' && sar.saCase.Pushed_to_Pnet__c == false) {
            setEffectiveDate(sar);

            List<SAApprovalRequest> saaRequests = ODRIntegration.getSAApprovalRequests(sar);
            List<SAApprovalRequestResponse> saaResponses = postSAApprovalRequests(sar.saCase.Id, saaRequests);
            
            if (allValid(saaResponses)) {
                markPushedToPharmanet(sar);
            }

            setTerminationDate(sar, saaRequests);
        }
    }

    private List<SAApprovalRequestResponse> postSAApprovalRequests(Id caseId, List<SAApprovalRequest> saaRequests) {
        List<SAApprovalRequestResponse> saaResponses = new List<SAApprovalRequestResponse>();
            
        for(SAApprovalRequest saaRequest: saaRequests) {
            saaResponses.add(ODRIntegration.postSAApproval(caseId, saaRequest));
        }

        return saaResponses;
    }

    private Boolean allValid(List<SAApprovalRequestResponse> saaResponses) {
        for (SAApprovalRequestResponse res: saaResponses) {
            if (res.error != null) {
                return  false;
            }
        }
        return true;
    }

    private void setEffectiveDate(SpecialAuthorityRequest sar) {
        sar.saCase.Effective_Date__c = Date.today();
    }

    private void setTerminationDate(SpecialAuthorityRequest sar, List<SAApprovalRequest> saaRequests) {
        for (SAApprovalRequest saaRequest : saaRequests) {
            sar.saCase.Termination_Date__c = DateUtil.parseOdrDate(saaRequest?.saRecord?.terminationDate);
        }
    }

    private void markPushedToPharmanet(SpecialAuthorityRequest sar) {
        sar.saCase.Pushed_to_Pnet__c = true;
        sar.saCase.Pushed_to_Pnet_Date__c = DateTime.now();
    }
}