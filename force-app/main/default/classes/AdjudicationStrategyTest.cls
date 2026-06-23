@isTest
public class AdjudicationStrategyTest {
    
    @TestSetup
    static void setupData() {
        Drug__c drug1 = TestFactory.newDrug('Drug 1');
        drug1.Auto_Validate_Patient__c = true;
        drug1.Auto_Validate_Provider__c = true;
        drug1.Auto_Push_to_Pharmanet__c = true;
        insert drug1;

        Drug__c drug2 = TestFactory.newDrug('Drug 2');
        drug2.Auto_Validate_Patient__c = false;
        drug2.Auto_Validate_Provider__c = false;
        drug2.Auto_Push_to_Pharmanet__c = false;
        insert drug2;

        Case case1 = TestFactory.newCase(drug1, 'Test Case 1');
        insert case1;

        Case case2 = TestFactory.newCase(drug2, 'Test Case 2');
        insert case2;
    }

    private static Case getCaseBySubject(String subject) {
        return [
            SELECT Id, Subject
            FROM Case
            WHERE Subject = :subject
            LIMIT 1
        ];
    }

    @isTest
    static void test_constructor_with_auto_flags_enabled() {
        Case saCase = getCaseBySubject('Test Case 1');
        SpecialAuthorityRequest sar = new SobjectSarBuilder(saCase.Id).build();

        Test.startTest();
        AdjudicationStrategy strategy = new AdjudicationStrategy(sar, true);
        Test.stopTest();

        System.assertNotEquals(null, strategy);
        System.assertEquals(sar, strategy.sar);
        System.assertEquals(true, strategy.assignOwner);
        System.assertEquals(true, strategy.autoValidatePatient);
        System.assertEquals(true, strategy.autoValidateProvider);
        System.assertEquals(true, strategy.autoPushToPharmanet);
        System.assertEquals(true, strategy.patientValidated);
        System.assertEquals(true, strategy.providerValidated);
        System.assertNotEquals(null, strategy.steps);
        System.assertEquals(0, strategy.steps.size());
    }

    @isTest
    static void test_constructor_with_auto_flags_disabled() {
        Case saCase = getCaseBySubject('Test Case 2');
        SpecialAuthorityRequest sar = new SobjectSarBuilder(saCase.Id).build();

        Test.startTest();
        AdjudicationStrategy strategy = new AdjudicationStrategy(sar, false);
        Test.stopTest();

        System.assertEquals(false, strategy.assignOwner);
        System.assertEquals(false, strategy.autoValidatePatient);
        System.assertEquals(false, strategy.autoValidateProvider);
        System.assertEquals(false, strategy.autoPushToPharmanet);
        System.assertEquals(true, strategy.patientValidated);
        System.assertEquals(true, strategy.providerValidated);
    }

    @isTest
    static void test_validationSuccessful_default() {
        Case saCase = getCaseBySubject('Test Case 1');
        SpecialAuthorityRequest sar = new SobjectSarBuilder(saCase.Id).build();
        AdjudicationStrategy strategy = new AdjudicationStrategy(sar, true);

        Test.startTest();
        Boolean result = strategy.validationSuccessful();
        Test.stopTest();

        System.assertEquals(true, result);
    }

    @isTest
    static void test_unsuccessfulTarget_default() {
        Case saCase = getCaseBySubject('Test Case 1');
        SpecialAuthorityRequest sar = new SobjectSarBuilder(saCase.Id).build();
        AdjudicationStrategy strategy = new AdjudicationStrategy(sar, true);

        Test.startTest();
        String result = strategy.unsuccessfulTarget();
        Test.stopTest();

        System.assertEquals('', result);
    }

    @isTest
    static void test_onBeforeEvaluate() {
        Case saCase = getCaseBySubject('Test Case 1');
        SpecialAuthorityRequest sar = new SobjectSarBuilder(saCase.Id).build();
        AdjudicationStrategy strategy = new AdjudicationStrategy(sar, true);

        Test.startTest();
        strategy.onBeforeEvaluate();
        Test.stopTest();

        System.assertNotEquals(null, strategy.steps);
        System.assert(strategy.steps.size() >= 1, 'Expected at least one step from owner assignment.');
    }

    @isTest
    static void test_evaluate() {
        Case saCase = getCaseBySubject('Test Case 1');
        SpecialAuthorityRequest sar = new SobjectSarBuilder(saCase.Id).build();
        AdjudicationStrategy strategy = new AdjudicationStrategy(sar, true);

        Test.startTest();
        strategy.evaluate();
        Test.stopTest();

        System.assertNotEquals(null, strategy.steps);
    }

    @isTest
    static void test_onAfterEvaluate_autoPushEnabled() {
        Case saCase = getCaseBySubject('Test Case 1');
        SpecialAuthorityRequest sar = new SobjectSarBuilder(saCase.Id).build();
        AdjudicationStrategy strategy = new AdjudicationStrategy(sar, true);

        Test.startTest();
        strategy.onAfterEvaluate();
        Test.stopTest();

        System.assertNotEquals(null, strategy.steps);
        System.assert(strategy.steps.size() >= 1, 'Expected Pharmanet submission step when auto push is enabled.');
    }

    @isTest
    static void test_onAfterEvaluate_autoPushDisabled() {
        Case saCase = getCaseBySubject('Test Case 2');
        SpecialAuthorityRequest sar = new SobjectSarBuilder(saCase.Id).build();
        AdjudicationStrategy strategy = new AdjudicationStrategy(sar, false);

        Test.startTest();
        strategy.onAfterEvaluate();
        Test.stopTest();

        System.assertEquals(0, strategy.steps.size());
    }

    @isTest
    static void test_runEvaluate() {
        Case saCase = getCaseBySubject('Test Case 1');
        SpecialAuthorityRequest sar = new SobjectSarBuilder(saCase.Id).build();
        AdjudicationStrategy strategy = new AdjudicationStrategy(sar, true);

        Test.startTest();
        strategy.runEvaluate();
        Test.stopTest();

        System.assertNotEquals(null, strategy.steps);
        System.assert(strategy.steps.size() >= 1, 'Expected steps to be added during runEvaluate.');
    }

    @isTest
    static void test_print_does_not_fail() {
        Case saCase = getCaseBySubject('Test Case 1');
        SpecialAuthorityRequest sar = new SobjectSarBuilder(saCase.Id).build();
        AdjudicationStrategy strategy = new AdjudicationStrategy(sar, true);

        Test.startTest();
        strategy.print();
        Test.stopTest();

        System.assertEquals(true, true);
    }

    @isTest
    static void test_adjudication_exception_type() {
        Test.startTest();
        AdjudicationStrategy.AdjudicationException ex =
            new AdjudicationStrategy.AdjudicationException('Test message');
        Test.stopTest();

        System.assertEquals('Test message', ex.getMessage());
    }
}