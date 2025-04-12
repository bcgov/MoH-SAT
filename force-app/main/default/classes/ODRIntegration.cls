public with sharing class ODRIntegration {
    public ODRIntegration() { }
    
    private static final User currentUser = [Select Id, UserRole.Name FROM USER WHERE Id =: UserInfo.getUserId()];
    private static final Boolean isEDRDUser = (currentUser.UserRoleId != NULL && currentUser.UserRole.Name.ContainsIgnoreCase('EDRD'));
    private static final String EDRD_Endpoint_Prescriber_Verification = 'callout:ODR_EDRD/primesvc/getPractitioner';
    private static final String SAT_Endpoint_Prescriber_Verification = 'callout:ODR_Credentials/primesvc/getPractitioner';
    private static final String EDRD_Endpoint_SA_Request_Approval = 'callout:ODR_EDRD/odr/sat/pnetsa/saApproval';
    private static final String SAT_Endpoint_SA_Request_Approval = 'callout:ODR_Credentials/odr/sat/pnetsa/saApproval';
    private static final String EDRD_Endpoint_SA_Approval_Terminate_Request = 'callout:ODR_EDRD/odr/sat/pnetsa/saApprovalUpdate';
    private static final String SAT_Endpoint_SA_Approval_Terminate_Request = 'callout:ODR_Credentials/odr/sat/pnetsa/saApprovalUpdate';
    private static final String EDRD_Endpoint_Patient_Benefit_Plan = 'callout:ODR_EDRD/odr/sat/pnetsa/benefits';
    private static final String SAT_Endpoint_Patient_Benefit_Plan = 'callout:ODR_Credentials/odr/sat/pnetsa/benefits';
    private static final String EDRD_Endpoint_SA_Approval_History = 'callout:ODR_EDRD/odr/sat/pnetsa/saHistory';
    private static final String SAT_Endpoint_SA_Approval_History = 'callout:ODR_Credentials/odr/sat/pnetsa/saHistory';
    private static final String EDRD_Endpoint_Prescription_History = 'callout:ODR_EDRD/odr/sat/pnetsa/medHistory';
    private static final String SAT_Endpoint_Prescription_History = 'callout:ODR_Credentials/odr/sat/pnetsa/medHistory';
    private static String Endpoint = '';

    // LWC Path
    @AuraEnabled(cacheable=true)
    public static Patient verifyPatientInformationx(Id recordId) {
        SpecialAuthorityRequest sar = new SobjectSarBuilder(recordId).build();

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
            List<String> givenListModified = new List<String>();
            if (givenList != null) {
                for (Integer i = 0;i < givenList.size();i++) {
                  List<String> newList = givenList[i].split(' ');
                  for(Integer z = 0;z < newList.size();z++) {
                    givenListModified.add(newList[z].toLowercase());
                  }
                }

              // Check if firstname exists in the EMPI given name list somewhere
              try {
                List<String> firstNameTokens = sar.saCase.Contact.Account.FirstName.split(' ');
                for(Integer s = 0;s < firstNameTokens.size();s++) {
                  if (givenListModified.contains(firstNameTokens[s].toLowercase())) {
                    bGivenNamesValid = true;
                    break;
                  }
                }
              } catch (Exception e) {
                System.debug('Error');
                System.debug(e);
              }
            }

            // Safety Checks
            if (p.deceased
               || !checkValidBirthDate(p.dob, sar.saCase.Patient_Date_of_Birth__c)
               || !bGivenNamesValid
               || sar.saCase.Contact.Account.LastName.toLowercase() != familyName.toLowercase())
            {
              System.debug('Patient NOT Verified');
              p.verified = false;
            } else {
              p.verified = true;
              System.debug('Patient Verified');
            }
            loggingEvents.add(new Logging_Event__e(code__c=200,
                                                message__c='Success',
                                                caseId__c=sar.saCase.Id,
                                                type__c='Patient Verification'));
        } catch (CalloutException e) {
            System.debug('EMPI Callout Exception');
            loggingEvents.add(new Logging_Event__e(code__c=500,
                                                message__c='EMPI Callout Exception',
                                                caseId__c=sar.saCase.Id,
                                                type__c='Patient Verification'));
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
        getPractitionerObject.licenceNumber    = practId.trim();
        getPractitionerObject.collegeReferenceId = getPractitionerCode(practIdRef.trim());

        Provider p = null;
        String saarObject = JSON.serialize(getPractitionerObject);
        Endpoint = isEDRDUser ? EDRD_Endpoint_Prescriber_Verification : SAT_Endpoint_Prescriber_Verification;

        CalloutResponse calloutResponseObject = sendRequestAndReturnBody(recordId,
                                                                         Endpoint,
                                                                         null,
                                                                         'POST',
                                                                         saarObject,
                                                                         'Prescriber Verification');
        if (calloutResponseObject.errorCode != 200) {
            // ERROR
            System.debug('*******************xxx');
            System.debug(calloutResponseObject.errorCode);
            p = new Provider();
            p.verified = false;
        } else {
            String resBody = calloutResponseObject.response;
            System.debug('*******************');
            System.debug(resBody);

            
            // TODO: This should really be receiving an object, but using this for now as the API is returning
            // an array instead of a list.
            List<Provider> providers = (List<Provider>) JSON.deserialize(resBody, List<Provider>.class);
            // Sometimes this is empty!
            if (!providers.isEmpty()) {
                p = providers[0];
                p.verified = p.status == 'P';
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

        SpecialAuthorityRequest sar = new SobjectSarBuilder(recordId).build();
        Provider p = getProviderWithRecordId(recordId, sar.saCase.Provider__r.Provider_Identifier__c, sar.saCase.Provider__r.Provider_Type__c);
        System.debug('saarr');
        return p;
    }

    public static Date calculateTerminationDate(Date startDate, Integer duration, String durationUnit) {
        Date terminationDate = startDate;

        if (String.isBlank(durationUnit) || durationUnit.equalsIgnoreCase('Indefinite')) {
            terminationDate = Date.newInstance(3000, 1, 1);
        } else if (durationUnit.equalsIgnoreCase('End of year')) {
            terminationDate = Date.newInstance(terminationDate.year(), 12, 31);
        } else if (durationUnit.equalsIgnoreCase('Days')) {
            terminationDate = terminationDate.addDays(duration).addDays(1);
        } else if (durationUnit.equalsIgnoreCase('Months')) {
            terminationDate = terminationDate.addMonths(duration).addDays(1);
        } else if (durationUnit.equalsIgnoreCase('Years')) {
            terminationDate = terminationDate.addYears(duration).addDays(1);
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
            } when 'Physician Assistant' {
                practIdCode = 'M9';    
            } when 'Nurse' {
                practIdCode = 'R9';
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
            } when 'Speech and Hearing Professional' {
                practIdCode = '92';
            } when 'OOP Provider - Saskatchewan' {
                practIdCode = '71';
            } when 'OOP Provider - Manitoba' {
                practIdCode = '06';
            } when 'OOP Provider - Ontario' {
                practIdCode = '01';
            } when 'OOP Provider - Quebec' {
                practIdCode = '51';
            } when 'OOP Provider - Newfoundland and Labrador' {
                practIdCode = '11';
            } when 'OOP Provider - New Brunswick' {
                practIdCode = '41';
            } when 'OOP Provider - Nova Scotia' {
                practIdCode = '31';
            } when 'OOP Provider - PEI' {
                practIdCode = '21';
            } when 'OOP Provider - Northwest Territories' {
                practIdCode = 'A1';
            } when 'OOP Provider- Yukon' {
                practIdCode = 'B1';
            } when 'OOP Provider - Nunavit' {
                practIdCode = 'C1';
            } when 'Registered Psychiatric Nurse' {
                practIdCode = 'Y9';
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

    public static SAApprovalRequestResponse postSAApproval(Id caseId, SAApprovalRequest saaRequest) {
        saaRequest.requestUUID = OdrIntegration.getUUIDString();
        saaRequest.clientName = 'SpecAuth';
        saaRequest.userid = OdrIntegration.getUserIdentifier();
        Endpoint = isEDRDUser ? EDRD_Endpoint_SA_Request_Approval : SAT_Endpoint_SA_Request_Approval;

        CalloutResponse calloutResponseObject = sendRequestAndReturnBody(
            caseId,
            Endpoint,
            null,
            'POST',
            JSON.serialize(saaRequest),
            'SA Request Approval'
        );

        SAApprovalRequestResponse saaResponse;

        if (calloutResponseObject.errorCode == 200 || calloutResponseObject.errorCode == 201) {
            String resBody = calloutResponseObject.response;
            saaResponse = (SAApprovalRequestResponse) JSON.deserialize(resBody, SAApprovalRequestResponse.class);
        } else {
            saaResponse = new SAApprovalRequestResponse();
            saaResponse.error = calloutResponseObject;
        }

        return saaResponse;
    }

    public static SAApprovalUpdateRequestResponse putSAApprovalUpdate(Id caseId, SAApprovalUpdateRequest saaUpdateRequest) {
        saaUpdateRequest.requestUUID = OdrIntegration.getUUIDString();
        saaUpdateRequest.clientName = 'SpecAuth';
        saaUpdateRequest.userid = ODRIntegration.getUserIdentifier();
        Endpoint = isEDRDUser ? EDRD_Endpoint_SA_Approval_Terminate_Request : SAT_Endpoint_SA_Approval_Terminate_Request;
        
        // If terminate, supress nulls.
        CalloutResponse calloutResponseObject;
        if (saaUpdateRequest.updateType == 'T') {
            calloutResponseObject = sendRequestAndReturnBody(
                    caseId, 
                    Endpoint, 
                    null,
                    'PUT', 
                    JSON.serialize(saaUpdateRequest, true), 
                    'SA Approval Terminate Request'
                );
        } else {
            calloutResponseObject = sendRequestAndReturnBody(
                    caseId, 
                    Endpoint, 
                    null,
                    'PUT', 
                    JSON.serialize(saaUpdateRequest, true), 
                    'SA Approval Update Request'
                );
        }

        SAApprovalUpdateRequestResponse saaUpdateResponse;

        if (calloutResponseObject.errorCode == 200 || calloutResponseObject.errorCode == 201) {
            String resBody = calloutResponseObject.response;
            saaUpdateResponse = (SAApprovalUpdateRequestResponse) JSON.deserialize(resBody, SAApprovalUpdateRequestResponse.class);
        } else {
            saaUpdateResponse = new SAApprovalUpdateRequestResponse();
            saaUpdateResponse.error = calloutResponseObject;
        }

        return saaUpdateResponse;
    }

   

    @AuraEnabled
    public static BenefitsResponse fetchBenefits(Id recordId) {
        System.debug('Fetch Benefits');

        BenefitsResponse bres = null;

        String queryParams = '';
        Endpoint = isEDRDUser ? EDRD_Endpoint_Patient_Benefit_Plan : SAT_Endpoint_Patient_Benefit_Plan;

        Map<String, String> jsonMap = new Map<String, String>();
        jsonMap.put('clientName', 'SpecAuth');
        jsonMap.put('requestUUID', getUUIDString());
        jsonMap.put('userid', getUserIdentifier());
        jsonMap.put('phn', getPatientIdentifier(recordId));
        CalloutResponse calloutResponseObject = sendRequestAndReturnBody(recordId,
                                                                         Endpoint,
                                                                         queryParams,
                                                                         'POST',
                                                                         JSON.serialize(jsonMap),
                                                                         'Patient Benefit Plan');

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

    @AuraEnabled(cacheable=true)
    public static SAApprovalHistoryResponse fetchSAApprovalHistoryByCase(Id recordId) {
        return fetchSAApprovalHistory(getPatientIdentifier(recordId));
    }

    

    @AuraEnabled(cacheable=true)
    public static SAApprovalHistoryResponse fetchSAApprovalHistory(String phn) {
        SAApprovalHistoryResponse sar = null;

        String queryParams = '';
        Endpoint = isEDRDUser ? EDRD_Endpoint_SA_Approval_History : SAT_Endpoint_SA_Approval_History;

        Map<String, String> jsonMap = new Map<String, String>();
        jsonMap.put('clientName', 'SpecAuth');
        jsonMap.put('requestUUID', getUUIDString());
        jsonMap.put('userid', getUserIdentifier());
        jsonMap.put('phn', phn);
        jsonMap.put('startDate', '1990-01-01');
        jsonMap.put('endDate','3000-01-01');
        
        CalloutResponse calloutResponseObject = sendRequestAndReturnBody(null,
                                                                         Endpoint,
                                                                         queryParams,
                                                                         'POST',
                                                                         JSON.serialize(jsonMap),
                                                                         'SA Approval History');

        if (calloutResponseObject.errorCode != 200) {
            sar = new SAApprovalHistoryResponse();
            sar.error = calloutResponseObject;
        } else {
            String resBody = calloutResponseObject.response;
            sar = (SAApprovalHistoryResponse) JSON.deserialize(resBody, SAApprovalHistoryResponse.class);
        }
        system.debug('The response is :'+ sar.saRecords);
        return sar;
    }
    
/** 
 * @author: accenture_sat_team
 * @description: To fectch the prescription in all the records with given search key(ESA-2109)
 * @param: recordId, page, totalCount, dinList, searchKey, displayCount 
 * @return:  Perscription History Records with search key.
 * Modified : CGI 
**/
@AuraEnabled(cacheable = true)
public static PrescriptionHistoryResponse fetchPrescriptionHistoryWithSearchKey(Id recordId, String page, String totalCount, List<Integer> dinList, String searchKey, String displayCount) {
    if(String.isBlank(searchKey)){
        return fetchPrescriptionHistory(recordId, page, displayCount, dinList);
    }
    
    PrescriptionHistoryResponse resObj = fetchPrescriptionHistory(recordId, page, totalCount, dinList);
    Integer returnRecordCount = 0;
    Integer displayCountInt = !String.isBlank(displayCount) ? Integer.valueOf(displayCount) : 0;
    List<PrescriptionHistoryResponse.MedRecords> medRecordsList = new List<PrescriptionHistoryResponse.MedRecords>();
    if(resObj.medHistory != NULL && !resObj.medHistory.medRecords.isEmpty()){
        for(PrescriptionHistoryResponse.MedRecords medObj : resObj.medHistory.medRecords){
            Boolean isReturnCountLessNSearchKeyContains = returnRecordCount < displayCountInt && 
                ((medObj.dinpin != NULL && String.valueOf(medObj.dinpin).containsIgnoreCase(searchKey)) || 
                 (!String.isEmpty(medObj.genericName) && medObj.genericName.containsIgnoreCase(searchKey)));
            if(isReturnCountLessNSearchKeyContains){
                medRecordsList.add(medObj);
                returnRecordCount = returnRecordCount + 1;                       
            }
            else if(returnRecordCount >= displayCountInt){
                break;
            }
        }
        resObj.medHistory.MedRecords = medRecordsList;
    }
    return resObj;
}
    
    // Fetch Prescription History
    @AuraEnabled
    public static PrescriptionHistoryResponse fetchPrescriptionHistory(Id recordId, String page, String count, List<Integer> dinList) {
        
        PrescriptionHistoryResponse sar = null;
        Endpoint = isEDRDUser ? EDRD_Endpoint_Prescription_History : SAT_Endpoint_Prescription_History;

        // Build Request Body
        Map<String, Object> jsonMap = new Map<String, Object>();
        jsonMap.put('clientName', 'SpecAuth');
        jsonMap.put('requestUUID', getUUIDString());
        jsonMap.put('userid', getUserIdentifier());
        jsonMap.put('phn', getPatientIdentifier(recordId));
        jsonMap.put('pageSize', count);
        jsonMap.put('pageNo', page);
        jsonMap.put('sort', 'DESC');

        List<Integer> newdinLst = new List<Integer>();
        List<List<Integer>> listOfLst = new List<List<Integer>>();
        List<CalloutResponse> callOutResponseLst = new List<CalloutResponse>();

        // Check if dinList is empty or less than 800, make a single callout
        if (dinList.size() == 0 || dinList.size() < 800) {
            jsonMap.put('dinList', dinList);
            jsonMap.put('startDate', '1900-01-01');

            CalloutResponse calloutResponseObject = sendRequestAndReturnBody(recordId,
                                                                            Endpoint,
                                                                            null,
                                                                            'POST',
                                                                            JSON.serialize(jsonMap),
                                                                            'Prescription History');
            callOutResponseLst.add(calloutResponseObject);
        }
        else {
            // Split dinList into chunks of 800 for multiple callouts
            for (Integer i = 0; i < dinList.size(); i++) {
                // If the newdinLst is empty, add the current element
                if (newdinLst.size() == 0) {
                    newdinLst.add(dinList[i]);
                }
                // If the newdinLst size is 800, add it to the listOfLst and start a new list
                else if (newdinLst.size() == 800) {
                    listOfLst.add(newdinLst);
                    newdinLst = new List<Integer>{dinList[i]};
                }
                // If the newdinLst size is less than 800, simply add the current element
                else {
                    newdinLst.add(dinList[i]);
                }
                // Add the last chunk to the list
                if (i == dinList.size() - 1) {
                    listOfLst.add(newdinLst);
                }
            }

             // Callout made for each list seperately to avoid governor limits
            for (List<Integer> batch : listOfLst) {
                jsonMap.put('dinList', batch);
                jsonMap.put('startDate', '1900-01-01');

                CalloutResponse calloutResponseObject = sendRequestAndReturnBody(recordId,
                                                                                Endpoint,
                                                                                null,
                                                                                'POST',
                                                                                JSON.serialize(jsonMap),
                                                                                'Prescription History');
                callOutResponseLst.add(calloutResponseObject);
                System.debug('the din pin size is ' + batch.size());
            }
        }


        PrescriptionHistoryResponse prescResponsRes = new PrescriptionHistoryResponse();

        // Combine responses from multiple callouts
        for (CalloutResponse calloutResponseObject : callOutResponseLst) {
            if (calloutResponseObject.errorCode != 200) {
                // ERROR
                sar = new PrescriptionHistoryResponse();
                sar.error = calloutResponseObject;
                return sar;
            } else {
                String resBody = calloutResponseObject.response;
                sar = (PrescriptionHistoryResponse) JSON.deserialize(resBody, PrescriptionHistoryResponse.class);
                
                // Combine data from individual responses
                if (prescResponsRes != null && prescResponsRes.medHistory != null && sar != null && sar.medHistory != null) {
                    if (prescResponsRes.medHistory.medRecords != null && sar.medHistory.medRecords != null) {
                        prescResponsRes.medHistory.medRecords.addAll(sar.medHistory.medRecords);
                    }
                    if (prescResponsRes.medHistory.totalPages != null && sar.medHistory.totalPages != null) {
                        prescResponsRes.medHistory.totalPages = prescResponsRes.medHistory.totalPages + sar.medHistory.totalPages;
                    }
                    if (prescResponsRes.medHistory.totalRecords != null && sar.medHistory.totalRecords != null) {
                        prescResponsRes.medHistory.totalRecords = prescResponsRes.medHistory.totalRecords + sar.medHistory.totalRecords;
                    }
                } else {
                    prescResponsRes = sar;
                }
            }
        }
        
        return prescResponsRes;
    }

    @AuraEnabled
    public static Map<String, Integration_Log__c> fetchIntegrationLogs(String phn, String[] keys){

        Id patientId = getPatientId(phn);
        if(patientId == null){
            return new Map<String, Integration_Log__c>();
        }

        List<Integration_Log__c> logs = [SELECT Id, Name, Code__c, Type__c, Key__c, Timestamp__c, Patient__c
                                            FROM Integration_Log__c
                                            WHERE (Type__c = 'SA Approval Update Request' OR Type__c = 'SA Approval Terminate Request') 
                                            AND Patient__c = :patientId
                                            AND Key__c IN :keys
                                            ORDER BY Key__c ASC, Timestamp__c ASC];

        Map<String, Integration_Log__c> mostRecentLogByKey = new Map<String, Integration_Log__c>();        
        for (Integration_Log__c log : logs) {
            mostRecentLogByKey.put(log.Key__c, log);
        }

        return mostRecentLogByKey;
    }

    public static Id getPatientId (String phn){
        try {
            Account patient = [SELECT Id, Patient_Identifier__pc FROM Account WHERE Patient_Identifier__pc = :phn];
            return patient.Id;
        } catch(Exception e){
            return null;
        }
        
    }

    public static void updateCasePusedToPNet(Id caseId) {
        Case c = [select Id, contact.patient_identifier__c FROM case WHERE Id =:caseId];
        c.Pushed_to_Pnet__c = true;
        c.Pushed_to_Pnet_Date__c = Datetime.now();
        update c;
    }

    @AuraEnabled
    public static String getPatientIdentifier(Id recordId) {
        Case c = [select Id, patient_identifier__c FROM case WHERE Id =:recordId];
        return c.patient_identifier__c;
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
        req.setTimeout(60000);
        
        System.debug(methodBody);
        
        // If POST, construct postBody
        if (method == 'POST') {
            req.setBody(methodBody);
        }

        // If PUT, construct postBody and create key for Integration Log.
        String integrationLogKey = '';
        Id accountId;
        if (method == 'PUT') {
            req.setBody(methodBody);
            SAApprovalUpdateRequest saApprovalUpdateRequestObj = (SAApprovalUpdateRequest) JSON.deserialize(methodBody, SAApprovalUpdateRequest.class);
            integrationLogKey += saApprovalUpdateRequestObj.saRecordId.phn;
            integrationLogKey += saApprovalUpdateRequestObj.saRecordId.specialItem.din;
            integrationLogKey += saApprovalUpdateRequestObj.saRecordId.specialItem.rdp;
            integrationLogKey += saApprovalUpdateRequestObj.saRecordId.specAuthType;
            integrationLogKey += saApprovalUpdateRequestObj.saRecordId.effectiveDate.replace('/', '');
            Account patient = [SELECT Id, Patient_Identifier__pc FROM Account WHERE Patient_Identifier__pc = :saApprovalUpdateRequestObj.saRecordId.phn];
            accountId = patient.Id;
            System.debug(integrationLogKey);
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
                                                       type__c=integrationName,
                                                       key__c=integrationLogKey,
                                                       patient__c=accountId));
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
                                                        type__c=integrationName,
                                                        key__c=integrationLogKey,
                                                        patient__c=accountId));
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
                                                        type__c=integrationName,
                                                        key__c=integrationLogKey,
                                                        patient__c=accountId));
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
                                                   type__c=integrationName,
                                                   key__c=integrationLogKey,
                                                   patient__c=accountId));
            EventBus.publish(loggingEvents);
            System.debug('API Error: ' + resObject.errorCode + ' ' + resObject.errorMessage);
        }
        return resObject;
    }
}