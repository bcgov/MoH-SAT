@isTest
public with sharing class StepBuilderTest {

    @isTest
    static void test_build_queried_steps() {
        Drug__c drug = TestFactory.newDrug('Test Drug 1');
        insert drug;

        Step__c step1 = TestFactory.newStep(drug, 1, 'AND(1)');
        Step__c step2 = TestFactory.newStep(drug, 2, 'AND(1)');
        insert new Step__c[] {step1, step2};

        Step_Criteria__c sc1 = TestFactory.newCriteria(step1, 1, 'Case', 'Origin', null, 'equals', 'Fax');
        Step_Criteria__c sc2 = TestFactory.newCriteria(step2, 1, 'Case', 'Origin', null, 'equals', 'Fax');
        insert new Step_Criteria__c[] {sc1, sc2};

        Step_Action__c sa1 = TestFactory.newStepAction(step1, 1, (Id) UserInfo.getUserId());
        Step_Action__c sa2 = TestFactory.newStepAction(step2, 1, (Id) UserInfo.getUserId());
        insert new Step_Action__c[] { sa1, sa2 };

        Test.startTest();
        List<Step> steps = StepBuilder.build(querySteps(drug.Id));
        Test.stopTest();

        system.assertEquals(2, steps.size());
        system.assertEquals(1, steps[0].order);
        system.assertEquals(2, steps[1].order);        
        system.assertEquals(1, steps[0].criteria.size());
        system.assertEquals(1, steps[1].criteria.size());
        system.assertEquals(1, steps[0].actions.size());
        system.assertEquals(1, steps[1].actions.size());
    }

    @isTest
    static void test_build_provider_validation_step() {
        Step step = StepBuilder.buildProviderValidationStep();
        system.assertEquals('Auto Validate Provider', step.title);
        system.assertEquals(1, step.actions.size());
        system.assertEquals(StepAction.ActionType.PROVIDER_VALIDATION, step.actions[0].actionType);
    }

    @isTest
    static void test_build_patient_validation_step() {
        Step step = StepBuilder.buildPatientValidatorStep();
        system.assertEquals('Auto Validate Patient', step.title);
        system.assertEquals(1, step.actions.size());
        system.assertEquals(StepAction.ActionType.PATIENT_VALIDATION, step.actions[0].actionType);
    }

    @isTest
    static void test_build_pharmanet_submission_step() {
        Step step = StepBuilder.buildPharmanetSubmissionStep();
        system.assertEquals('Auto Submit to Pharmanet', step.title);
        system.assertEquals(1, step.actions.size());
        system.assertEquals(StepAction.ActionType.PHARMANET_SUBMISSION, step.actions[0].actionType);
    }

    @isTest
    static void test_build_owner_assignemnt_step() {
        Id queueId = TestFactory.newId(Group.getSobjectType());
        Step step = StepBuilder.buildOwnerAssignmentStep(queueId);
        system.assertEquals('Default Owner Assignment', step.title);
        system.assertEquals(1, step.actions.size());
        system.assertEquals(StepAction.ActionType.OWNER_ASSIGNMENT, step.actions[0].actionType);
        system.assertEquals(queueId, step.actions[0].ownerId);
    }

    private static List<Step__c> querySteps(Id drugId) {
        return [
            select
                Id, Name, External_ID__c, Order__c, Always_Run__c, Criteria_Logic__c, 
                (
                    select 
                        Order__c, Object_Name__c, Field_Name__c, Question_ID__c, Operator__c,
                        String_Value__c, Boolean_Value__c, Decimal_Value__c, Date_Value__c, Datetime_Value__c
                    from Step_Criteria__r
                    order by Order__c asc
                ),
                (
                    select 
                        Order__c, OwnerId, RecordTypeId,
                        Adjudication_Status__c, Days_Supply__c, Excluded_Plans__c, Justification_Codes__c, 
                        Key_Type__c, Pharmanet_Code__c, Price_Percent__c, SA_Type__c,
                        Duration__c, Duration_Unit__c
                    from Step_Actions__r
                    order by Order__c asc
                )
            from Step__c
            where Drug__c = :drugId
            order by Order__c asc
        ];
    }
}
