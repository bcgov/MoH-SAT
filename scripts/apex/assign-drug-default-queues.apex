Map<String, String> drugQueueMap = new Map<String, String>{
    'aripip' => 'Regular',
    'olan' => 'Regular',
    'abatacept' => 'Regular',
    'bupropiondepression' => 'Urgent',
    'glic' => 'Regular',
    '1PPIpant' => 'Regular',
    '1PPIrabe' => 'Regular',
    'ARBcand' => 'Regular',
    'ARBlosa' => 'Regular',
    'ARBtelm' => 'Regular',
    'ARBvals' => 'Regular',
    'Maintenaarip' => 'Regular',
    'brex' => 'Regular',
    'dalteparin' => 'Regular',
    'SGLT2' => 'Regular',
    'enoxaparin' => 'Regular',
    'ARBepro' => 'Regular',
    '2PPIesom' => 'Regular',
    'ARBirbe' => 'Regular',
    '2PPIlans' => 'Regular',
    'DPP4lina' => 'Regular',
    'nadroparin' => 'Regular',
    'ARBolme' => 'Regular',
    '2PPIomep' => 'Regular',
    '2PPIpant' => 'Regular',
    'DPP4saxa' => 'Regular',
    'semaglutide' => 'Regular',
    'tinzaparin' => 'Regular',
    'vancomycin' => 'Regular',
    'zip' => 'Regular',
    'zopiclone' => 'Regular'
};

Map<String, Group> queues = new Map<String, Group>();
for (Group g : [select Id, DeveloperName from Group where DeveloperName in :drugQueueMap.values()]) {
    queues.put(g.DeveloperName, g);
}

List<Drug__c> drugs = [select Id, Drug_Code__c, OwnerId from Drug__c where Drug_Code__c in :drugQueueMap.keyset()];
for (Drug__c drug : drugs) {
    drug.OwnerId = queues.get(drugQueueMap.get(drug.Drug_Code__c)).Id;
}

update drugs;