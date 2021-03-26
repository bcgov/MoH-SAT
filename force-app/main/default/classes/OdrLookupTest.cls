@isTest
public with sharing class OdrLookupTest {

    @isTest
    static void test_find_provider() {
        Provider mockProvider = new Provider();
        mockProvider.lastName = 'Test Provider';

        OdrLookup.mockProvider = mockProvider;

        Test.startTest();
        Provider resultProvider = OdrLookup.findProvider('mock_id', 'mock_id_type');
        Test.stopTest();

        system.assertEquals(mockProvider.lastName, resultProvider.lastName);
    }

}

