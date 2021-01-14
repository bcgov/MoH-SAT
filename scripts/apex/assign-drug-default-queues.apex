Map<String, String> drugQueueMap = new Map<String, String>{
    'rabeprazole 10, 20 mg   NB4' => 'Regular',
    'pantoprazole Mg 40mg  NB4' => 'Regular',
    'bupropion [Wellbutrin Type]' => 'Urgent',
    'gliclazide 30mg & 60mg SR, 80mg' => 'Regular',
    'candesartan + hctz 9901-0057 NB4+  NB4' => 'Regular',
    'candesartan 8,16,32mg  NB4' => 'Regular',
    'losartan (ARBs)  NB4' => 'Regular',
    'losartan + hctz (ARBs)' => 'Regular',
    'telmisartan + hctz (ARBs)   NB4' => 'Regular',
    'telmisartan 40,80 mg (ARBs)  NB4' => 'Regular',
    'telmisartan + amlodipine combo NB4   NB4' => 'Regular',
    'valsartan + hctz   NB4' => 'Regular',
    'valsartan 40,80,160,320mg  NB4' => 'Regular'
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