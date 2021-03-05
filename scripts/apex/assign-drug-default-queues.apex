Map<String, String> drugQueueMap = new Map<String, String>{
    '1PPIpant' => 'Regular',
    '1PPIrabe' => 'Regular',
    '2PPIesom' => 'Regular',
    '2PPIlans' => 'Regular',
    '2PPIomep' => 'Regular',
    '2PPIpant' => 'Regular',
    'abatacept' => 'AR',
    'ARBcand' => 'Regular',
    'ARBepro' => 'Regular',
    'ARBirbe' => 'Regular',
    'ARBlosa' => 'Regular',
    'ARBolme' => 'Regular',
    'ARBtelm' => 'Regular',
    'ARBvals' => 'Regular',
    'aripip' => 'Urgent',
    'brex' => 'Urgent',
    'bupropiondepression' => 'Urgent',
    'dalteparin' => 'AC',
    'DPP4lina' => 'Regular',
    'DPP4saxa' => 'Regular',
    'enoxaparin' => 'AC',
    'gliclazide' => 'Regular',
    'Maintenaarip' => 'Urgent',
    'nadroparin' => 'AC',
    'olan' => 'Urgent',
    'semaglutide' => 'Regular',
    'SGLT2' => 'Regular',
    'tinzaparin' => 'AC',
    'vancomycin' => 'Urgent',
    'zip' => 'Urgent',
    'zopiclone' => 'Urgent'
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