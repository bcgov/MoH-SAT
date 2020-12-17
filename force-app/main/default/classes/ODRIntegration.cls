public with sharing class ODRIntegration {
    public ODRIntegration() { }

    @AuraEnabled(cacheable=true)
    public static Boolean verifyPHNInformation(Id recordId, String formData) {
        System.debug('verifyPHNInformation');
        String UUID = getUUIDString();
        String patientIdentifier = getPatientIdentifier(recordId);

        // TODO: Verify name matches what is returned by the ODR and set the contact information.
        Boolean retValue = verifyPHNData('TODO', formData);

        updateCasePHNStatus(recordId, retValue);

        return retValue;
    }

    public static Boolean verifyPHNData(String odrData, String formData) {
        // Validate what they sent and what we got from the DB
        return true;
    }

    @AuraEnabled(cacheable=true)
    public static PatientInformation verifyPatientInformation(Id recordId) {
        Case c = [select Id, Patient_Date_of_Birth__c, contact.patient_identifier__c ,contact.name FROM case WHERE Id =:recordId];

        PatientInformation p = new PatientInformation();
        p.name = c.contact.name;
        p.phn = c.contact.patient_identifier__c;
        p.verified = true;
        p.verifiedDate = Datetime.now();
        p.dob = c.Patient_Date_of_Birth__c;

        return p;
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

        // Send SA Approval into Pharmanet
        SAApprovalRequest sarBody = new SAApprovalRequest();
        sarBody.requestUUID = getUUIDString();
        sarBody.clientName = 'SpecAuth';
        sarBody.userid = getUserIdentifier();

        // SA Unique Identifier
        sarBody.phn = getPatientIdentifier(recordId); // PHN
        // sarBody.authType = // Auth Type  TBD? API Doc says required, but N/A?
        // sarBody.specialItem = // DIN or RDP Cat/Subcat, but we don't know the web service parameter.. says N/A
        // sarBody.specialType = // D or R
        // sarBody.effectiveDate = // Effective Date 3000/01/01
        // sarBody.typeSA = // Special Auth Type: B,L,R

        String saarObject = JSON.serialize(sarBody);
        System.debug('saarObject');
        System.debug(saarObject);

        SAApprovalRequestResponse saarr;
        CalloutResponse calloutResponseObject = sendRequestAndReturnBody(recordId,
                                                                         'callout:ODR_Credentials/odr/sat/pnetsa/saApproval',
                                                                         null,
                                                                         'POST',
                                                                         saarObject,
                                                                         '3A');

        if (calloutResponseObject.errorCode != 200) {
            // ERROR
            saarr = new SAApprovalRequestResponse();
            saarr.error = calloutResponseObject;
        } else {
            String resBody = calloutResponseObject.response;
            saarr = (SAApprovalRequestResponse) JSON.deserialize(resBody, PrescriptionHistoryResponse.class);
            // Write the successful approval into the DB
            if (saarr.statusMessage == 'Success') {
                updateCasePusedToPNet(recordId);
            }
        }
        System.debug('saarr');
        System.debug(saarr);
        return saarr;
    }

    @AuraEnabled
    public static BenefitsResponse fetchBenefits(Id recordId) {
        System.debug('Fetch Benefits');

        BenefitsResponse bres = null;

        String queryParams = '?clientName=SpecAuth';
        queryParams += '&requestUUID=' + getUUIDString();
        queryParams += '&phn=' + getPatientIdentifier(recordId);
        queryParams += '&userid=' + getUserIdentifier();

        CalloutResponse calloutResponseObject = sendRequestAndReturnBody(recordId,
                                                                         'callout:ODR_Credentials/odr/sat/pnetsa/benefits',
                                                                         queryParams,
                                                                         'GET',
                                                                         null,
                                                                         '2');

        if (calloutResponseObject.errorCode != 200) {
            // ERROR
            bres = new BenefitsResponse();
            bres.error = calloutResponseObject;
        } else {
            String resBody = calloutResponseObject.response;
            bres = (BenefitsResponse) JSON.deserialize(resBody, BenefitsResponse.class);
        }

        System.debug(bres);
        return bres;
    }

    @AuraEnabled
    public static PrescriptionHistoryResponse fetchPrescriptionHistory(Id recordId, String page, String count) {
        System.debug('Fetch Data');
        System.debug(page);
        System.debug(count);

        PrescriptionHistoryResponse sar = null;

        String queryParams = '?clientName=SpecAuth';
        queryParams += '&requestUUID=' + getUUIDString();
        queryParams += '&userid=' + getUserIdentifier();
        queryParams += '&phn=' + getPatientIdentifier(recordId);
        queryParams += '&pageSize=' + count;
        queryParams += '&pageNo=' + page;
        // TODO?
        // queryParams += '&startDate=2001-01-01';
        // queryParams += '&endDate=2020-01-01';
        CalloutResponse calloutResponseObject = sendRequestAndReturnBody(recordId,
                                                                         'callout:ODR_Credentials/odr/sat/pnetsa/medHistory',
                                                                         queryParams,
                                                                         'GET',
                                                                         null,
                                                                         '1');

        if (calloutResponseObject.errorCode != 200) {
            // ERROR
            sar = new PrescriptionHistoryResponse();
            sar.error = calloutResponseObject;
        } else {
            String resBody = calloutResponseObject.response;
            sar = (PrescriptionHistoryResponse) JSON.deserialize(resBody, PrescriptionHistoryResponse.class);
        }
        System.debug(sar);

        return sar;
    }

    private static void updateCasePusedToPNet(Id caseId) {
        Case c = [select Id, contact.patient_identifier__c FROM case WHERE Id =:caseId];
        c.Pushed_to_Pnet__c = true;
        c.Pushed_to_Pnet_Date__c = Datetime.now();
        update c;
    }

    private static String getPatientIdentifier(Id recordId) {
        System.debug('PATIENT DATA');
        // Get PHN from DB
        Case c = [select Id, contact.patient_identifier__c FROM case WHERE Id =:recordId];
        System.debug(c.contact.patient_identifier__c);

        return c.contact.patient_identifier__c;
    }

    private static String getUserIdentifier() {
        // Who's calling this?
        String userid = [Select FederationIdentifier From User Where Id = :UserInfo.getUserId()][0].FederationIdentifier;
        return userid;
    }

    private static String getUUIDString() {
        String hexString = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(DateTime.now().getTime().format())));
        return hexString.SubString(0,8)
                    + '-' + hexString.SubString(8,12)
                    + '-' + hexString.SubString(12,16)
                    + '-' + hexString.SubString(16,20)
                    + '-' + hexString.substring(20);
    }

    private static CalloutResponse sendRequestAndReturnBody(Id recordId,
                                                            String endpoint,
                                                            String queryParams,
                                                            String method,
                                                            String methodBody,
                                                            String integrationName) {
        System.debug('SRARB:' + recordId + endpoint);
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
        CalloutResponse resObject = new CalloutResponse();
        try {
            HTTPResponse res = http.send(req);
            resObject.response = res.getBody();

            resObject.errorCode = res.getStatusCode();
            if (resObject.errorCode == 200) {
                // Log here
                System.debug(resObject.response);
                List<Logging_Event__e> loggingEvents = new List<Logging_Event__e>();
                loggingEvents.add(new Logging_Event__e(code__c=resObject.errorCode,
                                                       message__c='Success',
                                                       caseId__c=recordId,
                                                       type__c=integrationName));
                EventBus.publish(loggingEvents);
                return resObject;
            } else {
                resObject.errorMessage = 'API Error';

                List<Logging_Event__e> loggingEvents = new List<Logging_Event__e>();
                loggingEvents.add(new Logging_Event__e(code__c=resObject.errorCode,
                                                       message__c=resObject.errorMessage,
                                                       caseId__c=recordId,
                                                       type__c=integrationName));
                EventBus.publish(loggingEvents);
                System.debug('API Error: ' + resObject.errorCode + ' ' + resObject.errorMessage);
            }
        } catch (CalloutException e) {
            resObject.errorCode = 500;
            resObject.errorMessage = e.getMessage();

            List<Logging_Event__e> loggingEvents = new List<Logging_Event__e>();
            loggingEvents.add(new Logging_Event__e(code__c=resObject.errorCode,
                                                   message__c=resObject.errorMessage,
                                                   caseId__c=recordId,
                                                   type__c=integrationName));
            EventBus.publish(loggingEvents);
            System.debug('API Error: ' + resObject.errorCode + ' ' + resObject.errorMessage);
        }
        return resObject;
    }
}