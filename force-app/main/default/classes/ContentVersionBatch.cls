/**********************************************************************************************
* @Author:      Ranadheer Reddy Gundla 
* @Date:        06 March 2025
* @Description: The class is used to create ContentDistribution for every Contentversion inserted.
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]  
***********************************************************************************************/
global with sharing class ContentVersionBatch implements Database.Batchable<SObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // Query ContentVersion records from the last 2 weeks
        // Exclude records that already have a ContentDistribution
        return Database.getQueryLocator([
            SELECT Id, Title FROM ContentVersion WHERE CreatedDate = LAST_N_DAYS:15 
                AND Id NOT IN (SELECT ContentVersionId FROM ContentDistribution
                    WHERE CreatedDate = LAST_N_DAYS:16
            )
        ]);
    }
    
    global void execute(Database.BatchableContext BC, List<ContentVersion> scope) {
       List<ContentDistribution> distributionsToInsert = new List<ContentDistribution>();
        
        for (ContentVersion objContentVersion : scope) {
            ContentDistribution newDist = new ContentDistribution();
            newDist.ContentVersionId = objContentVersion.Id;
            newDist.Name = objContentVersion.Title;
            newDist.PreferencesNotifyOnVisit = false;
            newDist.PreferencesAllowViewInBrowser = true;
            newDist.PreferencesAllowOriginalDownload = true;
            
            distributionsToInsert.add(newDist);
        }
        
        if (!distributionsToInsert.isEmpty()  ) {
            insert distributionsToInsert;
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        System.debug('Batch Job Completed: Created ContentDistributions for new ContentVersions');
    }
}