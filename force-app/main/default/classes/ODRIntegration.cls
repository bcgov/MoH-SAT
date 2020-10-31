
public with sharing class ODRIntegration {
    public ODRIntegration() {

    }

    @AuraEnabled(cacheable=true)
    public static String fetchData(String page, String count) {
        try {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:ODR_Credentials/ords/edwdev1/sat/pnetsa/getMedHistory/dummy');
            req.setMethod('GET');
            Http http = new Http();
            HTTPResponse res = http.send(req);
            System.debug(res.getBody());
        } catch (Exception e) {
            System.debug(e);
        }

        // TODO: Call out to service
        return '[ { "rxNumber": 12345, "quantity": 2, "refills": 0, "dinpin": 12345, "directions": "Directions for taking meds", "genericName": "Dummy generic name for drug", "practitioner": "Test, Doctor", "dateDispensed": "2000-01-01", "rxStatus": "F", "dispensingPharmacy": { "pharmacyId": "AB089", "phoneNumber": "+17893237898", "name": "ABC Pharmacy", "faxNumber": "+17893890898", "siteAddress": { "country": "123903990", "province": "ABE", "city": "Halloween Town", "addrLine1": "123 Boo Street", "postalCode": "HT" } } }, { "rxNumber": 67890, "quantity": 2, "refills": 0, "dinpin": 67890, "directions": "Directions for taking meds", "genericName": "Dummy generic name for drug", "practitioner": "Test, Doctor", "dateDispensed": "1999-01-01", "rxStatus": "F", "dispensingPharmacy": { "pharmacyId": "AB089", "phoneNumber": "+17893237898", "name": "ABC Pharmacy", "faxNumber": "+17893890898", "siteAddress": { "country": "123903990", "province": "ABE", "city": "Halloween Town", "addrLine1": "123 Boo Street", "postalCode": "HT" } } } ]';
    }
}
