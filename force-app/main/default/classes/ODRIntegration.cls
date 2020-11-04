
public with sharing class ODRIntegration {
    public ODRIntegration() {

    }

    @AuraEnabled(cacheable=true)
    public static String fetchData(String page, String count) {
        try {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:ODR_Credentials/ords/edwdev1/sat/pnetsa/dummy');
            req.setMethod('GET');
            Http http = new Http();
            HTTPResponse res = http.send(req);
            System.debug(res.getBody());
            // TODO: Implement
        } catch (Exception e) {
            System.debug(e);
        }

        // TODO: Call out to service
        return '[ { "rxNumber": 999999, "quantity": 2, "refills": 0, "dinpin": 12345, "directions": "Directions for taking meds", "genericName": "Dummy generic name for drug", "dateDispensed": "1999-01-01", "presciberInfo": { "licenseNo": "12345", "code": "91", "address": { "country": "19003990", "province": "ABE", "city": "Halloween Town", "addrLine1": "789 Witch Way", "postalCode": "HT" }, "name": "Test, Doctor" }, "rxStatus": "F", "dispensingPharmacy": { "pharmacyId": "AB089", "phoneNumber": "+17893237898", "name": "ABC Pharmacy", "faxNumber": "+17893890898", "siteAddress": { "country": "123903990", "province": "ABE", "city": "Halloween Town", "addrLine1": "123 Boo Street", "postalCode": "HT" } } }, { "rxNumber": 777777, "quantity": 3, "refills": 0, "dinpin": 6789, "directions": "Directions for taking meds", "genericName": "Dummy generic name for drug", "dateDispensed": "2000-01-01", "presciberInfo": { "licenseNo": "12345", "code": "91", "address": { "country": "19003990", "province": "ABE", "city": "Halloween Town", "addrLine1": "789 Witch Way", "postalCode": "HT" }, "name": "Test, Doctor" }, "rxStatus": "F", "dispensingPharmacy": { "pharmacyId": "AB089", "phoneNumber": "+17893237898", "name": "ABC Pharmacy", "faxNumber": "+17893890898", "siteAddress": { "country": "123903990", "province": "ABE", "city": "Halloween Town", "addrLine1": "123 Boo Street", "postalCode": "HT" } } } ]';
    }
}
