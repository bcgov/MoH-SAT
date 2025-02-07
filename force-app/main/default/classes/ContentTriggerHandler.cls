public without sharing class ContentTriggerHandler {
    public static void createPublicLinkForFile(List<ContentVersion> contentVersions) {
     /* ContentDistribution[] distributionsToInsert = new List<ContentDistribution>();
      for (ContentVersion objContentVersion: contentVersions) {
        System.debug('');
        System.debug(objContentVersion);
        distributionsToInsert.add(createContentDistribution(objContentVersion.Id, objContentVersion.Title));
      }

      if (!distributionsToInsert.isEmpty() && !Test.isRunningTest()) {
        insert distributionsToInsert;
      }
    }

    public static ContentDistribution createContentDistribution(Id contentVersionId, String Title) {
      ContentDistribution newDist = new ContentDistribution();
      newDist.ContentVersionId = contentVersionId;
      newDist.Name = Title;
      newDist.PreferencesNotifyOnVisit = false;
      newDist.PreferencesAllowViewInBrowser = true;
      newDist.PreferencesAllowOriginalDownload = true;
      System.debug( 'createContentDistribution created' );
      return newDist; */
    } 
}