@isTest
public class ProviderValidatorTest {
    @isTest
    public static void ProviderValidatorTest() {
        SpecialAuthorityRequest sar = TestFactory.newSpecialAuthorityRequest();

        ProviderValidator action = new ProviderValidator();
        action.mockResult = new Provider();
        action.mockResult.verified = true;
        
        Test.startTest();
        action.execute(sar, null);
        Test.stopTest();

        system.assertEquals(true, sar.saCase.Provider_Validated__c);
        system.assert(null != sar.saCase.Provider_Validated_Date__c);
    }
}