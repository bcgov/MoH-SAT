@isTest
public class ApexBasedAdjudicationTest {
    
    @TestSetup
    static void test_setup(){
        Drug__c drug = TestFactory.newDrug('Drug 1');
        drug.Adjudication_Strategy__c = 'Apex';
        insert drug;

        Case saCase = TestFactory.newCase(drug, 'Test case 1');
        insert saCase;
    }

    @isTest
    static void test_nothing() {
        SpecialAuthorityRequest sar = SpecialAuthorityRequest.build(queryCase('Test case 1').Id);
        
        new ApexBasedAdjudication(sar).evaluate();
    }

    private static Case queryCase(String subject) {
        return [select Id, Subject from Case where Subject = :subject limit 1][0];
    }
}
