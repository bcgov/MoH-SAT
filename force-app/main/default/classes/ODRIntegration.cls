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

    // LWC Path
    @AuraEnabled(cacheable=true)
    public static PatientInformation verifyPatientInformationx(Id recordId) {
        SpecialAuthorityRequest sar = SpecialAuthorityRequest.build(recordId);

        // TODO: dmlUpdate
        return verifyPatientInformation(sar);
    }

    // AA Path
    public static PatientInformation verifyPatientInformation(SpecialAuthorityRequest sar) {
        // TODO: Webservice call here

        PatientInformation p = new PatientInformation();
        p.name = sar.saCase.Contact.Account.FirstName;
        p.phn = sar.saCase.Patient_Identifier__c;
        p.verified = true;
        p.verifiedDate = Datetime.now();
        p.dob = sar.saCase.Patient_Date_of_Birth__c;

        return p;
    }

    private static void updateCasePHNStatus(Id recordId, Boolean value) {
        Case caseToUpdate = [select Id, patient_validated__c FROM case WHERE Id =:recordId];
        caseToUpdate.patient_validated__c = value;
        update caseToUpdate;
    }


    // Make an ODR class that encapsulated the provider/patient information
    // TODO
    public static Provider getProvider(String practId, String practIdRef) {
      return new Provider();
    }
     // TODO
     public static PatientInformation getPatient(String phn) {
      return new PatientInformation();
    }

    @AuraEnabled(cacheable=true)
    public static Provider verifyCollegeInformation(Id recordId, Boolean dmlUpdate) {
        System.debug('verifyCollegeInformation');

        GetPractitioner getPractitionerObject = new GetPractitioner();
        getPractitionerObject.applicationUUID = getUUIDString();
        // TODO: Spec says this, but they're not allowing it yet and will make the call 400
        // even if it's good.
        // getPractitionerObject.userid = 'SALESFORCE';//getUserIdentifier();
        getPractitionerObject.programArea = 'SpecAuth';

        // TODO: De-hardcode
        getPractitionerObject.licenceNumber = '0A0P1';
        getPractitionerObject.collegeReferenceId = '91';

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

    @AuraEnabled
    public static List<SAApprovalRequest> getSAApprovalRequestsx(Id recordId) {
        SpecialAuthorityRequest sar = SpecialAuthorityRequest.build(recordId);

        return getSAApprovalRequests(sar);
    }

    public static List<SAApprovalRequest> getSAApprovalRequests(SpecialAuthorityRequest sar) {
        System.debug('---------------------------');
        System.debug(sar.saCase.Termination_Date__c);
        System.debug(sar.saCase.Effective_Date__c);

        List<SAApprovalRequest> saarList = new List<SAApprovalRequest>();

        if (sar.drug != null && sar.drug.Drug_Templates__r != null) {
        System.debug(sar.drug.Drug_Templates__r.size());
          for (Drug_Template__c drugTemplate : sar.drug.Drug_Templates__r){
              SAApprovalRequest sarBody = new SAApprovalRequest();
              sarBody.requestUUID = getUUIDString();
              sarBody.clientName = 'SpecAuth';
              sarBody.userid = 'SALESFORCE';//getUserIdentifier();
              sarBody.saRecord.phn = sar.saCase.Patient_Identifier__c;
              System.debug('SAR');
              System.debug(sarBody);

              if (sar.saCase.Effective_Date__c != null) {
                  sarBody.saRecord.effectiveDate = formatToODRDate(sar.saCase.Effective_Date__c); // Effective Date 3000/01/01
              }
              if (sar.saCase.Termination_Date__c != null) {
                  sarBody.saRecord.terminationDate = formatToODRDate(sar.saCase.Termination_Date__c); // Termination Date 3000/01/01
              }

              sarBody.saRecord.saRequester.practId    = sar.saCase.Provider__r.Provider_Identifier__c; // 0A0P1
              sarBody.saRecord.saRequester.practIdRef = getPractitionerCode(sar.saCase.Provider__r.Provider_Type__c);

              if (drugTemplate.Key_Type__c == 'RDP') {
                  sarBody.saRecord.specAuthType = 'R';
                  // Add the RDP type
                  sarBody.saRecord.specialItem.rdp = drugtemplate.Pharmanet_Code__c.replaceAll('[^0-9]+', '');

                  // Add excluded plans
                  List<String> thePlans = drugtemplate.Excluded_Plans__c.split(';');
                  for (string sPlan: thePlans) {
                      sarBody.saRecord.excludedPlans.add(sPlan);
                  }

                  // Add justification codes
                  List<String> theCodes = drugtemplate.Justification_Codes__c.split(';');
                  for (string sCode: theCodes) {
                      sarBody.saRecord.justificationCodes.add(sCode);
                  }

                  // TODO: Needs a field
                  sarBody.saRecord.maxDaysSupply = Integer.valueOf(drugtemplate.Days_Supply__c); // 999
                  // TODO: Needs a field
                  sarBody.saRecord.maxPricePct = drugtemplate.Price_Percent__c; // 100.0

                  // Loop body
                  System.debug(drugtemplate.Key_Type__c);
                  System.debug(drugtemplate.Pharmanet_Code__c);
                  System.debug(drugtemplate.SA_Type__c);
              } else if (drugTemplate.Key_Type__c == 'DIN') {
                  sarBody.saRecord.specAuthType = 'D';
                  // TODO: DIN never has dashes
              } else {
                  // R type
              }
              System.debug('sarBody--------------------------------');
              System.debug(sarBody);

              saarList.add(sarBody);
          }
        }
        return saarList;
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

    // Formats a date in what the ODR wants.
    private static String formatToODRDate(Date dateItem) {
        Date d = dateItem;
        Datetime dt = Datetime.newInstance(d, Time.newInstance(0, 0, 0, 0));
        String dateString = dt.format('yyyy/MM/dd');
        System.debug(dateString);
        return dateString;
    }

    @AuraEnabled
    public static List<SAApprovalRequestResponse> postSAApprovalx(Id recordId) {
        SpecialAuthorityRequest sar = SpecialAuthorityRequest.build(recordId);
        List<SAApprovalRequest> sarBodies = getSAApprovalRequests(sar);
        List<SAApprovalRequestResponse> responses = new List<SAApprovalRequestResponse>();

        for(SAApprovalRequest sarBody: sarBodies) {
          String saarObject = JSON.serialize(sarBody);
          System.debug('saarObject');
          System.debug(saarObject);

          SAApprovalRequestResponse saarr;
          CalloutResponse calloutResponseObject = sendRequestAndReturnBody(sar.saCase.Id,
                                                                          'callout:ODR_Credentials/odr/sat/pnetsa/saApproval',
                                                                          null,
                                                                          'POST',
                                                                          saarObject,
                                                                          '3A');

          if (calloutResponseObject.errorCode != 200) {
              // // ERROR
              saarr = new SAApprovalRequestResponse();
              saarr.error = calloutResponseObject;
          } else {
              String resBody = calloutResponseObject.response;
              saarr = (SAApprovalRequestResponse) JSON.deserialize(resBody, PrescriptionHistoryResponse.class);
          }
          System.debug('saarr');
          System.debug(saarr);
          responses.add(saarr);
      }
      return responses;
    }

    public static Boolean postSAApproval(SpecialAuthorityRequest sar) {
        System.debug('postSAApproval');

        List<SAApprovalRequest> sarBodies = getSAApprovalRequests(sar);

        for(SAApprovalRequest sarBody: sarBodies) {
            String saarObject = JSON.serialize(sarBody);
            System.debug('saarObject');
            System.debug(saarObject);

            SAApprovalRequestResponse saarr;
            CalloutResponse calloutResponseObject = sendRequestAndReturnBody(sar.saCase.Id,
                                                                            'callout:ODR_Credentials/odr/sat/pnetsa/saApproval',
                                                                            null,
                                                                            'POST',
                                                                            saarObject,
                                                                            '3A');

            if (calloutResponseObject.errorCode != 200) {
                return false;
                // // ERROR
                // saarr = new SAApprovalRequestResponse();
                // saarr.error = calloutResponseObject;
            } else {
                String resBody = calloutResponseObject.response;
                saarr = (SAApprovalRequestResponse) JSON.deserialize(resBody, PrescriptionHistoryResponse.class);
            }
            System.debug('saarr');
            System.debug(saarr);
        }
        return true;
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
    public static PrescriptionHistoryResponse fetchPrescriptionHistory(Id recordId, String page, String count, List<Integer> dinList) {
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