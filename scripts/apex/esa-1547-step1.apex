List<AggregateResult> ARS = [select count(id), provider_identifier__c
    from contact
    where account.recordtype.name = 'provider'
    and Provider_Identifier__c not in ('IFIER', 'Not Provided')
    group by provider_identifier__c
    having count(id) > 1
    order by provider_identifier__c desc];

Set<String> identifiers = new Set<String>();

for (AggregateResult result : ARS) {
    String providerId = String.valueOf(result.get('Provider_Identifier__c'));
    
    identifiers.add(providerId);
}

List<Contact> providerList = [
    select Id, Provider_Identifier__c, Provider_Type__c, 
        (select Id, Provider__c from ProviderCases__r) 
    from Contact 
    where Provider_Identifier__c in :identifiers
    order by provider_identifier__c, provider_type__c, lastmodifieddate desc];

Map<String, List<Contact>> providersByKey = new Map<String, List<Contact>>();

// Sort dupes by key
for (Contact provider : providerList) {
    String key = provider.Provider_Type__c + '-' + provider.Provider_Identifier__c;
    
    if (!providersByKey.containsKey(key)) {
        providersByKey.put(key, new List<Contact>());
    }

    providersByKey.get(key).add(provider);
}

List<Case> casesToUpdate = new List<Case>();

for (String key : providersByKey.keySet()) {
    List<Contact> providersByKey = providersByKey.get(key);

    Contact latestProvider = providersByKey[0];
    
    List<Case> cases = new List<Case>();

    for (Contact provider : providersByKey) {
        for (Case c : provider.ProviderCases__r) {
            if (c.Provider__c != latestProvider.Id) {
                c.Provider__c = latestProvider.Id;
                cases.add(c);
            }
        }
    }

    List<Id> caseIds = new List<Id>();
    for (Case c : cases) {
        caseIds.add(c.Id);
    }

    system.debug(String.format(
        'New provider: {0}, cases: {1}', new String[] {
        latestProvider.Id,
        String.join(caseIds, ',')
    }));

    casesToUpdate.addAll(cases);
}

update casesToUpdate;

