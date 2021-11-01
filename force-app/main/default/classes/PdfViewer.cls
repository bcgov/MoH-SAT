public with sharing class PdfViewer {
    
    @AuraEnabled(cacheable=true)
    public static File getPdf(Id recordId){
        Set<Id> documentIds = new Set<Id>();

        for (ContentDocumentLink cdl : queryContentDocumentLinks(recordId)) {
            documentIds.add(cdl.ContentDocumentId);
        }

        ContentVersion cv = [
            select Id, Title, ContentDocumentId
            from ContentVersion
            where ContentDocumentId in :documentIds
            and FileExtension='pdf'
            order by CreatedDate desc
            limit 1
        ];

        return cv != null ? new File(cv) : null; 
    }

    private static List<ContentDocumentLink> queryContentDocumentLinks(Id recordId) {
        return [
            select Id, ContentDocumentId 
            from ContentDocumentLink 
            where LinkedEntityId = :recordId
        ];
    }

    public class File {
        @AuraEnabled public Id id;
        @AuraEnabled public Id documentId;
        @AuraEnabled public String title;

        public File(ContentVersion record) {
            this.id = record.Id;
            this.documentId = record.ContentDocumentId;
            this.title = record.Title;
        }
    }
}
