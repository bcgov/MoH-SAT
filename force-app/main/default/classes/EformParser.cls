public with sharing class EformParser {
    
    public static Eform.Bundle parse(String jsonStr) {
        EForm.Bundle bundle = new EForm.Bundle();  
        bundle.entry = new List<EForm.BundleEntry>();
        
        Map<String, Object> bundleMap = (Map<String, Object>) JSON.deserializeUntyped(jsonStr);
        List<Object> entryList = (List<Object>) bundleMap.get('entry');

        for (Object entry : entryList) {
            Map<String, Object> resource = (Map<String, Object>) ((Map<String, Object>) entry).get('resource');

            if (resource.get('resourceType') == 'Patient') {
                bundle.entry.add(new Eform.BundleEntry(buildPatient(resource)));
            }

            if (resource.get('resourceType') == 'Practitioner') {
                bundle.entry.add(new Eform.BundleEntry(buildProvider(resource)));
            }

            if (resource.get('resourceType') == 'QuestionnaireResponse') {
                bundle.entry.add(new Eform.BundleEntry(buildQuestionnaireResponse(resource)));
            }

            if (resource.get('resourceType') == 'Binary' && resource.get('contentType') == 'application/pdf') {
                bundle.entry.add(new Eform.BundleEntry(buildBinary(resource)));
            }
        }

        return bundle;
    }

    private static Eform.Patient buildPatient(Map<String, Object> resource) {
        Eform.Patient patient = new Eform.Patient();
        patient.active = Boolean.valueOf(resource.get('active'));
        patient.gender = String.valueOf(resource.get('gender'));
        patient.birthdate = Date.valueOf((String) resource.get('birthDate'));
        
        List<Map<String, Object>> identifierResources = toListOfMap(resource.get('identifier'));
        patient.patientIdentifier = String.valueOf(identifierResources[0].get('value'));
        
        List<Map<String, Object>> nameResources = toListOfMap(resource.get('name'));
        patient.lastName = String.valueOf(nameResources[0].get('family'));
        patient.firstName = String.valueOf( ((List<Object>) nameResources[0].get('given'))[0] );

        List<Map<String, Object>> telecomResources = toListOfMap(resource.get('telecom'));
        for (Map<String, Object> telecomResource : telecomResources) {
            String telecomSystem = String.valueOf(telecomResource.get('system'));
            
            if (telecomSystem == 'phone') {
                patient.primaryPhone = String.valueOf(telecomResource.get('value'));
                patient.primaryPhoneUse = String.valueOf(telecomResource.get('use'));
            }

            if (telecomSystem == 'email') {
                patient.primaryEmail = String.valueOf(telecomResource.get('value'));
                patient.primaryEmailUse = String.valueOf(telecomResource.get('use'));
            }
        }
        
        return patient;
    }

    private static Eform.Provider buildProvider(Map<String, Object> resource) {
        Eform.Provider provider = new Eform.Provider();
        
        List<Map<String, Object>> identifierResources = toListOfMap(resource.get('identifier'));
        provider.providerIdentifier = String.valueOf(identifierResources[0].get('value'));
        
        List<Map<String, Object>> nameResources = toListOfMap(resource.get('name'));
        provider.lastName = String.valueOf(nameResources[0].get('family'));
        provider.firstName = String.valueOf( ((List<Object>) nameResources[0].get('given'))[0] );

        List<Map<String, Object>> telecomResources = toListOfMap(resource.get('telecom'));
        for (Map<String, Object> telecomResource : telecomResources) {
            String telecomSystem = String.valueOf(telecomResource.get('system'));
            
            if (telecomSystem == 'phone') {
                provider.primaryPhone = String.valueOf(telecomResource.get('value'));
                provider.primaryPhoneUse = String.valueOf(telecomResource.get('use'));
            }
        }
        
        return provider;
    }
    
    private static Eform.Binary buildBinary(Map<String, Object> resource) {
        EForm.Binary binary = new EForm.Binary();
        binary.contentType = String.valueOf(resource.get('contentType'));
        binary.data = String.valueOf(resource.get('data'));
        binary.id = String.valueOf(resource.get('id'));
        return binary;
    }

    private static Eform.QuestionnaireResponse buildQuestionnaireResponse(Map<String, Object> resource) {
        EForm.QuestionnaireResponse qr = new EForm.QuestionnaireResponse();
        qr.status = String.valueOf(resource.get('status'));
        qr.item = (List<EForm.QRItem>) JSON.deserialize(JSON.serialize(resource.get('item')), List<EForm.QRItem>.class);
        return qr;
    }

    private static List<Map<String, Object>> toListOfMap(Object listObj) {
        List<Map<String, Object>> listOfMap = new List<Map<String, Object>>();

        for (Object mapObj : (List<Object>) listObj) {
            listOfMap.add((Map<String, Object>) mapObj);
        }

        return listOfMap;        
    }
}
