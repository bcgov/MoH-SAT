public with sharing class EmpiIntegration {

    private static final String LRA_RESPONSE_GENDER = 'gender';
    private static final String LRA_RESPONSE_BIRTH_DATE = 'birthDate';
    private static final String LRA_RESPONSE_ACTIVE = 'active';
    private static final String LRA_RESPONSE_RESOURCE_TYPE = 'resourceType';
    private static final String LRA_RESPONSE_DECEASED_DATE_TIME = 'deceasedDateTime';
    private static final String LRA_RESPONSE_GENDER_FEMALE = 'female';
    private static final String LRA_RESPONSE_GENDER_MALE = 'male';
    private static final String LRA_RESPONSE_GENDER_F = 'F';
    private static final String LRA_RESPONSE_GENDER_M = 'M';
    private static final String LRA_RESPONSE_DETAILS = 'details';
    private static final String LRA_RESPONSE_CODING = 'coding';
    private static final String LRA_RESPONSE_CODE = 'code';
    private static final String LRA_RESPONSE_DISPLAY = 'display';
    private static final String LRA_RESPONSE_USE = 'use';
    private static final String LRA_RESPONSE_FAMILY_NAME = 'family';
    private static final String LRA_RESPONSE_GIVEN_NAMES = 'given';
    private static final String LRA_RESPONSE_USE_OFFICIAL = 'official';
    private static final String LRA_RESPONSE_USE_USUAL = 'usual';
    private static final String LRA_RESPONSE_RESOURCE = 'resource';
    private static final String LRA_RESPONSE_RESOURCE_TYPE_PATIENT = 'Patient';
    private static final String LRA_RESPONSE_RESOURCE_TYPE_OPERATION_OUTCOME = 'OperationOutcome';
    private static final String LRA_RESPONSE_NAME = 'name';
    private static final String LRA_RESPONSE_ISSUE = 'issue';
    private static final String LRA_API_CUSTOMSETTING_NAME = 'LRA_API_Configuration';
    private static final User currentUser = [Select Id, Profile.Name, UserRole.Name FROM USER WHERE Id =: UserInfo.getUserId()];
    private static final Boolean isEDRDUser = currentUser?.Profile?.Name?.EqualsIgnoreCase('EDRD Prescriber Community User') || (currentUser.UserRoleId != NULL && currentUser.UserRole.Name.ContainsIgnoreCase('EDRD'));
    private static final String EDRD_Endpoint = 'callout:empi_edrd/HCIM.Services.Secured/Synchronous/QUPA_AR101102.svc';
    private static final String SAT_Endpoint = 'callout:empi/HCIM.Services.Secured/Synchronous/QUPA_AR101102.svc';


    public static Patient getPatient(String phn) {
        String patientPHN = '';
        Patient p = new Patient();
        if (phn != null) {
          patientPHN = phn.deleteWhitespace();
        }
        LRA_API_Configuration__c lraApiSettings = getLRAApiConfiguration(LRA_API_CUSTOMSETTING_NAME);
        if(lraApiSettings != null && lraApiSettings.Use_LRA_API__c == true) {
            p = fetchPatientData(patientPHN, lraApiSettings);
        }
        else {
            Empi.II id;
            Empi.TS creationTime;
            Empi.CS versionCode;
            Empi.II interactionId;
            Empi.CS processingCode;
            Empi.CS processingModeCode;
            Empi.CS acceptAckCode;
            Empi.MCCI_MT000100_Receiver receiver;
            Empi.MCCI_MT000100_Sender sender;
            Empi.HCIM_IN_GetDemographics_QUQI_MT020001_ControlActProcess controlActProcess;

            id = new Empi.II();
            id.root = '2.16.840.1.113883.3.51.1.1.1';
            id.extension = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(DateTime.now().getTime().format())));

            creationTime = new Empi.TS();
            creationTime.value = Datetime.now().format('YYYYMMddHHmmss');

            versionCode = new Empi.CS();
            versionCode.code = 'V3PR1';

            interactionId = new Empi.II();
            interactionId.extension = 'HCIM_IN_GetDemographics';
            interactionId.root = '2.16.840.1.113883.3.51.1.1.2';
            
            // Processing Code. "P" for Production, "T" for Training, "D" for Debug
            processingCode = new Empi.CS();
            processingCode.code = 'P';

            // Processing Mode Code. "T" for Online Processing
            processingModeCode = new Empi.CS();
            processingModeCode.code = 'T';

            // Accept Ack. always "NE" (never send)
            acceptAckCode = new Empi.CS();
            acceptAckCode.code = 'NE';

            receiver = new Empi.MCCI_MT000100_Receiver();
            receiver.typeCode = 'RCV';
            receiver.device = new Empi.MCCI_MT000100_Device();
            receiver.device.id = new Empi.II();
            receiver.device.classCode = 'DEV';
            receiver.device.determinerCode = 'INSTANCE';
            receiver.device.id.root = '2.16.840.1.113883.3.51.1.1.4';
            receiver.device.id.extension = '192.168.0.1';
            receiver.device.asAgent = new Empi.MCCI_MT000100_Agent();
            receiver.device.asAgent.classCode = 'AGNT';
            receiver.device.asAgent.representedOrganization = new Empi.MCCI_MT000100_Organization();
            receiver.device.asAgent.representedOrganization.classCode = 'ORG';
            receiver.device.asAgent.representedOrganization.determinerCode = 'INSTANCE';
            receiver.device.asAgent.representedOrganization.id = new Empi.II();
            receiver.device.asAgent.representedOrganization.id.root = '2.16.840.1.113883.3.51.1.1.3';
            receiver.device.asAgent.representedOrganization.id.extension = 'HCIM';

            sender = new Empi.MCCI_MT000100_Sender();
            sender.typeCode = 'SND';
            sender.device = new Empi.MCCI_MT000100_Device();
            sender.device.determinerCode = 'INSTANCE';
            sender.device.classCode = 'DEV';
            sender.device.id = new Empi.II();
            sender.device.id.root = '2.16.840.1.113883.3.51.1.1.5';
            sender.device.id.extension = 'MOH_CRS';
            sender.device.asAgent = new Empi.MCCI_MT000100_Agent();
            sender.device.asAgent.classCode = 'AGNT';
            sender.device.asAgent.representedOrganization = new Empi.MCCI_MT000100_Organization();
            sender.device.asAgent.representedOrganization.id = new Empi.II();
            sender.device.asAgent.representedOrganization.determinerCode = 'INSTANCE';
            sender.device.asAgent.representedOrganization.classCode = 'ORG';
            sender.device.asAgent.representedOrganization.id.root = '2.16.840.1.113883.3.51.1.1.3';
            sender.device.asAgent.representedOrganization.id.extension = isEDRDUser ? 'PHARM_EDRD' : 'PHARM_SA';

            controlActProcess = new Empi.HCIM_IN_GetDemographics_QUQI_MT020001_ControlActProcess();
            controlActProcess.classCode = 'ACCM';
            controlActProcess.moodCode = 'EVN';
            controlActProcess.dataEnterer = new Empi.QUQI_MT020001_DataEnterer();
            controlActProcess.dataEnterer.typeCode = 'CST';
            controlActProcess.dataEnterer.assignedPerson = new Empi.COCT_MT090100_AssignedPerson();
            controlActProcess.dataEnterer.assignedPerson.classCode = 'ENT';
            controlActProcess.dataEnterer.assignedPerson.id = new Empi.II();
            controlActProcess.dataEnterer.assignedPerson.id.root = '2.16.840.1.113883.3.51.1.1.7';
            controlActProcess.dataEnterer.assignedPerson.id.extension = UserInfo.getUserEmail();
            controlActProcess.queryByParameter = new Empi.HCIM_IN_GetDemographics_QUQI_MT020001_QueryByParameter();
            controlActProcess.queryByParameter.queryByParameterPayload = new Empi.HCIM_IN_GetDemographics_QueryByParameterPayload();
            controlActProcess.queryByParameter.queryByParameterPayload.person_id = new Empi.HCIM_IN_GetDemographics_Person_id();
            controlActProcess.queryByParameter.queryByParameterPayload.person_id.value = new Empi.II();
            controlActProcess.queryByParameter.queryByParameterPayload.person_id.value.root = '2.16.840.1.113883.3.51.1.1.6.1';
            controlActProcess.queryByParameter.queryByParameterPayload.person_id.value.extension = phn;
            controlActProcess.queryByParameter.queryByParameterPayload.person_id.value.assigningAuthorityName = 'MOH_CRS';
            
            Empi.QUPA_AR101102_Port stub = new Empi.QUPA_AR101102_Port();
            stub.endpoint_x = isEDRDUser ? EDRD_Endpoint : SAT_Endpoint; // TEST
            stub.timeout_x = 60000;
        
            p.phn = phn;
            p.deceased = false;
            if (!Test.isRunningTest()) {
                Empi.HCIM_IN_GetDemographicsResponse res = stub.HCIM_IN_GetDemographics(id, creationTime, versionCode, interactionId, processingCode, processingModeCode, acceptAckCode, receiver, sender, controlActProcess);

                p.notes = res.controlActProcess.queryAck.queryResponseCode.code;
                System.debug(p.notes);

                if (null != res.controlActProcess.subject) {
                    System.debug(res.controlActProcess.subject[0].target.identifiedPerson.birthTime);
                    if (res.controlActProcess.subject[0].target.identifiedPerson.birthTime != null
                        && res.controlActProcess.subject[0].target.identifiedPerson.birthTime.value != null) {
                        String birthTime = res.controlActProcess.subject[0].target.identifiedPerson.birthTime.value;
                        String year = birthTime.substring(0, 4);
                        String month = birthTime.substring(4, 6);
                        String day = birthTime.substring(6, 8);
                        p.dob = Date.newInstance(Integer.valueOf(year), Integer.valueOf(month), Integer.valueOf(day));
                    }
                    if (res.controlActProcess.subject[0].target.identifiedPerson.administrativeGenderCode != null) {
                        p.gender = res.controlActProcess.subject[0].target.identifiedPerson.administrativeGenderCode.code;
                    }

                    if (res.controlActProcess.subject[0].target.identifiedPerson.deceasedInd != null) {
                        p.deceased = res.controlActProcess.subject[0].target.identifiedPerson.deceasedInd.value == 'true' ? true : false;
                    }
                    p.names = new List<Patient.PersonName>();
                    if (res.controlActProcess.subject[0].target.identifiedPerson.name != null) {
                        for (Integer i =0;i < res.controlActProcess.subject[0].target.identifiedPerson.name.size();i++) {
                        Patient.PersonName personName = new Patient.PersonName();
                        personName.familyName = res.controlActProcess.subject[0].target.identifiedPerson.name[i].family;
                        personName.type = res.controlActProcess.subject[0].target.identifiedPerson.name[i].use;
                        if (res.controlActProcess.subject[0].target.identifiedPerson.name[i].use == 'L') {
                            personName.declared = true;

                            personName.givenNames = new List<String>();
                            for (Integer s=0;s < res.controlActProcess.subject[0].target.identifiedPerson.name[i].given.size();s++) {
                            String given = res.controlActProcess.subject[0].target.identifiedPerson.name[i].given[s];
                            personName.givenNames.add(given);
                            }
                        } else {
                            personName.declared = false;
                        }
                        p.names.add(personName);
                        }
                    }
                }
            }
        }
        //system.debug(p);
        return p;
    }


    /*
    * @Author: Nikhil Jeenru 
    * @Date: 09 Dec 2024
    * API Method to fetch the patient Demographics from LRA EMPI System.
    */
    public static Patient fetchPatientData(String identifier, LRA_API_Configuration__c lraApiSettings ) {
        
    try {
        String identifierNamespace;
        String userId;
        // Assign the necessary fields from the configuration settings.
        if (String.isNotBlank(lraApiSettings.Identifier_Namespace__c)) {
            identifierNamespace = lraApiSettings.Identifier_Namespace__c;
        }
        if (String.isNotBlank(lraApiSettings.UserID__c)) {
            userId = lraApiSettings.UserID__c;
        }
        // Construct the endpoint URL for the HTTP callout, encoding the identifier.
        String endpoint = 'callout:LRA_AccessToken_Request?identifier=' + EncodingUtil.urlEncode(identifierNamespace + identifier, 'UTF-8');

        // Prepare the HTTP request with necessary headers and send request.
        HttpRequest req = new HttpRequest();
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setHeader('UserID', userId);
        req.setEndpoint(endpoint);
        req.setMethod('GET');
            
        // Instantiate HTTP class and initialize a Patient object.
        Http http = new Http();
        System.debug(req.getBody());
        Patient patient = new Patient();
        // Send the HTTP request and capture the response
        HttpResponse res = http.send(req);

        System.debug('Response Body: ' + res.getBody());

      // Process the response if the status code indicates success (200 OK).
      if (res.getStatusCode() == 200) {
        Map<String, Object> jsonResponse = new Map<String, Object>();
    
        jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        System.debug('Full Response: ' + jsonResponse);
 
        // Extract 'entry' from the response which contains resources.
        List<Object> entries = (List<Object>) jsonResponse.get('entry');
        Map<String, Object> patientResource = null;
        Map<String, Object> OutcomeResource = null;

        // Iterate over the entries to find resources for Patient and Outcome.
        for (Object entryObj : entries) {
            if (entryObj instanceof Map<String, Object>) {
            Map<String, Object> entry = (Map<String, Object>) entryObj;
            Map<String, Object> resource = (Map<String, Object>) entry.get(LRA_RESPONSE_RESOURCE);

                if (resource != null) {
                    String resourceType = (String) resource.get(LRA_RESPONSE_RESOURCE_TYPE);

                    // Identify the Patient resource.
                    if (resourceType != null && resourceType.equalsIgnoreCase(LRA_RESPONSE_RESOURCE_TYPE_PATIENT)) {
                        patientResource = resource;
                    }

                    // Identify the Operation Outcome resource.
                    if (resourceType != null && resourceType.equalsIgnoreCase(LRA_RESPONSE_RESOURCE_TYPE_OPERATION_OUTCOME)) {
                        OutcomeResource = resource;
                    }
                }
            }
        }

        // Extract and process the name details from the Patient resource.
        List<Object> nameList = (List<Object>) patientResource.get(LRA_RESPONSE_NAME);
        List<Patient.PersonName> personNames = new List<Patient.PersonName>();

        if (nameList != null) {
            String selectedUse = null;

            // Search for an official name first, then fallback to usual if official is absent.
            for (Object nameObj : nameList) {
                if (nameObj instanceof Map<String, Object>) {
                    Map<String, Object> nameMap = (Map<String, Object>) nameObj;
                    String use = (String) nameMap.get(LRA_RESPONSE_USE);

                    // Prioritize 'official' name over 'usual'
                    if (use != null && (use.equalsIgnoreCase(LRA_RESPONSE_USE_OFFICIAL) || use.equalsIgnoreCase(LRA_RESPONSE_USE_USUAL))) {
                        if (use.equalsIgnoreCase(LRA_RESPONSE_USE_OFFICIAL)) {
                            selectedUse = LRA_RESPONSE_USE_OFFICIAL;
                            break;
                        } else if (selectedUse == null) {
                            selectedUse = LRA_RESPONSE_USE_USUAL; // Otherwise, select usual if official is absent
                        }
                    }
                }
            }

            // Process the selected name type (official or usual).
            if (selectedUse != null) {
                for (Object nameObj : nameList) {
                    if (nameObj instanceof Map<String, Object>) {
                        Map<String, Object> nameMap = (Map<String, Object>) nameObj;
                        String use = (String) nameMap.get(LRA_RESPONSE_USE);

                        // Process only the first matching 'use' value
                        if (use != null && use.equalsIgnoreCase(selectedUse)) {
                            Patient.PersonName personName = new Patient.PersonName();
                            if (selectedUse == LRA_RESPONSE_USE_OFFICIAL) {
                                personName.declared = true;
                            }
                            personName.familyName = (String) nameMap.get(LRA_RESPONSE_FAMILY_NAME);
                            personName.givenNames = new List<String>();
                            List<Object> givenList = (List<Object>) nameMap.get(LRA_RESPONSE_GIVEN_NAMES);
                            if (givenList != null) {
                                for (Object givenObj : givenList) {
                                    if (givenObj instanceof String) {
                                        personName.givenNames.add((String) givenObj);
                                    }
                                }
                            }

                            personName.type = use;
                            personNames.add(personName);
                            break;
                        }
                    }
                }
            }
        }


       // System.debug(personNames);
        // Extract outcome issues if present in the Outcome resource.
        List<Object> issues = (List<Object>) OutcomeResource.get(LRA_RESPONSE_ISSUE);
        if (issues != null) {
            for (Object issueObj : issues) {
                if (issueObj instanceof Map<String, Object>) {
                    Map<String, Object> issueMap = (Map<String, Object>) issueObj;
                    Map<String, Object> details = (Map<String, Object>) issueMap.get(LRA_RESPONSE_DETAILS);
                    patient.responseStatusValue = (String) issueMap.get(LRA_RESPONSE_CODE);
                    if (details != null) {
                    List<Object> codingList = (List<Object>) details.get(LRA_RESPONSE_CODING);
                        if (codingList != null) {
                            for (Object codingObj : codingList) {
                                if (codingObj instanceof Map<String, Object>) {
                                    Map<String, Object> codingMap = (Map<String, Object>) codingObj;

                                    if (codingMap.containsKey(LRA_RESPONSE_CODE)) {
                                        patient.notes = (String) codingMap.get(LRA_RESPONSE_CODE);
                                        if (codingMap.containsKey(LRA_RESPONSE_DISPLAY)) {
                                            patient.notes += ' | ' + (String) codingMap.get(LRA_RESPONSE_DISPLAY);
                                        }
                                        break;
                                    }
                                }
                            }

                        }
                    }
                }
            }
        } 
        // Extract additional Patient resource details (gender, birthDate, active status).
        String gender = (String) patientResource.get(LRA_RESPONSE_GENDER);
        String birthDate = (String) patientResource.get(LRA_RESPONSE_BIRTH_DATE);
        Boolean isActive = (Boolean) patientResource.get(LRA_RESPONSE_ACTIVE);

        patient.names = personNames;
        patient.phn = identifier;
        patient.gender = gender != null && gender.equalsIgnoreCase(LRA_RESPONSE_GENDER_FEMALE) 
            ? LRA_RESPONSE_GENDER_F 
            : (gender != null && gender.equalsIgnoreCase(LRA_RESPONSE_GENDER_MALE) ? LRA_RESPONSE_GENDER_M : gender);
        patient.dob = birthDate != null ? Date.valueOf(birthDate) : null;
        patient.deceased = patientResource.containsKey(LRA_RESPONSE_DECEASED_DATE_TIME) && patientResource.get(LRA_RESPONSE_DECEASED_DATE_TIME) != null;
      }

      else {
        // Handle non-success HTTP response(Response statusCode 400)
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        List<Object> issues = (List<Object>) responseMap.get(LRA_RESPONSE_ISSUE);
        if (issues != null && !issues.isEmpty()) {
        Map<String, Object> issue = (Map<String, Object>) issues[0];
        patient.responseStatusValue = (String) issue.get(LRA_RESPONSE_CODE);
        
        Map<String, Object> details = (Map<String, Object>) issue.get(LRA_RESPONSE_DETAILS);
        List<Object> coding = (List<Object>) details.get(LRA_RESPONSE_CODING);
        if (coding != null && !coding.isEmpty()) {
            Map<String, Object> codingMap = (Map<String, Object>) coding[0];
            patient.notes = (String) codingMap.get(LRA_RESPONSE_DISPLAY);
            }
        }
      }
      //system.debug(patient);
      return patient;
    }
     catch (Exception e) {
            // Catch any other exceptions and return a general message to JavaScript
            throw new AuraHandledException(Label.LRA_API_Exception_Message);
        }
         
  }

  /**
     * Retrieves the LRA_API_Configuration__c custom setting record dynamically by Name.
     * 
     * @param settingName The Name of the custom setting record to retrieve.
     * @return LRA_API_Configuration__c record if found, otherwise null.
     */
    public static LRA_API_Configuration__c getLRAApiConfiguration(String settingName) {
        // Query the custom setting with the specified name and return the record
        List<LRA_API_Configuration__c> lraConfigurationRecords = [
            SELECT Name, Identifier_Namespace__c, Use_LRA_API__c, UserID__c 
            FROM LRA_API_Configuration__c 
            WHERE Name = :settingName
            LIMIT 1
        ];
        return lraConfigurationRecords.isEmpty() ? null : lraConfigurationRecords[0];

    }
}