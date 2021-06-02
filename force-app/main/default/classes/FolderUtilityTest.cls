@isTest
public with sharing class FolderUtilityTest {
    @isTest
    static void test_get_templates() {
        List<EmailTemplate> actual = FolderUtility.getTemplates();
        List<EmailTemplate> expected = [select Id from EmailTemplate where Folder.DeveloperName = 'SA_Fax_Templates'];
        system.assertEquals(expected.size(), actual.size());
    }
}
