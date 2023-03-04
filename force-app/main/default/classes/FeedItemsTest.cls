@isTest(SeeAllData=true)
public with sharing class FeedItemsTest {
    @isTest
    static void test_for_coverage() {
        List<Id> feedItemIds = new List<Id>(new Map<Id, FeedItem>([select Id from FeedItem limit 2]).keySet());
        FeedItems.parseFeedItems(feedItemIds);
    }
}