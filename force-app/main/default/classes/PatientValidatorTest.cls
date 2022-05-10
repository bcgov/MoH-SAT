@isTest
public class PatientValidatorTest {
    @isTest
    public static void PatientValidatorTest() {
        SpecialAuthorityRequest sar = TestFactory.newSpecialAuthorityRequest();

        PatientValidator action = new PatientValidator();
        action.mockResult = new Patient();
        action.mockResult.verified = true;
        
        Test.startTest();
        action.execute(sar, null);
        Test.stopTest();

        system.assertEquals(true, sar.saCase.Patient_Validated__c);
        system.assert(null != sar.saCase.Patient_Validated_Date__c);
    }
  }