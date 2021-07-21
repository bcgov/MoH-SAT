List<Account> providers = [
    select Id, Provider_Identifier_Key__pc,Provider_Identifier__pc, Provider_Type__pc 
    from Account 
    where Provider_Identifier_Key__pc = null
    and PersonContactId in (select Provider__c from Case)
    and Recordtype.Name = 'Provider'
];

for (Account provider : providers) {
    provider.Provider_Identifier_Key__pc = 
        provider.Provider_Type__pc+'-'+provider.Provider_identifier__pc;
}

update providers;

delete [
    select Id from Account 
    where PersonContactId not in (select Provider__c from Case) 
    and Provider_Identifier__pc not in ('IFIER', 'Not Provided')
    and Recordtype.Name = 'Provider'
];