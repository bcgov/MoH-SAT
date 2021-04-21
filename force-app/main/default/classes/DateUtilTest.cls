@isTest
public with sharing class DateUtilTest {

    @isTest
    static void test_parse_odr_date() {
        system.assertEquals(Date.newInstance(2020, 1, 22), DateUtil.parseOdrDate('2020/01/22'));
    }
}
