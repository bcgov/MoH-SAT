public static User newUser(Profile profile, Contact contact) {
    User user = new User();
    user.ContactId = contact.Id;
    user.ProfileId = profile.Id;
    user.FirstName = contact.FirstName;
    user.LastName = contact.LastName;
    user.Email = contact.Email;
    user.CommunityNickname = contact.LastName;
    user.Alias = contact.LastName.left(8);
    user.Username = contact.Email.substringBefore('@') + '@' + UserInfo.getUserName().substringBefore('@') + '.com';
    user.EmailEncodingKey = 'UTF-8';
    user.TimeZoneSidKey = 'America/Los_Angeles';
    user.LocaleSidKey = 'en_US';
    user.LanguageLocaleKey = 'en_US';
    user.IsActive=false;
    return user;
}

Profile ecProfile = [select Id from Profile where Name = 'External Committee Community Users'][0];
List<Contact> ecContacts = [select Id, FirstName, LastName, Email from Contact where IsPersonAccount=false and Account.Name in ('IBD DBAAC', 'MS DBAAC')];
List<Contact> hibcContacts = [select Id, FirstName, LastName, Email from Contact where IsPersonAccount=false and Account.Name in ('HIBC')];
List<User> users = new List<User>();

for (Contact c : ecContacts) {
    users.add(newUser(ecProfile, c));
}

insert users;