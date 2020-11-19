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
    public static BenefitsResponse fetchBenefits(Id recordId, String page, string count) {
        System.debug('Fetch Benefits');
        System.debug(page);
        System.debug(count);

        BenefitsResponse bres = null;

        String hexString = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(DateTime.now().getTime().format())));
        String UUID = hexString.SubString(0,8)
                    + '-' + hexString.SubString(8,12)
                    + '-' + hexString.SubString(12,16)
                    + '-' + hexString.SubString(16,20)
                    + '-' + hexString.substring(20);

        // Get PHN
        Case c = [select Id, contact.patient_identifier__c FROM case WHERE Id =:recordId];
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
            req.setEndpoint('callout:ODR_Credentials/ords/edwdev1/sat/pnetsa/benefits' + queryParams);
            req.setMethod('GET');
            Http http = new Http();
            HTTPResponse res = http.send(req);
            String resBody = res.getBody();
            System.debug(resBody);
            bres = (BenefitsResponse) JSON.deserialize(resBody, BenefitsResponse.class);
            System.debug(bres);
        } catch (Exception e) {
            // TODO remove stubbed data.
            System.debug('ERROR');
            bres = new BenefitsResponse();
            System.debug(bres);
        }
        // TODO: Get PHN that returns responses.
        String resBody = '{ "clientName": "SpecAuth", "requestUUID": "d2e44d88-52d6-4f24-b4f3-ef4f40c1cf59", "planIExpenditure": { "amount": 233.00, "year": 2020 }, "planEligibility": [ { "terminationDate": "3000-01-01", "authorityCode": "MSS", "authorityValue": "C", "authorityDesc": "MINISTRY OF SOCIAL SERVICES", "effectiveDate": "1998-12-22" } ], "restrictedClaimant": { "pracRestricts": [ { "terminationDate": "3000-01-01", "practitionerName": "YLNYMU, FRNWCKX", "practitionerDesc": "CPSBC - PHYSICIANS & SURGEONS", "pracitionerId": "91", "effectiveDate": "2012-05-04", "pracitionerRefId": "7F7S0" } ], "pharmRestricts": [ { "terminationDate": "3000-01-01", "pharmacyId": "BC00006509", "pharmacyName": "BNYLRPLXWJPUIPKWVZXJWFTTMZEDQ", "effectiveDate": "2012-07-20" } ] } }';
        bres = (BenefitsResponse) JSON.deserialize(resBody, BenefitsResponse.class);
        return bres;
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
            // &startDate=2001-01-01
            // &endDate=2020-01-01
            String queryParams = '?clientName=SpecAuth&requestUUID=' + UUID;
            queryParams += '&phn=' + c.contact.patient_identifier__c;
            queryParams += '&pageSize=' + count;
            queryParams += '&pageNo=' + page;
            // TODO
            // queryParams += '&startDate=2001-01-01';
            // queryParams += '&endDate=2020-01-01';
            req.setEndpoint('callout:ODR_Credentials/ords/edwdev1/sat/pnetsa/medHistory' + queryParams);
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
            sar = new SpecialAuthorityResponse();
            System.debug(sar);
        }
        return sar;
    }
}


