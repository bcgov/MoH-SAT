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
    user.FederationIdentifier = user.Alias;
    user.IsActive=true;
    return user;
}

List<Contact> ecContacts = [select Id, FirstName, LastName, Email from Contact where IsPersonAccount=false and Account.Name in ('IBD DBAAC', 'MS DBAAC')];
List<User> users = new List<User>();

Profile ecProfile = [select Id from Profile where Name = 'External Committee Community Users'][0];
for (Contact c : ecContacts) {
    users.add(newUser(ecProfile, c));
}

Profile hibcProfile = [select Id from Profile where Name = 'HIBC CCPlus Community Users'][0];
List<Contact> hibcContacts = [select Id, FirstName, LastName, Email from Contact where IsPersonAccount=false and Account.Name in ('HIBC')];
for (Contact c : hibcContacts) {
    users.add(newUser(hibcProfile, c));
}

Profile serviceBcProfile = [select Id from Profile where Name = 'Service BC CCPlus Community Users'][0];
List<Contact> serviceBcContacts = [select Id, FirstName, LastName, Email from Contact where IsPersonAccount=false and Account.Name in ('Service BC')];
for (Contact c : serviceBcContacts) {
    users.add(newUser(serviceBcProfile, c));
}

insert users;

PermissionSet ecPermset = [select Id from PermissionSet where Name = 'External_Committee_User_Permission'];
PermissionSet hibcPermset = [select Id from PermissionSet where Name = 'HIBC_CCplus_Community_User_Permission'];

List<PermissionSetAssignment> psas = new List<PermissionSetAssignment>();
for (User u : users) {
    PermissionSetAssignment psa = new PermissionSetAssignment();
    psa.AssigneeId = u.Id;
    
    if (u.ProfileId == ecProfile.Id) {
        psa.PermissionSetId=ecPermset.Id;
    } else if (u.ProfileId == hibcProfile.Id) {
        psa.PermissionSetId=hibcPermset.Id;
    } else if (u.ProfileId == serviceBcProfile.Id) {
        psa.PermissionSetId=hibcPermset.Id;
    }
    psas.add(psa);
}
insert psas;