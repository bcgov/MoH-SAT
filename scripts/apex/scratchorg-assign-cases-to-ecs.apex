for (External_Committee__c ec : [select Id from External_Committee__c]){
    List<Case> cases = [select Id, External_Committee__c from Case where External_Committee__c = null limit 3];
    for (Case c : cases) {
        c.External_Committee__c = ec.Id;
    }
    update cases;
}