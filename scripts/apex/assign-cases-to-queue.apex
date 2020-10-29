Group regularQueue = [select Id from Group where DeveloperName = 'Regular'];
List<Case> cases = [select Id, OwnerId from Case];

for (Case c : cases) {
    c.OwnerId = regularQueue.Id;
}

update cases;