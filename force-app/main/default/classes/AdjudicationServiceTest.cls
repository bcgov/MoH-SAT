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

        SaSettings.disableTriggers();

        Case saCase = TestFactory.newCase(drug, 'Test case 1');
        insert saCase;
        
        SaSettings.enableTriggers();
    }

    @isTest
    static void test_evaluate() {
        SpecialAuthorityRequest sar = new SobjectSarBuilder(queryCase('Test case 1').Id).build();
        AdjudicationService.evaluate(sar.saCase.Id);   
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