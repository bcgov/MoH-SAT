public without sharing class RelatedFiles {

  public without sharing class RelatedFilesDownload {
    @AuraEnabled
    public string Title;

    @AuraEnabled
    public string URL;

    @AuraEnabled
    public Id Id;
  }

  @AuraEnabled(cacheable=true)
  public static List<RelatedFilesDownload> getRelatedFiles(Id caseId){
      List<RelatedFilesDownload> downloadLinks = new List<RelatedFilesDownload>();

      List<ContentDocumentLink> links = [
        SELECT ContentDocumentId, LinkedEntityId, ContentDocument.title FROM ContentDocumentLink where LinkedEntityId=:caseId and LinkedEntity.Type='Case'
      ];

      for(Integer i = 0; i < links.size(); i++){
        ContentDocument contentDocument = [ SELECT Id, Title FROM ContentDocument WHERE Id =: links[i].ContentDocumentId LIMIT 1 ];
        ContentVersion contentVersion = [ SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId =: contentDocument.Id LIMIT 1 ];
        List<ContentDistribution> contentDistributions = [ SELECT Id, Name, DistributionPublicUrl, ContentVersionId FROM ContentDistribution WHERE ContentVersionId =: contentVersion.Id ];

        if (contentDistributions.size() > 0) {
            RelatedFilesDownload aLink = new RelatedFilesDownload();
            aLink.Id = contentDistributions[0].Id;
            aLink.Title = contentDistributions[0].Name;
            aLink.URL = contentDistributions[0].DistributionPublicUrl;
            downloadLinks.add(aLink);
        }
      }

      return downloadLinks;
  }
}
