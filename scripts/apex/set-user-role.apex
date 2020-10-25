User u = new User();
u.Id = UserInfo.getUserId();
u.UserRoleId = [select Id from UserRole where Name = 'Developer'].Id;
update u;