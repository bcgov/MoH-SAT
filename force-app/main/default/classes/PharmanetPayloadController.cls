public with sharing class PharmanetPayloadController {

    @TestVisible
    private static SAApprovalRequestResponse mockSaaResponse;

    @AuraEnabled
    public static void markPushedToPharmanet(Id recordId) {
        Case record = new Case();
        record.Id = recordId;
        record.Pushed_to_Pnet__c = true;
        record.Pushed_to_Pnet_Date__c = Datetime.now();
        update record;
    }

    @AuraEnabled
    public static List<SAApprovalRequest> getPnetSars(Id recordId) {
        SpecialAuthorityRequest sar = SpecialAuthorityRequest.build(recordId);
        return OdrIntegration.getSAApprovalRequests(sar);
    }

    @AuraEnabled
    public static void submitSinglePnetSar(Id caseId, SAApprovalRequest pnetSa) {
        SAApprovalRequestResponse saaResponse = postSAAProval(caseId, pnetSa);

        if (hasError(saaResponse)) {
            throwError(pnetSa, saaResponse);
        }

        setTerminationDate(caseId, pnetSa?.saRecord?.terminationDate);
    }

    private static void setTerminationDate(Id caseId, String odrTerminationDate) {
        Case record = new Case();
        record.Id = caseId;
        record.Termination_Date__c = parseOdrDate(odrTerminationDate);
        update record;
    }

    private static Date parseOdrDate(String odrDateStr) {
        if (odrDateStr == null) return null;

        String[] terminationDateArr = odrDateStr.split('/');
        
        return Date.newInstance(
            Integer.valueOf(terminationDateArr[0]), 
            Integer.valueOf(terminationDateArr[1]), 
            Integer.valueOf(terminationDateArr[2])
        );
    }

    private static Boolean hasError(SAApprovalRequestResponse saaResponse) {
        return saaResponse.error != null
            && saaResponse.error.errorCode != 200 
            && saaResponse.error.errorCode != 201;
    }

    private static void throwError(SAApprovalRequest pnetSa, SAApprovalRequestResponse saaResponse) {
        SAApprovalRequest.SpecialItem item = pnetSa.saRecord.specialItem;

        String errorMessage = String.format('[{0}] {1}.', new String[] {
            String.isBlank(item.din) ? item.rdp : item.din, 
            saaResponse.error.errorMessage
        });

        throw new AuraHandledException(errorMessage);
    }

    private static SAApprovalRequestResponse postSAAProval(Id caseId, SAApprovalRequest pnetSa) {
        return Test.isRunningTest() ? mockSaaResponse : OdrIntegration.postSAApproval(caseId, pnetSa);
    }
}
