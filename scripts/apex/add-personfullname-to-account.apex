List<Account> personAccounts = [SELECT Id, FirstName, LastName, IsPersonAccount FROM Account WHERE IsPersonAccount = TRUE and Person_Full_Name__c = null];

for(Account a : personAccounts){
    a.Person_Full_Name__c = a.FirstName + ' ' + a.LastName;
}

update personAccounts;
