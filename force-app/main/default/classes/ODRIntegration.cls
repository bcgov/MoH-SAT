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
    public static PatientInformation verifyPatientInformation(Id recordId, Boolean dmlUpdate) {
        Case c = [select Id, Patient_Date_of_Birth__c, contact.patient_identifier__c ,contact.name FROM case WHERE Id =:recordId];

        // TODO: de-harcode
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
    public static Provider verifyCollegeInformation(Id recordId, Boolean dmlUpdate) {
        System.debug('verifyCollegeInformation');

        SpecialAuthorityRequest sar = SpecialAuthorityRequest.build(recordId);

        GetPractitioner getPractitionerObject = new GetPractitioner();
        getPractitionerObject.applicationUUID = getUUIDString();
        // TODO: Spec says this, but they're not allowing it yet and will make the call 400
        // even if it's good.
        // getPractitionerObject.userid = 'SALESFORCE';//getUserIdentifier();
        getPractitionerObject.programArea = 'SpecAuth';

        getPractitionerObject.licenceNumber = sar.saCase.Provider__r.Provider_Identifier__c;
        getPractitionerObject.collegeReferenceId = getPractitionerCode(sar.saCase.Provider__r.Provider_Type__c);

        String saarObject = JSON.serialize(getPractitionerObject);

        CalloutResponse calloutResponseObject = sendRequestAndReturnBody(recordId,
                                                                         'callout:ODR_Credentials/primesvc/getPractitioner',
                                                                         null,
                                                                         'POST',
                                                                         saarObject,
                                                                         '4');
        Provider p = null;
        if (calloutResponseObject.errorCode != 200) {
            // ERROR
            System.debug('*******************xxx');
            System.debug(calloutResponseObject.errorCode);
            // saarr = new SAApprovalRequestResponse();
            // saarr.error = calloutResponseObject;
            p = new Provider();
            p.verified = false;
        } else {
            String resBody = calloutResponseObject.response;
            System.debug('*******************');
            System.debug(resBody);

            // {
            //     applicationUUID: "",
            //     firstName: "",
            //     middleInitial: "",
            //     lastName: "",
            //     dateofBirth: "",
            //     status: "",
            //     effectiveDate: "",
            // }

            // TODO: This should really be receiving an object, but using this for now as the API is returning
            // an array instead of a list.
            List<Provider> providers = (List<Provider>) JSON.deserialize(resBody, List<Provider>.class);
            // Sometimes this is empty!
            if (!providers.isEmpty()) {
                p = providers[0];
                if (p.status == 'P') {
                    // Practising
                    p.verified = true;
                } else {
                    p.verified = true;
                }
            } else {
                // Invalid Provider
                p = new Provider();
                p.verified = false;
            }

        }
        System.debug('saarr');
        return p;
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

    @AuraEnabled
    public static SAApprovalRequest getSAApprovalRequest(Id recordId) {

        Case c = [select Id, Drug__r.Pharmanet_Code__c, Provider__r.Provider_Type__c, SA_Type__c, Termination_Date__c, Effective_Date__c, contact.patient_identifier__c, contact.name FROM case WHERE Id =:recordId];
        System.debug('---------------------------');
        System.debug(c.Termination_Date__c);
        System.debug(c.Effective_Date__c);
        // Send SA Approval into Pharmanet
        SAApprovalRequest sarBody = new SAApprovalRequest();
        sarBody.requestUUID = getUUIDString();
        sarBody.clientName = 'SpecAuth';
        sarBody.userid = 'SALESFORCE';//getUserIdentifier();
        sarBody.saRecord.phn = c.contact.patient_identifier__c;
        System.debug('SAR');
        System.debug(sarBody);

        // sarBody.saRecord.specialItem.din = '98789';
        // Drug__r.Pharmanet_Code__c for supercode
        // TODO: This isn't working OOTB
        sarBody.saRecord.specialItem.rdp = '99010146'; //c.Drug__r.Pharmanet_Code__c.replaceAll('[^0-9]+', ''); 

        SpecialAuthorityRequest sar = SpecialAuthorityRequest.build(recordId);

        // contact.account.Provider_Type__c to 2 digit prac_id_ref
        String practId = sar.saCase.Provider__r.Provider_Identifier__c;
        String practIdRef = getPractitionerCode(sar.saCase.Provider__r.Provider_Type__c);

        System.debug('99999999999');
        System.debug(practId);
        System.debug(practIdRef);

        // TODO: This isn't working OOTB
        sarBody.saRecord.specAuthType = 'B';//c.SA_Type__c; // Special Auth Type: B,L,R
        sarBody.saRecord.justificationCodes.add('R'); // D or R
        sarBody.saRecord.excludedPlans.add('B'); // ['B','C','CN','D',]
        sarBody.saRecord.saRequester.practIdRef = practIdRef; // 91
        sarBody.saRecord.saRequester.practId = practId; // 12345
        if (c.Effective_Date__c != null) {
            sarBody.saRecord.effectiveDate = formatToODRDate(c.Effective_Date__c); // Effective Date 3000/01/01
        }
        if (c.Termination_Date__c != null) {
            sarBody.saRecord.terminationDate = formatToODRDate(c.Termination_Date__c); // Termination Date 3000/01/01
        }
        sarBody.saRecord.maxDaysSupply = 999; // 999
        sarBody.saRecord.maxPricePct = 100.0; // 100.0

        return sarBody;
    }

    // Formats a date in what the ODR wants.
    private static String formatToODRDate(Date dateItem) {
        Date d = dateItem;
        Datetime dt = Datetime.newInstance(d, Time.newInstance(0, 0, 0, 0));
        String dateString = dt.format('yyyy/MM/dd');
        System.debug(dateString);
        return dateString;
    }

    @AuraEnabled
    public static SAApprovalRequestResponse postSAApproval(Id recordId, Boolean dmlUpdate) {
        System.debug('postSAApproval');

        SAApprovalRequest sarBody = getSAApprovalRequest(recordId);


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
                // Only store if DML param is true
                if (dmlUpdate == true) {
                    updateCasePusedToPNet(recordId);
                }
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
        queryParams += '&userid=SALESFORCE';// + getUserIdentifier();

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
    public static PrescriptionHistoryResponse fetchPrescriptionHistory(Id recordId, String page, String count, List<Integer> dinList) {
        System.debug('Fetch Data');
        System.debug(page);
        System.debug(count);

        PrescriptionHistoryResponse sar = null;

        String queryParams = '?clientName=SpecAuth';
        queryParams += '&requestUUID=' + getUUIDString();
        queryParams += '&userid=SALESFORCE';// + getUserIdentifier();
        queryParams += '&phn=' + getPatientIdentifier(recordId);
        queryParams += '&pageSize=' + count;
        queryParams += '&pageNo=' + page;
        if (dinList.size() > 0) {
            queryParams += '&dinList=' + JSON.serialize(dinList);
        }
        System.debug(queryParams);
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
            if (resObject.errorCode == 200
                || resObject.errorCode == 201) {
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
                System.debug('*********************************************');
                System.debug(resObject.response);

                if (resObject.response != '') {
                    ODRErrorResponse errResp = (ODRErrorResponse) JSON.deserialize(resObject.response, ODRErrorResponse.class);
                    ODRBusinessErrorResponse businessErrorResp = (ODRBusinessErrorResponse) JSON.deserialize(resObject.response, ODRBusinessErrorResponse.class);

                    System.debug(businessErrorResp);

                    if (businessErrorResp.status == '-1') {
                        // business error
                        resObject.errorMessage = 'Error: ' + businessErrorResp.statusMessage;
                    } else {
                        // Oracle error
                        resObject.errorMessage = 'API Error: ' + errResp.message;
                    }

                    System.debug(errResp);

                    List<Logging_Event__e> loggingEvents = new List<Logging_Event__e>();
                    loggingEvents.add(new Logging_Event__e(code__c=resObject.errorCode,
                                                        message__c=resObject.errorMessage,
                                                        caseId__c=recordId,
                                                        type__c=integrationName));
                    EventBus.publish(loggingEvents);
                    System.debug('API Error: ' + resObject.errorCode + ' ' + resObject.errorMessage);
                } else {
                    // error, but no response
                    resObject.errorMessage = 'Error in call, no response text given';
                    System.debug('Error in call, no response text given.');
                    List<Logging_Event__e> loggingEvents = new List<Logging_Event__e>();
                    loggingEvents.add(new Logging_Event__e(code__c=resObject.errorCode,
                                                        message__c=resObject.errorMessage,
                                                        caseId__c=recordId,
                                                        type__c=integrationName));
                    EventBus.publish(loggingEvents);
                }
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