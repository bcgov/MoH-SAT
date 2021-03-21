public with sharing class PharmanetPayloadController {

    @AuraEnabled
    public static void markAsPushedToPharmanet(Id recordId) {

    }

    @AuraEnabled(cacheable=true)
    public static List<SAApprovalRequest> getPnetSars(Id recordId) {
        SpecialAuthorityRequest sar = SpecialAuthorityRequest.build(recordId);
        return OdrIntegration.getSAApprovalRequests(sar);
    }

    @AuraEnabled
    public static void submitSinglePnetSar(Id caseId, SAApprovalRequest pnetSa) {
        pnetSa.requestUUID = OdrIntegration.getUUIDString();
        pnetSa.clientName = 'SpecAuth';
        pnetSa.userid = OdrIntegration.getUserIdentifier();

        CalloutResponse calloutResponseObject = OdrIntegration.sendRequestAndReturnBody(
            caseId,
            'callout:ODR_Credentials/odr/sat/pnetsa/saApproval',
            null,
            'POST',
            JSON.serialize(pnetSa),
            '3A'
        );

        if (calloutResponseObject.errorCode != 200 && calloutResponseObject.errorCode != 201) {
            String errorMessage = String.format('{0} ({1}).', new String[] {
                calloutResponseObject.errorMessage,
                String.isBlank(pnetSa.saRecord.specialItem.din) ? 
                pnetSa.saRecord.specialItem.rdp : 
                pnetSa.saRecord.specialItem.din 
            });

            throw new AuraHandledException(errorMessage);
        }
    }
}
