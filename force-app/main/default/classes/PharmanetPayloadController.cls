public with sharing class PharmanetPayloadController {

    @AuraEnabled
    public static void markPushedToPharmanet(Id recordId) {
        Case record = new Case();
        record.Id = recordId;
        record.Pushed_to_Pnet__c = true;
        record.Pushed_to_Pnet_Date__c = Datetime.now();
        update record;
    }

    @AuraEnabled(cacheable=true)
    public static List<SAApprovalRequest> getPnetSars(Id recordId) {
        SpecialAuthorityRequest sar = SpecialAuthorityRequest.build(recordId);
        return OdrIntegration.getSAApprovalRequests(sar);
    }

    @AuraEnabled
    public static void submitSinglePnetSar(Id caseId, SAApprovalRequest pnetSa) {
        SAApprovalRequestResponse saaResponse = OdrIntegration.postSAApproval(caseId, pnetSa);

        Boolean isError = saaResponse.error != null;
        
        if (isError) {
            String errorMessage = String.format('[{0}] {1}.', new String[] {
                String.isBlank(pnetSa.saRecord.specialItem.din) ? 
                    pnetSa.saRecord.specialItem.rdp : 
                    pnetSa.saRecord.specialItem.din, 
                saaResponse.error.errorMessage
            });

            throw new AuraHandledException(errorMessage);
        }
    }
}
