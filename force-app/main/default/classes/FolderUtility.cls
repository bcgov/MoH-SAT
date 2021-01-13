public with sharing class FolderUtility {
    public FolderUtility() { }

    @AuraEnabled(cacheable=true)
    public static List<EmailTemplate> getTemplates(Id recordId) {
        List<EmailTemplate> templates = [select Id, Name FROM EmailTemplate WHERE IsActive=true and Folder.DeveloperName = 'SA_Fax_Templates'];
        System.debug(templates);
        return templates;
    }
}
