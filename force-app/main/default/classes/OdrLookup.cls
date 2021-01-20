public with sharing class OdrLookup {

    @AuraEnabled(cacheable=true)
    public static Provider findProvider(String providerId, String providerType){
        return ODRIntegration.getProvider(providerId, providerType);  
    }

}
