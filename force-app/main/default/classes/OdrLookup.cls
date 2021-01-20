public with sharing class OdrLookup {

    @AuraEnabled(cacheable=true)
    public static Provider findProvider(String providerId, String providerType){
        return ODRIntegration.getProvider(providerId, getPractitionerCode(providerType));  
    }

    private static String getPractitionerCode(String name) {
        String practIdCode = '';
        switch on name {
            when 'Physician' {
                practIdCode = '91';
            } when 'Nurse Practitioner' {
                practIdCode = '96';
            } when 'Dentist' {
                practIdCode = '95';
            } when 'Midwife' {
                practIdCode = '98';
            } when 'Podiatrist' {
                practIdCode = '93';
            } when 'Naturopathic Practitioner' {
                practIdCode = '97';
            } when 'Pharmacist' {
                practIdCode = 'P1';
            } when 'Optometrist' {
                practIdCode = '94';
            } when 'Out of province provider' {
                practIdCode = 'OOP';
            }
        }
        return practIdCode;
      }
  

}
