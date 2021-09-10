trigger FeedItemTrigger on FeedItem (after insert) {
    List<Id> feedItemIds = new List<Id>();
    for (FeedItem feedItem : Trigger.new) {
        feedItemIds.add(feedItem.Id);
    }

    FeedItems.parseFeedItems(feedItemIds);
}