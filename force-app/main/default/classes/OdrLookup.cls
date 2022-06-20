public with sharing class OdrLookup {
    
    @TestVisible
    private static Provider mockProvider;

    @AuraEnabled(cacheable=true)
    public static Provider findProvider(String providerId, String providerType){
        return callGetProvider(providerId, providerType);
    }
    
    private static Provider callGetProvider(String providerId, String providerType) {
        return Test.isRunningTest() ? mockProvider : ODRIntegration.getProvider(providerId, providerType);
    }

}