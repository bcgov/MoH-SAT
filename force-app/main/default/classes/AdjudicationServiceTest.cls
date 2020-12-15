@isTest
public class AdjudicationServiceTest {
    @TestSetup
    static void test_setup(){
        Group testGroup = new Group(Name='Test Group', Type='Queue');
        insert testGroup;
        
        system.runAs(new User(Id=UserInfo.getUserId())) {    
            insert new QueueSobject[] { 
                new QueueSObject(QueueId=testGroup.id, SObjectType='Case'), 
                new QueueSObject(QueueId=testGroup.id, SObjectType='Drug__c') 
            };
        }

        Drug__c drug = TestFactory.newDrug('Drug 1');
        drug.OwnerId = testGroup.Id;
        insert drug;

        Case saCase = TestFactory.newCase(drug, 'Test case 1');
        insert saCase;
    }

    @isTest
    static void test_evaluate() {
        SpecialAuthorityRequest sar = SpecialAuthorityRequest.build(queryCase('Test case 1'));
        AdjudicationStrategyFactory.mockStrategy = new MockAdjudicationStrategy(sar);
                
        AdjudicationService.evaluate(sar.saCase);
        system.assertEquals('Mock strategy executed', sar.saCase.Subject);
        
        AdjudicationService.evaluate(sar.saCase.Id);
        system.assertEquals('Mock strategy executed', sar.saCase.Subject);
    }

    @isTest
    static void test_evaluate_set_owner() {
        Drug__c drug = [select Id, OwnerId from Drug__c where Name = 'Drug 1' limit 1][0];
        
        SpecialAuthorityRequest sar = SpecialAuthorityRequest.build(queryCase('Test case 1'));
        AdjudicationStrategyFactory.mockStrategy = new MockAdjudicationStrategy(sar);
        
        AdjudicationService.evaluate(sar.saCase, true);
        system.assertEquals(drug.OwnerId, sar.saCase.OwnerId);
        
        AdjudicationService.evaluate(sar.saCase.Id, true);
        system.assertEquals(drug.OwnerId, sar.saCase.OwnerId);
    }

    private class MockAdjudicationStrategy extends AdjudicationStrategy {
        public MockAdjudicationStrategy(SpecialAuthorityRequest sar) {
            super(sar);
        }

        public override void evaluate() {
            sar.saCase.Subject = 'Mock strategy executed';
        }
    }

    private static Case queryCase(String subject) {
        return [
            select 
                Id, RecordTypeId, Drug__c, ContactId, Provider__c, IsClosed, Subject
            from Case
            where Subject = :subject
            limit 1
        ][0];
    }
}
