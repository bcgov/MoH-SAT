public with sharing class EmpiLookup {

    @AuraEnabled(cacheable=true)
    public static Patient findPatient(String phn){
        return EmpiIntegration.getPatient(phn);
    }
}
