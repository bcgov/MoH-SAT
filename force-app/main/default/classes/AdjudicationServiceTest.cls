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
    static void test_adjudication_strategy() {
        AdjudicationStrategy strategy = AdjudicationService.buildAdjudicationStrategy(null);
        system.assert((Object) strategy instanceof AdjudicationStrategy);

        strategy = AdjudicationService.buildAdjudicationStrategy('Criteria');
        system.assert(strategy instanceof CriteriaBasedAdjudication);

        strategy = AdjudicationService.buildAdjudicationStrategy('Apex');
        system.assert(strategy instanceof ApexBasedAdjudication);
    }

    @isTest
    static void test_evaluate() {
        AdjudicationService.ADJUDICATION_STRATEGY = new MockAdjudicationStrategy();
        
        Case saCase = queryCase('Test case 1');
                
        AdjudicationService.evaluate(saCase);
        system.assertEquals('Mock strategy executed', saCase.Description);
        
        AdjudicationService.evaluate(saCase.Id);
        system.assertEquals('Mock strategy executed', saCase.Description);
    }

    @isTest
    static void test_evaluate_set_owner() {
        AdjudicationService.ADJUDICATION_STRATEGY = new MockAdjudicationStrategy();

        Drug__c drug = [select Id, OwnerId from Drug__c where Name = 'Drug 1' limit 1][0];
        Case saCase = queryCase('Test case 1');
        
        AdjudicationService.evaluate(saCase, true);
        system.assertEquals(drug.OwnerId, saCase.OwnerId);
        
        AdjudicationService.evaluate(saCase.Id, true);
        system.assertEquals(drug.OwnerId, saCase.OwnerId);
    }

    private class MockAdjudicationStrategy extends AdjudicationStrategy {
        public override void evaluate(SpecialAuthorityRequest sar) {
            sar.saCase.Description = 'Mock strategy executed';
        }
    }

    private static Case queryCase(String subject) {
        return [
            select 
                Id, RecordTypeId, Drug__c, ContactId, Provider__c, IsClosed
            from Case
            where Subject = :subject
            limit 1
        ][0];
    }
}
