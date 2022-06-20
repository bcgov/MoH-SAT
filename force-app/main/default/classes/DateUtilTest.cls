@isTest
public with sharing class DateUtilTest {

    @isTest
    static void test_parse_odr_date() {
        system.assertEquals(Date.newInstance(2020, 1, 22), DateUtil.parseOdrDate('2020/01/22'));
    }

    @isTest
    static void test_format_to_odr_date() {
        Date testDate = Date.newInstance(2021, 1, 10);
        system.assertEquals('2021/01/10',DateUtil.formatToOdrDate(testDate));
    }

    @isTest
    static void test_calculate_termination_date_indefinite() {
        Date testDate = Date.newInstance(2021, 1, 10);
        Date result = DateUtil.calculateTerminationDate(testDate, null, 'Indefinite');
        system.assertEquals(Date.newInstance(3000,1,1), result);
    }

    @isTest
    static void test_calculate_termination_date_end_of_year() {
        Date testDate = Date.newInstance(2021, 1, 10);
        Date result = DateUtil.calculateTerminationDate(testDate, null, 'End of year');
        system.assertEquals(Date.newInstance(2021,12,31), result);
    }

    @isTest
    static void test_calculate_termination_date_days() {
        Date testDate = Date.newInstance(2021, 1, 10);
        Date result = DateUtil.calculateTerminationDate(testDate, 1, 'Days');
        system.assertEquals(Date.newInstance(2021,1,11).addDays(1), result);
    }

    @isTest
    static void test_calculate_termination_date_months() {
        Date testDate = Date.newInstance(2021, 1, 10);
        Date result = DateUtil.calculateTerminationDate(testDate, 2, 'Months');
        system.assertEquals(Date.newInstance(2021,3,10).addDays(1), result);
    }

    @isTest
    static void test_calculate_termination_date_years() {
        Date testDate = Date.newInstance(2021, 1, 10);
        Date result = DateUtil.calculateTerminationDate(testDate, 2, 'Years');
        system.assertEquals(Date.newInstance(2023,1,10).addDays(1), result);
    }

    @isTest
    static void test_calculate_termination_date_negative() {
        Date testDate = Date.newInstance(2021, 1, 10);
        Date result = DateUtil.calculateTerminationDate(testDate, null, 'Invalid unit');
        system.assertEquals(Date.newInstance(2021,1,10), result);
    }
}