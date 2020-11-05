public with sharing class ODRIntegration {
    public ODRIntegration() { }

    @AuraEnabled(cacheable=true)
    public static SpecialAuthorityResponse fetchData(String page, String count) {
        // TODO: Feature Toggle
        return mockData();
        // try {
        //     // TODO
        //     String payload = '{ requestUUID: "aec0ecff-a240-4ad1-9283-8fa1c5185fba", clientName: "SpecAuth", phn: "999999998", searchDateRange: { from: "2000-01-01", to: "2020-01-01" } }';
        //     HttpRequest req = new HttpRequest();
        //     req.setEndpoint('callout:ODR_Credentials/ords/edwdev1/sat/pnetsa/getMedHistory');
        //     req.setMethod('POST');
        //     req.setHeader('Content-Type','application/json');
        //     req.setBody(payLoad);
        //     // req.setEndpoint('callout:ODR_Credentials/ords/edwdev1/sat/pnetsa/dummy');
        //     // req.setMethod('GET');
        //     Http http = new Http();
        //     HTTPResponse res = http.send(req);
        //     String json = res.getBody();
        //     SpecialAuthorityResponse sar = SpecialAuthorityResponse.parse(json);
        //     System.debug(sar);
        //     return sar;
        // } catch (Exception e) {
        //     System.debug(e);
        //     return this.mockData();
        // }
    }

    private static SpecialAuthorityResponse mockData() {
        String json = '{ "clientName": "SpecAuth", "requestUUID": "63d5bb9c-cbc9-4718-a11d-d651f7e72345", "medHistory": { "totalRecords": 7, "totalPages": 1, "medRecords": [ { "rxNumber": 445566, "quantity": 90, "refills": 0, "dinpin": 1234567, "directions": "TAKE 1/2 TABLET TWICE A DAY", "drugStrength": "25 MG", "genericName": "Generic thing", "daysSupply": 90, "dateDispensed": "2019-05-15", "presciberInfo": { "paymentAddress": { "country": "BC", "province": "BC", "city": "Somewhere", "addrLine1": "DH", "postalCode": "VVVVVV" }, "licenseNo": "99999", "code": "91", "phoneNumber": "+12505555555", "name": "MYNAME", "faxNumber": "+12505555555" }, "rxStatus": "F", "dispensingPharmacy": { "pharmacyId": "abc123", "phoneNumber": "+12505555555", "name": "EDDHBFDZATZOCI", "faxNumber": "+12505555555", "siteAddress": { "country": "BC", "province": "BC", "city": "COMOX", "addrLine1": "333 Street", "postalCode": "TFDFSL" } } } ] } }';
        SpecialAuthorityResponse sar = SpecialAuthorityResponse.parse(json);
        return sar;
    }
}


