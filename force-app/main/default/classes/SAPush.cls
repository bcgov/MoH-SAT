public class SAPush implements Action {
    public void execute(SpecialAuthorityRequest sar, StepAction actionParams) {
        system.debug('EXEC: Push to pharmanet');

        if (sar.saCase.status =='Approved' && sar.saCase.Pushed_to_Pnet__c == false) {
            List<SAApprovalRequestResponse> saaResponses = postSAApprovalRequests(sar.saCase.Id, sar.saApprovalRequests);
            
            if (allValid(saaResponses)) {
                sar.setPushedToPharmanet();
            }

            sar.setTerminationDate();
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
}