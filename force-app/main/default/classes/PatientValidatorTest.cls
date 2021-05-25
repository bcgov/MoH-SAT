@isTest
public class PatientValidatorTest {
    @isTest
    public static void PatientValidatorTest() {
        Case saCase = TestFactory.newCase(new Drug__c(), 'Test case 1');
        insert saCase;

        SpecialAuthorityRequest sar = new SobjectSarBuilder(saCase.Id).build();

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