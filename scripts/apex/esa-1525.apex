List<Diagnosis__c> diagnoses = [select id, Drug__r.Drug_Code__c, Diagnosis__c from Diagnosis__c where Hierarchy__c = null and Diagnosis__c != 'Other'];

for (Diagnosis__c diagnosis : diagnoses) {
    diagnosis.Hierarchy__c = 'Primary';
}

update diagnoses;