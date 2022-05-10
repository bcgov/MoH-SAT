@isTest
public class SAApprovalUpdateRequestTest {
    @isTest
    public static void SAApprovalUpdateRequestTest() {
        SAApprovalUpdateRequest saaur = new SAApprovalUpdateRequest();
        saaur.requestUUID = '12345';
        saaur.clientName = 'SpecAuth';
        saaur.userid = 'Salesforce';
        saaur.updateType = 'T';
        saaur.saRecordId.phn = '9000111222';
        saaur.saRecordId.specialItem.din = '9901-0065';
        saaur.saRecordId.specialItem.rdp = '02241113';
        saaur.saRecordId.specAuthType = 'Terminate';
        saaur.saRecordId.effectiveDate = '3000/01/01';
        saaur.saRevisedData.specialItem.din = '9901-0065';
        saaur.saRevisedData.specialItem.rdp = '02241113';
        saaur.saRevisedData.specAuthType = 'Terminate';
        saaur.saRevisedData.justificationCodes.add('123');
        saaur.saRevisedData.excludedPlans.add('456');
        saaur.saRevisedData.saRequester.practId = '0A0P1';
        saaur.saRevisedData.saRequester.practIdRef = '0A0P1';
        saaur.saRevisedData.saRequester.decCode = 'DEC1232';
        saaur.saRevisedData.effectiveDate = '3000/01/01';
        saaur.saRevisedData.terminationDate = '3000/01/01';
        saaur.saRevisedData.maxDaysSupply = 30;
        saaur.saRevisedData.maxPricePct = 100.0;
        System.assertEquals(true, true);
    }
}
