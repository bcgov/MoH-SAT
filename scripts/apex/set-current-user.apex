User u = new User();
u.Id = UserInfo.getUserId();
u.UserRoleId = [select Id from UserRole where Name = 'Developer'].Id;
u.FederationIdentifier = 'SFDEV';
u.UserPreferencesUserDebugModePref = true;
update u;
