public without sharing class RelatedFiles {

  public without sharing class RelatedFilesDownload {
    @AuraEnabled
    public string Title;

    @AuraEnabled
    public string URL;

    @AuraEnabled
    public Id Id;
    
    @AuraEnabled
    public Datetime createdDate;
  }

  @AuraEnabled(cacheable=true)
  public static List<RelatedFilesDownload> getRelatedFiles(Id caseId){
      List<RelatedFilesDownload> downloadLinks = new List<RelatedFilesDownload>();

      Set<Id> documentIds = new Set<Id>();
      for (ContentDocumentLink cdl : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:caseId and LinkedEntity.Type='Case']) {
        documentIds.add(cdl.ContentDocumentId);
      }
      
      List<ContentDistribution> contentDistributions = [
        SELECT Id, Name, DistributionPublicUrl, ContentVersionId, ContentVersion.CreatedDate 
        FROM ContentDistribution
        WHERE ContentVersionId in (select LatestPublishedVersionId from ContentDocument where Id in :documentIds)
        ORDER BY ContentVersion.CreatedDate desc
      ];

      for(ContentDistribution cd : contentDistributions){
        RelatedFilesDownload link = new RelatedFilesDownload();
        link.Id = cd.Id;
        link.Title = cd.Name;
        link.URL = cd.DistributionPublicUrl;
        link.createdDate = cd.ContentVersion.CreatedDate;
        downloadLinks.add(link);
      }

      return downloadLinks;
  }
}
