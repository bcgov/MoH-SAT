@isTest
private class SendEmailUtilityTest {
 
    @isTest
    public static void testSendEmail() {
        
        RecordType providerRT = [SELECT Id from RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Provider'];
        //Test Person Account
        Account providerAccount = new Account(
            LastName = 'testLastName',
            RecordTypeId = providerRT.Id,
            PersonEmail = 'provider@test.com'
        );
        insert providerAccount;
        
        Contact provider = [SELECT Id from Contact where AccountId =: providerAccount.Id];
 
        // Test Case
        Case testCase = new Case(
            Subject = 'Test Case',
            Status = 'Approved',
            Origin = 'Email',
            Priority = 'Medium',
            EDRD_Ref_No__c = '1234',
            Provider__c = provider.Id,
            EDRD_MOHFunding_Decision__c = 'Approved'
        );
        insert testCase;
        
        List<String> params = new List<String>{testCase.Id,testCase.Status};
        
        
       PageReference pageRef = Page.emailPDFTemplate;
        Test.setCurrentPage(pageRef);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(testCase);

        ApexPages.currentPage().getParameters().put('parameters',String.join(params, ','));
        
        SendEmailUtility emailUtility = new SendEmailUtility(sc);
        System.assertEquals(testCase.Id, emailUtility.caseRec.Id);
        System.assertEquals(testCase.Status, emailUtility.Status);
        
        SendEmailUtility.generatePDFParams innerClass = new SendEmailUtility.generatePDFParams();
        innerClass.caseStatus = testCase.Status;
        innerClass.recordId= testCase.Id;
        
        SendEmailUtility.generatePDFParams innerClass2 = new SendEmailUtility.generatePDFParams();
        innerClass2.caseStatus = testCase.Status;
        innerClass2.recordId= testCase.Id;       
        
        List<SendEmailUtility.generatePDFParams> invocableValues = new List<SendEmailUtility.generatePDFParams>();
        invocableValues.add(innerClass);
        invocableValues.add(innerClass2);
        
        Test.startTest();
            SendEmailUtility.processCases(invocableValues);
        Test.stopTest();

        Integer emailInvocations = Limits.getEmailInvocations();
    }
}