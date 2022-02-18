@isTest
public with sharing class FaxServiceTest {
    @isTest
    static void test_Fax_Service()
    {
        
        FaxService.sendFax('5000i000000uomKAAQ','00X0i000000ubydEAA');
        
    }
}
