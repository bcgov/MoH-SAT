@isTest
public with sharing class DescriptionLookupTest {
    @isTest
    static void test_get_description_positive() {
        insert newRecord('test', 'test description');
        Test.startTest();
        String result = DescriptionLookup.getDescription('test');
        Test.stopTest();
        system.assertEquals('test description', result);       
    }

    @isTest
    static void test_get_description_negative() {
        Test.startTest();
        String result = DescriptionLookup.getDescription('test');
        Test.stopTest();
        system.assertEquals(null, result);       
    }

    private static RDP_Code_Description__c newRecord(String code, String description) {
        RDP_Code_Description__c record = new RDP_Code_Description__c();
        record.Name = code;
        record.Description__c = description;
        return record;
    }
}
