public with sharing class ODRIntegration {
    public ODRIntegration() { }

    @AuraEnabled(cacheable=true)
    public static Boolean verifyPHNInformation(Id recordId, String formData) {
        System.debug('verifyPHNInformation');
        String UUID = getUUIDString();

        // Get PHN
        Case c = [select Id, contact.patient_identifier__c FROM case WHERE Id =:recordId];
        System.debug('PATIENT DATA');
        System.debug(c.contact.patient_identifier__c);

        // TODO: Verify name matches what is returned by the ODR and set the contact information.
        Boolean retValue = verifyPHNData('TODO', formData);

        updateCasePHNStatus(recordId, retValue);

        return retValue;
    }

    public static Boolean verifyPHNData(String odrData, String formData) {
        // Validate what they sent and what we got from the DB
        return true;
    }

    private static void updateCasePHNStatus(Id recordId, Boolean value) {
        Case caseToUpdate = [select Id, patient_validated__c FROM case WHERE Id =:recordId];
        caseToUpdate.patient_validated__c = value;
        update caseToUpdate;
    }

    @AuraEnabled(cacheable=true)
    public static Provider verifyCollegeInformation(Id recordId, String formData) {
        System.debug('verifyCollegeInformation');
        String UUID = getUUIDString();

        Boolean retValue = verifyCollegeData('TODO', formData);

        // TODO: Verify name matches what is returned by the ODR
        Provider p = new Provider();
        p.name = 'Provider Name';
        p.collegeNumber = '4G3Q0';
        p.phoneNumber = '+12505555555';
        p.faxNumber = '+12505555555';
        p.verified = true;
        return p;
    }

    public static Boolean verifyCollegeData(String odrData, String formData) {
        // Validate what they sent and what we got from the DB
        return true;
    }

    @AuraEnabled
    public static SAApprovalRequestResponse postSAApproval(Id recordId) {
        System.debug('postSAApproval');
        String UUID = getUUIDString();

        Case c = [select Id, contact.patient_identifier__c FROM case WHERE Id =:recordId];
        System.debug('c.contact.patient_identifier__c');
        System.debug(c.contact.patient_identifier__c);

        // Send SA Approval into Pharmanet
        SAApprovalRequest sarBody = new SAApprovalRequest();
        sarBody.requestUUID = UUID;
        sarBody.clientName = 'SpecAuth';
        sarBody.phn = c.contact.patient_identifier__c;

        String saarObject = JSON.serialize(sarBody);
        System.debug('saarObject');
        System.debug(saarObject);
        SAApprovalRequestResponse saarr;
        try {
            String resBody = sendRequestAndReturnBody('callout:ODR_Credentials/ords/edwdev1/sat/pnetsa/saApproval', null, 'POST', saarObject);
            saarr = (SAApprovalRequestResponse) JSON.deserialize(resBody, SAApprovalRequestResponse.class);
            System.debug('saarr');
            System.debug(saarr);

            // Write the successful approval into the DB
            if (saarr.statusMessage == 'Success') {
                c.Pushed_to_Pnet__c = true;
                c.Pushed_to_Pnet_Date__c = Datetime.now();
                update c;
            }
        } catch (APIException e) {
            System.debug('Error in API');
            System.debug(e);
        }
        return saarr;
    }

    @AuraEnabled(cacheable=true)
    public static BenefitsResponse fetchBenefits(Id recordId, String page, string count) {
        System.debug('Fetch Benefits');
        System.debug(page);
        System.debug(count);

        BenefitsResponse bres = null;
        String UUID = getUUIDString();

        // Get PHN
        Case c = [select Id, contact.patient_identifier__c FROM case WHERE Id =:recordId];
        System.debug('PATIENT DATA');
        System.debug(c.contact.patient_identifier__c);
        try {
            String queryParams = '?clientName=SpecAuth&requestUUID=' + UUID;
            queryParams += '&phn=' + c.contact.patient_identifier__c;
            // ?clientName=SpecAuth
            // &requestUUID=51255567-9713-4ac1-a5aa-ec0e0bb951d6
            // &phn=9999999999
            String resBody = sendRequestAndReturnBody('callout:ODR_Credentials/ords/edwdev1/sat/pnetsa/benefits', queryParams, 'GET', null);
            bres = (BenefitsResponse) JSON.deserialize(resBody, BenefitsResponse.class);
            System.debug(bres);
        } catch (APIException e) {
            System.debug('ERROR');
            bres = new BenefitsResponse();
            System.debug(bres);
        }
        return bres;
    }

    @AuraEnabled(cacheable=true)
    public static PrescriptionHistoryResponse fetchPrescriptionHistory(Id caseId, String page, String count) {
        System.debug('Fetch Data');
        System.debug(page);
        System.debug(count);

        PrescriptionHistoryResponse sar = null;
        String UUID = getUUIDString();

        // Get PHN
        Case c = [select Id, contact.patient_identifier__c FROM case WHERE Id =:caseId];
        System.debug('PATIENT DATA');
        System.debug(c.contact.patient_identifier__c);

        try {
            String queryParams = '?clientName=SpecAuth&requestUUID=' + UUID;
            queryParams += '&phn=' + c.contact.patient_identifier__c;
            queryParams += '&pageSize=' + count;
            queryParams += '&pageNo=' + page;
            // ?clientName=SpecAuth
            // &requestUUID=51255567-9713-4ac1-a5aa-ec0e0bb951d6
            // &phn=9999999999
            // &pageSize=10
            // &pageNo=1
            // &startDate=2001-01-01
            // &endDate=2020-01-01
            // TODO
            // queryParams += '&startDate=2001-01-01';
            // queryParams += '&endDate=2020-01-01';
            String resBody = sendRequestAndReturnBody('callout:ODR_Credentials/ords/edwdev1/sat/pnetsa/medHistory', queryParams, 'GET', null);
            sar = (PrescriptionHistoryResponse) JSON.deserialize(resBody, PrescriptionHistoryResponse.class);
            System.debug(sar);
        } catch (APIException e) {
            System.debug('ERROR');
            sar = new PrescriptionHistoryResponse();
            System.debug(sar);
        }
        return sar;
    }

    private static String getUUIDString() {
        String hexString = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(DateTime.now().getTime().format())));
        return hexString.SubString(0,8)
                    + '-' + hexString.SubString(8,12)
                    + '-' + hexString.SubString(12,16)
                    + '-' + hexString.SubString(16,20)
                    + '-' + hexString.substring(20);
    }

    private static String sendRequestAndReturnBody(String endpoint, String queryParams, String method, String methodBody) {
        String uri = endpoint;
        if (queryParams != null) {
            uri += queryParams;
        }

        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type','application/json');
        req.setEndpoint(uri);
        req.setMethod(method);
        req.setCompressed(true);
        
        // If post, construct postBody
        if (method == 'POST') {
            req.setBody(methodBody);
        }

        Http http = new Http();
        HTTPResponse res = http.send(req);
        String resBody = res.getBody();
        if (res.getStatusCode() == 200) {
            System.debug(resBody);
        } else {
            throw new APIException(resBody);
        }
        return resBody;
    }
}


