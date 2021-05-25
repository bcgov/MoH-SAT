@isTest
public class AdjudicationStrategyTest {
    
    @TestSetup
    static void test_setup(){
        Drug__c drug = TestFactory.newDrug('Drug 1');
        insert drug;

        Case saCase = TestFactory.newCase(drug, 'Test case 1');
        insert saCase;
    }

    private static Drug__c queryDrug(String name) {
        return [select Id, Name, Pre_Adjudication_Apex__c, Post_Adjudication_Apex__c from Drug__c where Name = :name limit 1][0];
    }

    private static Case queryCase(String subject) {
        return [select Id, Subject from Case where Subject = :subject limit 1][0];
    }
}
