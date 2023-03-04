public with sharing class EmpiLookup {

    @TestVisible
    private static Patient mockPatient;

    @AuraEnabled(cacheable=true)
    public static Patient findPatient(String phn){
        return callGetPatient(phn);
    }

    private static Patient callGetPatient(String phn) {
        return Test.isRunningTest() ? mockPatient : EmpiIntegration.getPatient(phn);
    }
}