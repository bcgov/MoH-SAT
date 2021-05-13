public with sharing class PHNCaseLookup {

    @AuraEnabled(cacheable=true)
    public static List<Case> lookup(String phn) {
      List<Case> cases = [select Id, CaseNumber, Status, Subject, CreatedDate, owner.name from Case where Patient_Identifier__c = :phn];
      return cases;
    }
}
