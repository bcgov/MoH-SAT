@isTest
private class FeedItemTrigger_Test {

    @isTest
    static void testFeedItemTrigger() {
        // Create a test user (required for Chatter posts)
        User testUser = new User(
            Alias = 'tuser',
            Email = 'testuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/New_York',
            UserName = 'testuserfeeditem@example.com'
        );
        insert testUser;

        System.runAs(testUser) {
            // Create a test account (FeedItem needs a parent record to post to)
            Account acc = new Account(Name = 'Test Account');
            insert acc;

            // Create a FeedItem (Chatter post) related to the Account
            FeedItem post = new FeedItem();
            post.Body = 'Test chatter post';
            post.ParentId = acc.Id;
            insert post;
        }
    }
}
