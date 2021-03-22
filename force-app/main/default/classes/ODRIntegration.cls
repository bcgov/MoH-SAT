public with sharing class ODRIntegration {
    public ODRIntegration() { }

    // LWC Path
    @AuraEnabled(cacheable=true)
    public static Patient verifyPatientInformationx(Id recordId) {
        SpecialAuthorityRequest sar = SpecialAuthorityRequest.build(recordId);

        // TODO: dmlUpdate
        return verifyPatientInformation(sar);
    }

    // AA Path
    public static Patient verifyPatientInformation(SpecialAuthorityRequest sar) {
        Patient p;
        List<Logging_Event__e> loggingEvents = new List<Logging_Event__e>();
        try {
            p = EmpiIntegration.getPatient(sar.saCase.Patient_Identifier__c);

            p.verifiedDate = Datetime.now();

            String familyName = '';
            List<String> givenList;

            if (p.names != null) {
              for (Integer i = 0;i < p.names.size();i++) {
                if (p.names[i].type == 'L') {
                  familyName = p.names[i].familyName;
                  givenList = p.names[i].givenNames.clone();
                }
              }
            }

            Boolean bGivenNamesValid = false;
            // Check if firstname exists in the EMPI given name list somewhere
            try {
              if (givenList.contains(sar.saCase.Contact.Account.FirstName.split(' ')[0])) {
                bGivenNamesValid = true;
              }
            } catch (Exception e) {
              System.debug('Error');
              System.debug(e);
            }

            // Safety Checks
            if (p.deceased
               || !checkValidBirthDate(p.dob, sar.saCase.Patient_Date_of_Birth__c)
               || !bGivenNamesValid
               || sar.saCase.Contact.Account.LastName.toLowercase() != familyName.toLowercase())
            {
                p.verified = false;
            } else {
                p.verified = true;
            }
            loggingEvents.add(new Logging_Event__e(code__c=200,
                                                message__c='Success',
                                                caseId__c=sar.saCase.Id,
                                                type__c='5'));
        } catch (CalloutException e) {
            System.debug('EMPI Callout Exception');
            loggingEvents.add(new Logging_Event__e(code__c=500,
                                                message__c='EMPI Callout Exception',
                                                caseId__c=sar.saCase.Id,
                                                type__c='5'));
        }
        EventBus.publish(loggingEvents);
        return p;
    }

    public static Boolean checkValidBirthDate(DateTime first, DateTime second) {
        if (first == null || second == null) {
            return false;
        }

        if (first.day() == second.day() && first.month() == second.month() && first.year() == second.year()) {
            return true;
        } else {
            return false;
        }
    }

    public static void updateCasePHNStatus(Id recordId, Boolean value) {
        Case caseToUpdate = [select Id, patient_validated__c FROM case WHERE Id =:recordId];
        caseToUpdate.patient_validated__c = value;
        update caseToUpdate;
    }

    public static Provider getProviderWithRecordId(Id recordId, String practId, String practIdRef) {
        GetPractitioner getPractitionerObject = new GetPractitioner();
        getPractitionerObject.applicationUUID = getUUIDString();
        getPractitionerObject.programArea = 'SpecAuth';
        getPractitionerObject.licenceNumber    = practId.deleteWhitespace();
        getPractitionerObject.collegeReferenceId = getPractitionerCode(practIdRef.deleteWhitespace());

        Provider p = null;
        String saarObject = JSON.serialize(getPractitionerObject);

        CalloutResponse calloutResponseObject = sendRequestAndReturnBody(recordId,
                                                                         'callout:ODR_Credentials/primesvc/getPractitioner',
                                                                         null,
                                                                         'POST',
                                                                         saarObject,
                                                                         '4');
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
        return p;
    }

    public static Provider getProvider(String practId, String practIdRef) {
        return getProviderWithRecordId(null, practId, practIdRef);
    }

     // TODO
     public static Patient getPatient(String phn) {
      return new Patient();
    }

    @AuraEnabled(cacheable=true)
    public static Provider verifyCollegeInformation(Id recordId) {
        System.debug('verifyCollegeInformation');
        System.debug(recordId);

        SpecialAuthorityRequest sar = SpecialAuthorityRequest.build(recordId);
        Provider p = getProviderWithRecordId(recordId, sar.saCase.Provider__r.Provider_Identifier__c, sar.saCase.Provider__r.Provider_Type__c);
        System.debug('saarr');
        return p;
    }

    public static List<SAApprovalRequest> getSAApprovalRequests(SpecialAuthorityRequest sar) {
        List<SAApprovalRequest> saarList = new List<SAApprovalRequest>();

        if (sar.drug != null && sar.drug.Drug_Templates__r != null) {
          for (Drug_Template__c drugTemplate : sar.drug.Drug_Templates__r){
              SAApprovalRequest sarBody = new SAApprovalRequest();
              sarBody.requestUUID = getUUIDString();
              sarBody.clientName = 'SpecAuth';
              sarBody.userid = getUserIdentifier();
              sarBody.saRecord.phn = sar.saCase.Patient_Identifier__c;

              if (sar.saCase.Effective_Date__c != null) {
                  sarBody.saRecord.effectiveDate = formatToODRDate(sar.saCase.Effective_Date__c); // Effective Date 3000/01/01
              }
              if (sar.saCase.Termination_Date__c != null) {
                  Date terminationDate = calculateTerminationDate(
                    sar.saCase.Effective_Date__c, 
                    Integer.valueOf(drugTemplate.Duration__c), 
                    drugTemplate.Duration_Unit__c
                  );

                  sarBody.saRecord.terminationDate = formatToODRDate(terminationDate);
              }

              sarBody.saRecord.specAuthType = drugTemplate.SA_Type__c;
              sarBody.saRecord.saRequester.practId    = sar.saCase.Provider__r.Provider_Identifier__c; // 0A0P1
              sarBody.saRecord.saRequester.practIdRef = getPractitionerCode(sar.saCase.Provider__r.Provider_Type__c);
              sarBody.saRecord.maxDaysSupply = Integer.valueOf(drugtemplate.Days_Supply__c);
              sarBody.saRecord.maxPricePct = drugtemplate.Price_Percent__c;
              sarBody.saRecord.excludedPlans = drugtemplate.Excluded_Plans__c?.split(';');
              sarBody.saRecord.justificationCodes = drugtemplate.Justification_Codes__c?.split(';');
              
              String dinOrRdp = drugtemplate.Pharmanet_Code__c?.replaceAll('[^0-9]+', '');
              sarBody.saRecord.specialItem.rdp = drugTemplate.Key_Type__c == 'RDP' ? dinOrRdp : null;
              sarBody.saRecord.specialItem.din = drugTemplate.Key_Type__c == 'DIN' ? dinOrRdp : null;
              
              saarList.add(sarBody);
          }
        }
        return saarList;
    }

    public static Date calculateTerminationDate(Date startDate, Integer duration, String durationUnit) {
        Date terminationDate = startDate;

        if (String.isBlank(durationUnit) || durationUnit.equalsIgnoreCase('Indefinite')) {
            terminationDate = Date.newInstance(3000, 1, 1);
        } else if (durationUnit.equalsIgnoreCase('End of year')) {
            terminationDate = Date.newInstance(terminationDate.year(), 12, 31);
        } else if (durationUnit.equalsIgnoreCase('Days')) {
            terminationDate = terminationDate.addDays(duration);
        } else if (durationUnit.equalsIgnoreCase('Months')) {
            terminationDate = terminationDate.addMonths(duration);
        } else if (durationUnit.equalsIgnoreCase('Years')) {
            terminationDate = terminationDate.addYears(duration);
        }

        return terminationDate;
    }

    public static String getPractitionerCode(String name) {
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
                practIdCode = '81';
            }
        }
        return practIdCode;
    }

    // Formats a date in what the ODR wants.
    public static String formatToODRDate(Date dateItem) {
        Date d = dateItem;
        Datetime dt = Datetime.newInstance(d, Time.newInstance(0, 0, 0, 0));
        String dateString = dt.format('yyyy/MM/dd');
        System.debug(dateString);
        return dateString;
    }

    public static List<SAApprovalRequestResponse> postSAApproval(SpecialAuthorityRequest sar) {
        System.debug('postSAApproval');

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

          if (calloutResponseObject.errorCode == 200 || calloutResponseObject.errorCode == 201) {
            System.debug('SA Created');
            System.debug(calloutResponseObject);
            String resBody = calloutResponseObject.response;
            saarr = (SAApprovalRequestResponse) JSON.deserialize(resBody, SAApprovalRequestResponse.class);
          } else {
            // // ERROR
            saarr = new SAApprovalRequestResponse();
            saarr.error = calloutResponseObject;
          }
          System.debug('saarr');
          System.debug(saarr);
          responses.add(saarr);
      }
      return responses;
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
            // for (Integer i = 0; i < resBody.length(); i=i+300) {
            //     Integer iEffectiveEnd = (i+300 > (resBody.length()) ? resBody.length()-1 : i+300);
            //     System.debug(resBody.substring(i,iEffectiveEnd));
            // }
            sar = (PrescriptionHistoryResponse) JSON.deserialize(resBody, PrescriptionHistoryResponse.class);
        }
        System.debug(sar);

        return sar;
    }

    @AuraEnabled
    public static SAApprovalHistoryResponse fetchSAApprovalHistory(Id recordId, String page, String count) {
        System.debug('Fetch Data');
        System.debug(page);
        System.debug(count);

        SAApprovalHistoryResponse sar = null;

        String queryParams = '?clientName=SpecAuth';
        queryParams += '&requestUUID=' + getUUIDString();
        queryParams += '&userid=' + getUserIdentifier();
        queryParams += '&phn=' + getPatientIdentifier(recordId);
        System.debug(queryParams);
        // TODO?
        // queryParams += '&startDate=2001-01-01';
        // queryParams += '&endDate=2020-01-01';
        CalloutResponse calloutResponseObject = sendRequestAndReturnBody(recordId,
                                                                         'callout:ODR_Credentials/odr/sat/pnetsa/saHistory',
                                                                         queryParams,
                                                                         'GET',
                                                                         null,
                                                                         '6');

        if (calloutResponseObject.errorCode != 200) {
            // ERROR
            sar = new SAApprovalHistoryResponse();
            sar.error = calloutResponseObject;
        } else {
            String resBody = calloutResponseObject.response;
            // for (Integer i = 0; i < resBody.length(); i=i+300) {
            //     Integer iEffectiveEnd = (i+300 > (resBody.length()) ? resBody.length()-1 : i+300);
            //     System.debug(resBody.substring(i,iEffectiveEnd));
            // }
            sar = (SAApprovalHistoryResponse) JSON.deserialize(resBody, SAApprovalHistoryResponse.class);
        }
        System.debug(sar);

        return sar;
    }

    public static void updateCasePusedToPNet(Id caseId) {
        Case c = [select Id, contact.patient_identifier__c FROM case WHERE Id =:caseId];
        c.Pushed_to_Pnet__c = true;
        c.Pushed_to_Pnet_Date__c = Datetime.now();
        update c;
    }

    public static String getPatientIdentifier(Id recordId) {
        System.debug('PATIENT DATA');
        // Get PHN from DB
        Case c = [select Id, contact.patient_identifier__c FROM case WHERE Id =:recordId];
        System.debug(c.contact.patient_identifier__c);

        return c.contact.patient_identifier__c;
    }

    public static String getUserIdentifier() {
        // Who's calling this?
        String userid = [Select FederationIdentifier From User Where Id = :UserInfo.getUserId()][0].FederationIdentifier;
        return userid;
    }

    public static String getUUIDString() {
        String hexString = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(DateTime.now().getTime().format())));
        return hexString.SubString(0,8)
                    + '-' + hexString.SubString(8,12)
                    + '-' + hexString.SubString(12,16)
                    + '-' + hexString.SubString(16,20)
                    + '-' + hexString.substring(20);
    }

    public static CalloutResponse sendRequestAndReturnBody(Id recordId,
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