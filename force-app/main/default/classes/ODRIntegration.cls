public with sharing class ODRIntegration {
    public ODRIntegration() { }

    @AuraEnabled(cacheable=true)
    public static SpecialAuthorityResponse fetchData(String page, String count) {
        System.debug('Fetch Data');
        System.debug(page);
        System.debug(count);

        SpecialAuthorityResponse sar = null;
        // TODO: Feature Toggle
        try {
            // TODO

            Http h = new Http();
            HttpRequest r = new HttpRequest();
            r.setEndPoint('http://ifconfig.me/ip');
            r.setMethod('GET');
            HttpResponse response = h.send(r);
            System.debug('Salesforce IP');
            System.debug(response.getBody());


            String payload = '{ requestUUID: "aec0ecff-a240-4ad1-9283-8fa1c5185fba", clientName: "SpecAuth", phn: "999999998", searchDateRange: { from: "2000-01-01", to: "2020-01-01" } }';
            HttpRequest req = new HttpRequest();
            req.setHeader('Content-Type','application/json');
            req.setEndpoint('callout:ODR_Credentials/ords/edwdev1/sat/pnetsa/dummy');
            // req.setEndpoint('callout:ODR_Credentials/ords/edwdev1/sat/pnetsa/getMedHistory');
            req.setMethod('GET');
            Http http = new Http();
            HTTPResponse res = http.send(req);
            String resBody = res.getBody();
            sar = (SpecialAuthorityResponse) JSON.deserialize(resBody, SpecialAuthorityResponse.class);
            System.debug(sar);
        } catch (Exception e) {
            System.debug(e);
            String resBody = '{ "clientName": "SpecAuth", "requestUUID": "63d5bb9c-cbc9-4718-a11d-d651f7e72345", "medHistory": { "totalRecords": 7, "totalPages": 1, "medRecords": [ { "rxNumber": 445566, "quantity": 90, "refills": 0, "dinpin": 1234567, "directions": "TAKE 1/2 TABLET TWICE A DAY", "drugStrength": "25 MG", "genericName": "Generic thing", "daysSupply": 90, "dateDispensed": "2019-05-15", "presciberInfo": { "paymentAddress": { "country": "BC", "province": "BC", "city": "Somewhere", "addrLine1": "DH", "postalCode": "VVVVVV" }, "licenseNo": "99999", "code": "91", "phoneNumber": "+12505555555", "name": "MYNAME", "faxNumber": "+12505555555" }, "rxStatus": "F", "dispensingPharmacy": { "pharmacyId": "abc123", "phoneNumber": "+12505555555", "name": "EDDHBFDZATZOCI", "faxNumber": "+12505555555", "siteAddress": { "country": "BC", "province": "BC", "city": "COMOX", "addrLine1": "333 Street", "postalCode": "TFDFSL" } } } ] } }';
            sar = (SpecialAuthorityResponse) JSON.deserialize(resBody, SpecialAuthorityResponse.class);
            System.debug(sar);
        }
        return sar;
    }
}


