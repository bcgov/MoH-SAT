public with sharing class ODRIntegration {
    public ODRIntegration() { }

    @AuraEnabled(cacheable=true)
    public static Boolean verifyPHNInformation(Id recordId, String phn, String name) {
        System.debug('verifyPHNInformation');

        // Get PHN
        // Case c = [select Id, contact.patient_identifier__c FROM record WHERE Id =:recordId];
        // System.debug('PATIENT DATA');
        // System.debug(c.contact.patient_identifier__c);

        // TODO: Verify name matches what is returned by the ODR
        return true;
    }

    @AuraEnabled(cacheable=true)
    public static Provider verifyCollegeInformation(Id recordId, String collegeNumber, String collegeName) {
        System.debug('verifyCollegeInformation');

        // Verify PHN, Name and College ID
        // Case c = [select Id, contact.patient_identifier__c FROM case WHERE Id =:recordId];
        // System.debug('PATIENT DATA');
        // System.debug(c.contact.patient_identifier__c);

        // TODO: Verify name matches what is returned by the ODR
        Provider p = new Provider();
        p.name = 'Provider Name';
        p.collegeNumber = '4G3Q0';
        p.phoneNumber = '+12505555555';
        p.faxNumber = '+12505555555';
        p.verified = true;
        return p;
    }

    @AuraEnabled(cacheable=true)
    public static BenefitsResponse fetchBenefits(Id caseId, String page, string count) {
        System.debug('Fetch Benefits');
        System.debug(page);
        System.debug(count);

        BenefitsResponse sar = null;

        String hexString = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(DateTime.now().getTime().format())));
        String UUID = hexString.SubString(0,8)
                    + '-' + hexString.SubString(8,12)
                    + '-' + hexString.SubString(12,16)
                    + '-' + hexString.SubString(16,20)
                    + '-' + hexString.substring(20);

        // Get PHN
        Case c = [select Id, contact.patient_identifier__c FROM case WHERE Id =:caseId];
        System.debug('PATIENT DATA');
        System.debug(c.contact.patient_identifier__c);
        try {
            HttpRequest req = new HttpRequest();
            req.setHeader('Content-Type','application/json');
            // ?clientName=SpecAuth
            // &requestUUID=51255567-9713-4ac1-a5aa-ec0e0bb951d6
            // &phn=9999999999
            String queryParams = '?clientName=SpecAuth&requestUUID=' + UUID;
            queryParams += '&phn=' + c.contact.patient_identifier__c;
            req.setEndpoint('callout:ODR_Credentials/ords/edwdev1/sat/pnetsa/getBenefits' + queryParams);
            req.setMethod('GET');
            Http http = new Http();
            HTTPResponse res = http.send(req);
            String resBody = res.getBody();
            System.debug(resBody);
            sar = (BenefitsResponse) JSON.deserialize(resBody, BenefitsResponse.class);
            System.debug(sar);
        } catch (Exception e) {
            // TODO remove stubbed data.
            System.debug('ERROR');
            sar = new BenefitsResponse();
            System.debug(sar);
        }
        return sar;
    }

    @AuraEnabled(cacheable=true)
    public static SpecialAuthorityResponse fetchSAHistory(Id caseId, String page, String count) {
        System.debug('Fetch Data');
        System.debug(page);
        System.debug(count);

        SpecialAuthorityResponse sar = null;

        String hexString = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(DateTime.now().getTime().format())));
        String UUID = hexString.SubString(0,8)
                    + '-' + hexString.SubString(8,12)
                    + '-' + hexString.SubString(12,16)
                    + '-' + hexString.SubString(16,20)
                    + '-' + hexString.substring(20);

        // Get PHN
        Case c = [select Id, contact.patient_identifier__c FROM case WHERE Id =:caseId];
        System.debug('PATIENT DATA');
        System.debug(c.contact.patient_identifier__c);

        // PHN that works in dev
        // caseId = '9735352567';

        try {
            HttpRequest req = new HttpRequest();
            req.setHeader('Content-Type','application/json');
            // req.setEndpoint('callout:ODR_Credentials/ords/edwdev1/sat/pnetsa/dummy');
            // ?clientName=SpecAuth
            // &requestUUID=51255567-9713-4ac1-a5aa-ec0e0bb951d6
            // &phn=9999999999
            // &pageSize=10
            // &pageNo=1
            // &searchStartDate=2001-01-01
            // &searchEndDate=2020-01-01
            String queryParams = '?clientName=SpecAuth&requestUUID=' + UUID;
            queryParams += '&phn=' + c.contact.patient_identifier__c;
            queryParams += '&pageSize=' + count;
            queryParams += '&pageNo=' + page;
            // TODO
            // queryParams += '&searchStartDate=2001-01-01';
            // queryParams += '&searchEndDate=2020-01-01';
            req.setEndpoint('callout:ODR_Credentials/ords/edwdev1/sat/pnetsa/getMedHistory' + queryParams);
            req.setMethod('GET');
            Http http = new Http();
            HTTPResponse res = http.send(req);
            String resBody = res.getBody();
            System.debug(resBody);
            sar = (SpecialAuthorityResponse) JSON.deserialize(resBody, SpecialAuthorityResponse.class);
            System.debug(sar);
        } catch (Exception e) {
            // TODO remove stubbed data.
            System.debug('ERROR');
            // String resBody = '{ "clientName": "SpecAuth", "requestUUID": "63d5bb9c-cbc9-4718-a11d-d651f7e72345", "medHistory": { "totalRecords": 7, "totalPages": 7, "medRecords": [ { "rxNumber": 445566, "quantity": 90, "refills": 0, "dinpin": 1234567, "directions": "TAKE 1/2 TABLET TWICE A DAY", "drugStrength": "25 MG", "genericName": "Generic thing", "daysSupply": 90, "dateDispensed": "2019-05-15", "presciberInfo": { "paymentAddress": { "country": "BC", "province": "BC", "city": "Somewhere", "addrLine1": "DH", "postalCode": "VVVVVV" }, "licenseNo": "99999", "code": "91", "phoneNumber": "+12505555555", "name": "MYNAME", "faxNumber": "+12505555555" }, "rxStatus": "F", "dispensingPharmacy": { "pharmacyId": "abc123", "phoneNumber": "+12505555555", "name": "EDDHBFDZATZOCI", "faxNumber": "+12505555555", "siteAddress": { "country": "BC", "province": "BC", "city": "COMOX", "addrLine1": "333 Street", "postalCode": "TFDFSL" } } } ] } }';
            sar = new SpecialAuthorityResponse(); //(SpecialAuthorityResponse) JSON.deserialize(resBody, SpecialAuthorityResponse.class);
            System.debug(sar);
        }
        return sar;
    }
}


