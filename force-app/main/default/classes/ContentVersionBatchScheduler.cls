/**********************************************************************************************
* @Author:      Ranadheer Reddy Gundla 
* @Date:        06 March 2025
* @Description: This is used to schedule the ContentVersionBatch Class for every 6 hours, every day.
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]  
***********************************************************************************************/
global with sharing class ContentVersionBatchScheduler implements Schedulable {
    global void execute(SchedulableContext SC) {
        Database.executeBatch(new ContentVersionBatch(), 200);
    }
}