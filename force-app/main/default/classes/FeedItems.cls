public with sharing class FeedItems {
    @future
    public static void parseFeedItems(List<Id> feedItemIds) {
        notifyGroups(feedItemIds);
    }

    private static void notifyGroups(List<Id> feedItemIds) {
        ConnectApi.BatchResult[] results = ConnectApi.ChatterFeeds.getFeedElementBatch(Network.getNetworkId(), feedItemIds);

        for (ConnectApi.BatchResult result : results) {
            if (result.isSuccess()) {
                Object theResult = result.getResult();
                if (theResult instanceof ConnectApi.FeedItem) {
                    ConnectApi.FeedItem item = (ConnectApi.FeedItem) theResult;
                    for (ConnectApi.MessageSegment segment : item.body.messageSegments) {
                        if (segment instanceof ConnectApi.MentionSegment) {
                            ConnectApi.MentionSegment theMention = (ConnectApi.MentionSegment) segment;
                            Id mentionedId = theMention.record.id;
                            if (mentionedId.getSobjectType() == CollaborationGroup.sobjectType) {
                                callFlow(mentionedId);
                            }
                        }
                    }
                }
            }
        }
    }

    private static void callFlow(Id collaborationGroupId) {
        Map<String, Object> params = new Map<String, Object>();
        params.put('Collaboration_Group_ID', collaborationGroupId);
        Flow.Interview.Send_notification_to_group flow = new Flow.Interview.Send_notification_to_group(params);
        flow.start();
    }
}