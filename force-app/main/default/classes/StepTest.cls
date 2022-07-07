@IsTest
public with sharing class StepTest {

    @isTest
    static void test_constructor() {
        List<StepCriteria> criterias = new List<StepCriteria>();
        criterias.add(newCriteria(1));
        criterias.add(newCriteria(2));

        Step obj = new Step(
            10, 
            'Test title',
            false,
            'AND(1,2)',
            criterias,
            new StepAction[]{}
        );

        system.assertEquals(10, obj.order);
        system.assertEquals('Test title', obj.title);
        system.assertEquals(false, obj.alwaysRun);
        system.assertEquals('AND(1,2)', obj.criteriaLogic);
        system.assertEquals(false, obj.criteriaMap.isEmpty());
        system.assert(obj.criteriaMap.containsKey(1));
        system.assert(obj.criteriaMap.containsKey(2));
    }

    @isTest
    static void test_constructor_title(){
        Step obj = new Step('Test title');

        system.assertEquals('Test title', obj.title);
        system.assertEquals(true, obj.alwaysRun);
        system.assertEquals(null, obj.order);
        system.assertEquals(null, obj.criteriaLogic);
        system.assertEquals(true, obj.criteriaMap.isEmpty());
        system.assertEquals(true, obj.actions.isEmpty());
        system.assertEquals(true, obj.criteria.isEmpty());
    }

    @isTest
    static void test_executable_always_run() {
        Step obj = new Step('Test title');
        Boolean result = obj.executable(new Case(), new Request_Detail__c[]{});
        system.assertEquals(true, result);
    }

    @isTest
    static void test_executable_criteria_run_positive() {
        List<StepCriteria> criterias = new List<StepCriteria>();
        criterias.add(new StepCriteria(TestFactory.newCriteria(new Step__c(), 1, 'Case', 'Origin', null, 'equals', 'Fax')));
        criterias.add(new StepCriteria(TestFactory.newCriteria(new Step__c(), 2, 'Request_Detail__c', 'String_Value__c', 'test.question.id', 'equals', 'Test string')));

        Step obj = new Step(10, 'Test title', false, 'AND(1,2)', criterias, new StepAction[]{});

        Case saCase = TestFactory.newCase(new Drug__c(), 'Test subject');
        saCase.Origin = 'Fax';

        Request_Detail__c rd = TestFactory.newRequestDetail(saCase, 'test.question.id', 'Test string');

        Test.startTest();
        Boolean result = obj.executable(saCase, new Request_Detail__c[]{rd});
        Test.stopTest();
        
        system.assertEquals(true, result);
    }

    @isTest
    static void test_executable_criteria_run_negative() {
        List<StepCriteria> criterias = new List<StepCriteria>();
        criterias.add(new StepCriteria(TestFactory.newCriteria(new Step__c(), 1, 'Case', 'Origin', null, 'equals', 'Fax')));

        Step obj = new Step(10, 'Test title', false, 'AND(1)', criterias, new StepAction[]{});

        Case saCase = TestFactory.newCase(new Drug__c(), 'Test subject');
        saCase.Origin = 'Not fax'; // Negates above criteria

        Test.startTest();
        Boolean result = obj.executable(saCase, new Request_Detail__c[]{});
        Test.stopTest();
        
        system.assertEquals(false, result);
    }

    private static StepCriteria newCriteria(Integer order) {
        return new StepCriteria(TestFactory.newCriteria(
            new Step__c(),
            order,
            'Case',
            'Origin',
            null,
            'equals',
            'Received'
        ));
    }
}