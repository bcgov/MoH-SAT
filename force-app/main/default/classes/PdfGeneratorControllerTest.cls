@isTest
public with sharing class PdfGeneratorControllerTest {

    @isTest
    static void test_controller() {
        Case saCase = TestFactory.newCase(new Drug__c(), 'Test case 1');
        insert saCase;

        EmailTemplate template = [select Id from EmailTemplate where Folder.Name = 'SA Fax Templates' limit 1][0];

        Pagereference ref = Page.PDFGenerator;
        ref.getParameters().put('id', saCase.Id);
        ref.getParameters().put('templateId', template.Id);
        Test.setCurrentPage(ref);

        Test.startTest();
        PDFGeneratorController controller = new PDFGeneratorController();
        controller.postToChatter();
        Test.stopTest();

        system.assert(controller.html != null);
    }
    
}