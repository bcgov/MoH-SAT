@IsTest
public class SpecialAuthorityRequestTest {

    @isTest
    static void test_has_drug() {
        SpecialAuthorityRequest sar = new SobjectSarBuilder(
            new Drug__c(), 
            new Account(), 
            new Account(), 
            new Case(), 
            new List<Request_Detail__c>(),
            new List<ContentVersion>()
        ).build();
        
        system.assertEquals(true, sar.hasDrug());
        
        sar = new SobjectSarBuilder(
            null, 
            new Account(), 
            new Account(), 
            new Case(), 
            new List<Request_Detail__c>(),
            new List<ContentVersion>()
        ).build();

        system.assertEquals(false, sar.hasDrug());
    }
}
