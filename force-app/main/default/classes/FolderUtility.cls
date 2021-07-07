public with sharing class FolderUtility {
    @AuraEnabled(cacheable=true)
    public static List<EmailTemplate> getTemplates() {
        return [select Id, Name FROM EmailTemplate WHERE IsActive=true and Folder.DeveloperName = 'SA_Fax_Templates' order by Name asc];
    }
}
