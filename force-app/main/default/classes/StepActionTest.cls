@isTest
public with sharing class StepActionTest {
    @isTest
    static void test_construct_owner_assignment() {
        Id queueId = TestFactory.newId(Group.getSobjectType());
        StepAction action = new StepAction(queueId);
        system.assertEquals(StepAction.ActionType.OWNER_ASSIGNMENT, action.actionType);
        system.assertEquals(queueId, action.ownerId);
    }

    @isTest
    static void test_construct_full_owner_assignment_type() {
        Id queueId = TestFactory.newId(Group.getSobjectType());
        Step_Action__c record = TestFactory.newStepAction(new Step__c(), 1, queueId);
        StepAction action = new StepAction(record);
        system.assertEquals(StepAction.ActionType.OWNER_ASSIGNMENT, action.actionType);
        system.assertEquals(queueId, action.ownerId);
    }

    @isTest
    static void test_construct_full_adjudication_type() {
        String status = 'Approved';
        Step_Action__c record = TestFactory.newStepAction(new Step__c(), 1, status);
        StepAction action = new StepAction(record);
        system.assertEquals(StepAction.ActionType.ADJUDICATION, action.actionType);
        system.assertEquals(status, action.adjudicationStatus);
    }

    @isTest
    static void test_construct_full_pharmanet_payload_type() {
        Step_Action__c record = TestFactory.newStepAction(
            new Step__c(),
            1, 
            '9901-0001',
            'DIN',
            'B',
            100.0.doubleValue(),
            100,
            null,
            'Indefinite',
            'B;C;CN',
            '1;2;3'
        );

        StepAction action = new StepAction(record);
        system.assertEquals(StepAction.ActionType.PHARMANET_PAYLOAD, action.actionType);
        system.assertEquals('9901-0001', action.pharmanetCode);
    }

    @isTest
    static void test_is_owner_assignment() {
        StepAction action = new StepAction(TestFactory.newId(Group.getSobjectType()));
        system.assertEquals(true, action.isOwnerAssignment());
    }

    @isTest
    static void test_get_apex_class_adjudication() {
        StepAction action = new StepAction(StepAction.ActionType.ADJUDICATION);
        system.assertEquals(Adjudication.class, action.getApexClass());
    }

    @isTest
    static void test_get_apex_class_owner_assignment() {
        StepAction action = new StepAction(StepAction.ActionType.OWNER_ASSIGNMENT);
        system.assertEquals(OwnerAssignment.class, action.getApexClass());
    }

    @isTest
    static void test_get_apex_class_provider_validation() {
        StepAction action = new StepAction(StepAction.ActionType.PROVIDER_VALIDATION);
        system.assertEquals(ProviderValidator.class, action.getApexClass());
    }

    @isTest
    static void test_get_apex_class_patient_validation() {
        StepAction action = new StepAction(StepAction.ActionType.PATIENT_VALIDATION);
        system.assertEquals(PatientValidator.class, action.getApexClass());
    }

    @isTest
    static void test_get_apex_class_pharmanet_payload() {
        StepAction action = new StepAction(StepAction.ActionType.PHARMANET_PAYLOAD);
        system.assertEquals(PharmanetPayload.class, action.getApexClass());
    }

    @isTest
    static void test_get_apex_class_pharmanet_submission() {
        StepAction action = new StepAction(StepAction.ActionType.PHARMANET_SUBMISSION);
        system.assertEquals(PharmanetSubmission.class, action.getApexClass());
    }

    @isTest
    static void test_run_action() {
        StepAction action = new StepAction(StepAction.ActionType.OWNER_ASSIGNMENT);
        SpecialAuthorityRequest sar = TestFactory.newSpecialAuthorityRequest();
        
        system.assertEquals(false, action.executed);
        action.run(sar);
        system.assertEquals(true, action.executed);
    }
}
