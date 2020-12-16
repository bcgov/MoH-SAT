Map<String, String> drugQueueMap = new Map<String, String>{
    'rabeprazole 10, 20 mg   NB4' => 'Regular',
    'pantoprazole Mg 40mg  NB4' => 'Regular',
    'bupropion [Wellbutrin Type]' => 'Urgent',
    'gliclazide 30mg & 60mg SR, 80mg' => 'Regular'
};

Map<String, Group> queues = new Map<String, Group>();
for (Group g : [select Id, DeveloperName from Group where DeveloperName in :drugQueueMap.values()]) {
    queues.put(g.DeveloperName, g);
}

List<Drug__c> drugs = [select Id, Name, OwnerId from Drug__c where Name in :drugQueueMap.keyset()];
for (Drug__c drug : drugs) {
    drug.OwnerId = queues.get(drugQueueMap.get(drug.Name)).Id;
}

update drugs;