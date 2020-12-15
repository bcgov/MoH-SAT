@isTest
public class AdjudicationCriteriaTest {


    @isTest
    static void test_construct_criteria_with_non_existing_field() {
        try {
            AdjudicationCriteria ac = new AdjudicationCriteria(TestFactory.newCriteria('Case', 'Random_Field__c', null, 'equals', 'Fax'));
            system.assert(false, 'An expected exception was not thrown.');
        } catch (AdjudicationCriteria.AdjudicationCriteriaException e) {
            system.assert(true);
        }
    }

    @isTest
    static void test_set_inapplicable_record_type() {
        AdjudicationCriteria ac = new AdjudicationCriteria(TestFactory.newCriteria('Case', 'Origin', null, 'equals', 'Fax'));
        Request_Detail__c record = new Request_Detail__c();
        system.assertEquals(false, ac.set(record).evaluate());
    }

    @isTest
    static void test_set_inapplicable_request_detail_question_id() {
        AdjudicationCriteria ac = new AdjudicationCriteria(TestFactory.newCriteria('Request_Detail__c', 'String_Value__c', 'data.diagnosis', 'equals', 'gerd'));
        Request_Detail__c record = new Request_Detail__c();
        record.Question_ID__c = 'different.question.id';
        system.assertEquals(false, ac.set(record).evaluate());
    }

    @isTest
    static void test_null_safe_request_detail_question_id() {
        AdjudicationCriteria ac = new AdjudicationCriteria(TestFactory.newCriteria('Request_Detail__c', 'String_Value__c', 'data.diagnosis', 'equals', 'gerd'));
        Request_Detail__c record = new Request_Detail__c();
        record.Question_ID__c = null;
        system.assertEquals(false, ac.set(record).evaluate());
    }

    @isTest
    static void test_string_equals() {
        AdjudicationCriteria ac = new AdjudicationCriteria(TestFactory.newCriteria('Case', 'Origin', null, 'equals', 'Fax'));
        Case record = new Case();
        record.Origin = 'Fax';
        system.assertEquals(true, ac.set(record).evaluate());
        
        record.Origin = 'Email';
        system.assertEquals(false, ac.set(record).evaluate());
    }

    @isTest
    static void test_string_not_equals() {
        AdjudicationCriteria ac = new AdjudicationCriteria(TestFactory.newCriteria('Case', 'Origin', null, 'not equal to', 'Fax'));
        Case record = new Case();
        record.Origin = 'Fax';
        system.assertEquals(false, ac.set(record).evaluate());
        
        record.Origin = 'Email';
        system.assertEquals(true, ac.set(record).evaluate());
    }

    @isTest
    static void test_string_starts_with() {
        AdjudicationCriteria ac = new AdjudicationCriteria(TestFactory.newCriteria('Request_Detail__c', 'String_Value__c', 'question.id', 'starts with', 'abc'));
        Request_Detail__c record = new Request_Detail__c();
        record.Question_ID__c = 'question.id';
        record.String_Value__c = 'abc-string-value-123';
        
        system.assertEquals(true, ac.set(record).evaluate());
        
        record.String_Value__c = 'def-string-value-123';
        system.assertEquals(false, ac.set(record).evaluate());
    }

    @isTest
    static void test_string_contains() {
        AdjudicationCriteria ac = new AdjudicationCriteria(TestFactory.newCriteria('Request_Detail__c', 'String_Value__c', 'question.id', 'contains', 'abc-string'));
        Request_Detail__c record = new Request_Detail__c();
        record.Question_ID__c = 'question.id';

        record.String_Value__c = 'abc-string-value-123';        
        system.assertEquals(true, ac.set(record).evaluate());
        
        record.String_Value__c = 'def-string-value-123';
        system.assertEquals(false, ac.set(record).evaluate());
    }

    @isTest
    static void test_string_does_not_contain() {
        AdjudicationCriteria ac = new AdjudicationCriteria(TestFactory.newCriteria('Request_Detail__c', 'String_Value__c', 'question.id', 'does not contain', 'abc-string'));
        Request_Detail__c record = new Request_Detail__c();
        record.Question_ID__c = 'question.id';

        record.String_Value__c = 'abc-string-value-123';
        system.assertEquals(false, ac.set(record).evaluate());
        
        record.String_Value__c = 'def-string-value-123';
        system.assertEquals(true, ac.set(record).evaluate());
    }

    @isTest
    static void test_string_less_than() {
        AdjudicationCriteria ac = new AdjudicationCriteria(TestFactory.newCriteria('Request_Detail__c', 'String_Value__c', 'question.id', 'less than', 'banana'));
        Request_Detail__c record = new Request_Detail__c();
        record.Question_ID__c = 'question.id';

        record.String_Value__c = 'apple';
        system.assertEquals(true, ac.set(record).evaluate());
        
        record.String_Value__c = 'chocolate';
        system.assertEquals(false, ac.set(record).evaluate());
    }

    @isTest
    static void test_string_greater_than() {
        AdjudicationCriteria ac = new AdjudicationCriteria(TestFactory.newCriteria('Request_Detail__c', 'String_Value__c', 'question.id', 'greater than', 'banana'));
        Request_Detail__c record = new Request_Detail__c();
        record.Question_ID__c = 'question.id';

        record.String_Value__c = 'apple';
        system.assertEquals(false, ac.set(record).evaluate());
        
        record.String_Value__c = 'chocolate';
        system.assertEquals(true, ac.set(record).evaluate());
    }

    @isTest
    static void test_string_less_or_equal() {
        AdjudicationCriteria ac = new AdjudicationCriteria(TestFactory.newCriteria('Request_Detail__c', 'String_Value__c', 'question.id', 'less or equal', 'banana'));
        Request_Detail__c record = new Request_Detail__c();
        record.Question_ID__c = 'question.id';

        record.String_Value__c = 'apple';
        system.assertEquals(true, ac.set(record).evaluate());
        
        record.String_Value__c = 'banana';
        system.assertEquals(true, ac.set(record).evaluate());
        
        record.String_Value__c = 'chocolate';
        system.assertEquals(false, ac.set(record).evaluate());
    }

    @isTest
    static void test_string_greater_or_equal() {
        AdjudicationCriteria ac = new AdjudicationCriteria(TestFactory.newCriteria('Request_Detail__c', 'String_Value__c', 'question.id', 'greater or equal', 'banana'));
        Request_Detail__c record = new Request_Detail__c();
        record.Question_ID__c = 'question.id';

        record.String_Value__c = 'apple';
        system.assertEquals(false, ac.set(record).evaluate());
        
        record.String_Value__c = 'banana';
        system.assertEquals(true, ac.set(record).evaluate());
        
        record.String_Value__c = 'chocolate';
        system.assertEquals(true, ac.set(record).evaluate());
    }

    @isTest
    static void test_boolean_equal() {
        AdjudicationCriteria ac = new AdjudicationCriteria(TestFactory.newCriteria('Request_Detail__c', 'Boolean_Value__c', 'question.id', 'equals', true));
        Request_Detail__c record = new Request_Detail__c();
        record.Question_ID__c = 'question.id';

        record.Boolean_Value__c = true;
        system.assertEquals(true, ac.set(record).evaluate());
        
        record.Boolean_Value__c = false;
        system.assertEquals(false, ac.set(record).evaluate());
    }

    @isTest
    static void test_boolean_not_equal() {
        AdjudicationCriteria ac = new AdjudicationCriteria(TestFactory.newCriteria('Request_Detail__c', 'Boolean_Value__c', 'question.id', 'not equal to', true));
        Request_Detail__c record = new Request_Detail__c();
        record.Question_ID__c = 'question.id';

        record.Boolean_Value__c = true;
        system.assertEquals(false, ac.set(record).evaluate());
        
        record.Boolean_Value__c = false;
        system.assertEquals(true, ac.set(record).evaluate());
    }

    @isTest
    static void test_decimal_equals() {
        AdjudicationCriteria ac = new AdjudicationCriteria(TestFactory.newCriteria('Request_Detail__c', 'Decimal_Value__c', 'question.id', 'equals', 10.0));
        Request_Detail__c record = new Request_Detail__c();
        record.Question_ID__c = 'question.id';

        record.Decimal_Value__c = 10.0;
        system.assertEquals(true, ac.set(record).evaluate());
        
        record.Decimal_Value__c = 11.0;
        system.assertEquals(false, ac.set(record).evaluate());
    }

    @isTest
    static void test_decimal_not_equal_to() {
        AdjudicationCriteria ac = new AdjudicationCriteria(TestFactory.newCriteria('Request_Detail__c', 'Decimal_Value__c', 'question.id', 'not equal to', 10.0));
        Request_Detail__c record = new Request_Detail__c();
        record.Question_ID__c = 'question.id';

        record.Decimal_Value__c = 10.0;
        system.assertEquals(false, ac.set(record).evaluate());
        
        record.Decimal_Value__c = 11.0;
        system.assertEquals(true, ac.set(record).evaluate());
    }

    @isTest
    static void test_decimal_less_than() {
        AdjudicationCriteria ac = new AdjudicationCriteria(TestFactory.newCriteria('Request_Detail__c', 'Decimal_Value__c', 'question.id', 'less than', 10.0));
        Request_Detail__c record = new Request_Detail__c();
        record.Question_ID__c = 'question.id';

        record.Decimal_Value__c = 9.0;
        system.assertEquals(true, ac.set(record).evaluate());

        record.Decimal_Value__c = 10.0;
        system.assertEquals(false, ac.set(record).evaluate());
        
        record.Decimal_Value__c = 11.0;
        system.assertEquals(false, ac.set(record).evaluate());
    }

    @isTest
    static void test_decimal_greater_than() {
        AdjudicationCriteria ac = new AdjudicationCriteria(TestFactory.newCriteria('Request_Detail__c', 'Decimal_Value__c', 'question.id', 'greater than', 10.0));
        Request_Detail__c record = new Request_Detail__c();
        record.Question_ID__c = 'question.id';

        record.Decimal_Value__c = 9.0;
        system.assertEquals(false, ac.set(record).evaluate());

        record.Decimal_Value__c = 10.0;
        system.assertEquals(false, ac.set(record).evaluate());
        
        record.Decimal_Value__c = 11.0;
        system.assertEquals(true, ac.set(record).evaluate());
    }

    @isTest
    static void test_decimal_less_or_equal() {
        AdjudicationCriteria ac = new AdjudicationCriteria(TestFactory.newCriteria('Request_Detail__c', 'Decimal_Value__c', 'question.id', 'less or equal', 10.0));
        Request_Detail__c record = new Request_Detail__c();
        record.Question_ID__c = 'question.id';

        record.Decimal_Value__c = 9.0;
        system.assertEquals(true, ac.set(record).evaluate());

        record.Decimal_Value__c = 10.0;
        system.assertEquals(true, ac.set(record).evaluate());
        
        record.Decimal_Value__c = 11.0;
        system.assertEquals(false, ac.set(record).evaluate());
    }

    @isTest
    static void test_decimal_greater_or_equal() {
        AdjudicationCriteria ac = new AdjudicationCriteria(TestFactory.newCriteria('Request_Detail__c', 'Decimal_Value__c', 'question.id', 'greater or equal', 10.0));
        Request_Detail__c record = new Request_Detail__c();
        record.Question_ID__c = 'question.id';

        record.Decimal_Value__c = 9.0;
        system.assertEquals(false, ac.set(record).evaluate());

        record.Decimal_Value__c = 10.0;
        system.assertEquals(true, ac.set(record).evaluate());
        
        record.Decimal_Value__c = 11.0;
        system.assertEquals(true, ac.set(record).evaluate());
    }

    @isTest
    static void test_date_equals() {
        AdjudicationCriteria ac = new AdjudicationCriteria(TestFactory.newCriteria('Request_Detail__c', 'Date_Value__c', 'question.id', 'equals', Date.today()));
        Request_Detail__c record = new Request_Detail__c();
        record.Question_ID__c = 'question.id';

        record.Date_Value__c = Date.today();
        system.assertEquals(true, ac.set(record).evaluate());
        
        record.Date_Value__c = Date.today().addDays(1);
        system.assertEquals(false, ac.set(record).evaluate());
    }

    @isTest
    static void test_date_not_equal_to() {
        AdjudicationCriteria ac = new AdjudicationCriteria(TestFactory.newCriteria('Request_Detail__c', 'Date_Value__c', 'question.id', 'not equal to', Date.today()));
        Request_Detail__c record = new Request_Detail__c();
        record.Question_ID__c = 'question.id';

        record.Date_Value__c = Date.today();
        system.assertEquals(false, ac.set(record).evaluate());
        
        record.Date_Value__c = Date.today().addDays(1);
        system.assertEquals(true, ac.set(record).evaluate());
    }

    @isTest
    static void test_date_less_than() {
        AdjudicationCriteria ac = new AdjudicationCriteria(TestFactory.newCriteria('Request_Detail__c', 'Date_Value__c', 'question.id', 'less than', Date.today()));
        Request_Detail__c record = new Request_Detail__c();
        record.Question_ID__c = 'question.id';

        record.Date_Value__c = Date.today().addDays(-1);
        system.assertEquals(true, ac.set(record).evaluate());

        record.Date_Value__c = Date.today();
        system.assertEquals(false, ac.set(record).evaluate());
        
        record.Date_Value__c = Date.today().addDays(1);
        system.assertEquals(false, ac.set(record).evaluate());
    }

    @isTest
    static void test_date_greater_than() {
        AdjudicationCriteria ac = new AdjudicationCriteria(TestFactory.newCriteria('Request_Detail__c', 'Date_Value__c', 'question.id', 'greater than', Date.today()));
        Request_Detail__c record = new Request_Detail__c();
        record.Question_ID__c = 'question.id';

        record.Date_Value__c = Date.today().addDays(-1);
        system.assertEquals(false, ac.set(record).evaluate());

        record.Date_Value__c = Date.today();
        system.assertEquals(false, ac.set(record).evaluate());
        
        record.Date_Value__c = Date.today().addDays(1);
        system.assertEquals(true, ac.set(record).evaluate());
    }

    @isTest
    static void test_date_less_or_equal() {
        AdjudicationCriteria ac = new AdjudicationCriteria(TestFactory.newCriteria('Request_Detail__c', 'Date_Value__c', 'question.id', 'less or equal', Date.today()));
        Request_Detail__c record = new Request_Detail__c();
        record.Question_ID__c = 'question.id';

        record.Date_Value__c = Date.today().addDays(-1);
        system.assertEquals(true, ac.set(record).evaluate());

        record.Date_Value__c = Date.today();
        system.assertEquals(true, ac.set(record).evaluate());
        
        record.Date_Value__c = Date.today().addDays(1);
        system.assertEquals(false, ac.set(record).evaluate());
    }

    @isTest
    static void test_date_greater_or_equal() {
        AdjudicationCriteria ac = new AdjudicationCriteria(TestFactory.newCriteria('Request_Detail__c', 'Date_Value__c', 'question.id', 'greater or equal', Date.today()));
        Request_Detail__c record = new Request_Detail__c();
        record.Question_ID__c = 'question.id';

        record.Date_Value__c = Date.today().addDays(-1);
        system.assertEquals(false, ac.set(record).evaluate());

        record.Date_Value__c = Date.today();
        system.assertEquals(true, ac.set(record).evaluate());
        
        record.Date_Value__c = Date.today().addDays(1);
        system.assertEquals(true, ac.set(record).evaluate());
    }

    @isTest
    static void test_datetime_equals() {
        Datetime dtnow = Datetime.now();

        AdjudicationCriteria ac = new AdjudicationCriteria(TestFactory.newCriteria('Request_Detail__c', 'Datetime_Value__c', 'question.id', 'equals', dtnow));
        Request_Detail__c record = new Request_Detail__c();
        record.Question_ID__c = 'question.id';

        record.Datetime_Value__c = dtnow;
        system.assertEquals(true, ac.set(record).evaluate());
        
        record.Datetime_Value__c = dtnow.addDays(1);
        system.assertEquals(false, ac.set(record).evaluate());
    }

    @isTest
    static void test_datetime_not_equal_to() {
        Datetime dtnow = Datetime.now();

        AdjudicationCriteria ac = new AdjudicationCriteria(TestFactory.newCriteria('Request_Detail__c', 'Datetime_Value__c', 'question.id', 'not equal to', dtnow));
        Request_Detail__c record = new Request_Detail__c();
        record.Question_ID__c = 'question.id';

        record.Datetime_Value__c = dtnow;
        system.assertEquals(false, ac.set(record).evaluate());
        
        record.Datetime_Value__c = dtnow.addDays(1);
        system.assertEquals(true, ac.set(record).evaluate());
    }

    @isTest
    static void test_datetime_less_than() {
        Datetime dtnow = Datetime.now();

        AdjudicationCriteria ac = new AdjudicationCriteria(TestFactory.newCriteria('Request_Detail__c', 'Datetime_Value__c', 'question.id', 'less than', dtnow));
        Request_Detail__c record = new Request_Detail__c();
        record.Question_ID__c = 'question.id';

        record.Datetime_Value__c = dtnow.addDays(-1);
        system.assertEquals(true, ac.set(record).evaluate());

        record.Datetime_Value__c = dtnow;
        system.assertEquals(false, ac.set(record).evaluate());
        
        record.Datetime_Value__c = dtnow.addDays(1);
        system.assertEquals(false, ac.set(record).evaluate());
    }

    @isTest
    static void test_datetime_greater_than() {
        Datetime dtnow = Datetime.now();

        AdjudicationCriteria ac = new AdjudicationCriteria(TestFactory.newCriteria('Request_Detail__c', 'Datetime_Value__c', 'question.id', 'greater than', dtnow));
        Request_Detail__c record = new Request_Detail__c();
        record.Question_ID__c = 'question.id';

        record.Datetime_Value__c = dtnow.addDays(-1);
        system.assertEquals(false, ac.set(record).evaluate());

        record.Datetime_Value__c = dtnow;
        system.assertEquals(false, ac.set(record).evaluate());
        
        record.Datetime_Value__c = dtnow.addDays(1);
        system.assertEquals(true, ac.set(record).evaluate());
    }

    @isTest
    static void test_datetime_less_or_equal() {
        Datetime dtnow = Datetime.now();

        AdjudicationCriteria ac = new AdjudicationCriteria(TestFactory.newCriteria('Request_Detail__c', 'Datetime_Value__c', 'question.id', 'less or equal', dtnow));
        Request_Detail__c record = new Request_Detail__c();
        record.Question_ID__c = 'question.id';

        record.Datetime_Value__c = dtnow.addDays(-1);
        system.assertEquals(true, ac.set(record).evaluate());

        record.Datetime_Value__c = dtnow;
        system.assertEquals(true, ac.set(record).evaluate());
        
        record.Datetime_Value__c = dtnow.addDays(1);
        system.assertEquals(false, ac.set(record).evaluate());
    }

    @isTest
    static void test_datetime_greater_or_equal() {
        Datetime dtnow = Datetime.now();

        AdjudicationCriteria ac = new AdjudicationCriteria(TestFactory.newCriteria('Request_Detail__c', 'Datetime_Value__c', 'question.id', 'greater or equal', dtnow));
        Request_Detail__c record = new Request_Detail__c();
        record.Question_ID__c = 'question.id';

        record.Datetime_Value__c = dtnow.addDays(-1);
        system.assertEquals(false, ac.set(record).evaluate());

        record.Datetime_Value__c = dtnow;
        system.assertEquals(true, ac.set(record).evaluate());
        
        record.Datetime_Value__c = dtnow.addDays(1);
        system.assertEquals(true, ac.set(record).evaluate());
    }
    
}
