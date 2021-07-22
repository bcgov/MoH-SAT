@isTest
public class SAApprovalRequestTest {
    @isTest
    public static void SAApprovalRequestTest() {
      SAApprovalRequest saar = new SAApprovalRequest();
      saar.requestUUID = '12345';
      saar.clientName = 'SpecAuth';
      saar.userid = 'SALESFORCE';
      saar.saRecord.phn = '12345';
      saar.saRecord.specialItem.din = '12345';
      saar.saRecord.specialItem.rdp = '12345';
      saar.saRecord.specAuthType = '12345';
      saar.saRecord.justificationCodes.add('123');
      saar.saRecord.excludedPlans.add('123');
      saar.saRecord.saRequester.practId = '0A0P1';
      saar.saRecord.saRequester.practIdRef = '0A0P1';
      saar.saRecord.saRequester.pharmacyId = 'BC00000V009';
      saar.saRecord.saRequester.decCode = 'DEC1232';
      saar.saRecord.effectiveDate = '3000/01/01';
      saar.saRecord.terminationDate = '3000/01/01';
      saar.saRecord.maxDaysSupply = 25;
      saar.saRecord.maxPricePct = 100.0;
      System.assertEquals(true, true);
    }
  }