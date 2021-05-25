public with sharing class PharmanetSubmission implements Action {

    @TestVisible
    private SAApprovalRequestResponse mockResult { get; set; }

    public void execute(SpecialAuthorityRequest sar, StepAction actionParams) {
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
            saaResponses.add(callService(caseId, saaRequest));
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

    private SAApprovalRequestResponse callService(Id caseId, SAApprovalRequest saaRequest) {
        return Test.isRunningTest() ? mockResult : ODRIntegration.postSAApproval(caseId, saaRequest);
    }
}