@isTest
public class SAApprovalHistoryResponseTest {
    @isTest
    public static void SAApprovalHistoryResponseTest() {
      SAApprovalHistoryResponse res = new SAApprovalHistoryResponse();
      res.requestUUID = '';
      res.clientName = '';
      res.totalRecords = 0;
      res.saRecords = new List<SAApprovalHistoryResponse.SARecords>();

      SAApprovalHistoryResponse.SARecords sar = new SAApprovalHistoryResponse.SARecords();
      sar.createdBy = '';
      sar.effectiveDate = '';
      sar.excludedPlans.add('123');
      sar.justificationCodes.add('123');
      sar.maxDaysSupply = 25;
      sar.maxPricePct = 100;
      sar.specAuthType = '';
      sar.terminationDate = '';

      sar.specialItem = new SAApprovalHistoryResponse.SpecialItem();
      sar.specialItem.din = '';
      sar.specialItem.rdp = '';
      sar.specialItem.text = '';
      sar.specialItem.itemDescription = '';

      sar.saRequester = new SAApprovalHistoryResponse.SARequester();
      sar.saRequester.practIdRef = '';
      sar.saRequester.practId = '';
      sar.saRequester.decCode = '';
      sar.saRequester.pharmacyID = '';

      CalloutResponse cor = new CalloutResponse();
      cor.errorCode = 200;
      cor.errorMessage = '';

      res.error = cor;
    }
}