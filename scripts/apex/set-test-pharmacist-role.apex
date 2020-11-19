User u = [select Id, Email, UserRoleId from User where LastName='Pharmacist' limit 1];
u.UserRoleId = [select Id from UserRole where Name = 'SA Pharmacist'].Id;
update u;