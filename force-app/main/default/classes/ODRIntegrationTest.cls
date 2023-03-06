@isTest
public class ODRIntegrationTest {
    @testsetup
    static void testData(){
      Drug__c drug = TestFactory.newDrug('Drug 11');
      insert drug;

      Account patient = TestFactory.newPatient('Patient 1');
      patient.Patient_Identifier__pc = '222333444554';
       
      Account provider = TestFactory.newProvider('Provider 1');
      provider.Provider_Identifier__pc = '111222333444';
      insert new Account[] { patient, provider };

      Case saCase = TestFactory.newCase(drug, patient, provider, 'Test case 1');
      insert saCase;
    }
    @isTest
    public static void verifyPatientInformationxTest() {
      Drug__c drug = TestFactory.newDrug('Drug 1');
      insert drug;

      Account patient = TestFactory.newPatient('Patient 1');
      Account provider = TestFactory.newProvider('Provider 1');
     
      insert new Account[] { patient, provider };

      Case saCase = TestFactory.newCase(drug, patient, provider, 'Test case 1');
      insert saCase;
      Patient p = ODRIntegration.verifyPatientInformationx(saCase.Id);
      System.assertEquals(false, p.verified);
    }
   
    @isTest
    public static void calloutTesting() {
        Integer RESPONSE_CODE = 200;

        Drug__c drug = TestFactory.newDrug('Drug 2');
        insert drug;

        Account patient = TestFactory.newPatient('Patient 1');
        Account provider = TestFactory.newProvider('Provider 1');
        insert new Account[] { patient, provider };

        Case saCase = TestFactory.newCase(drug, patient, provider, 'Test case 1');
        insert saCase;

        Test.startTest();
        String queryParams = '?clientName=SpecAuth';
        queryParams += '&requestUUID=' + ODRIntegration.getUUIDString();
        queryParams += '&userid=' + ODRIntegration.getUserIdentifier();
        queryParams += '&phn=' + ODRIntegration.getPatientIdentifier(saCase.Id);
        queryParams += '&pageSize=10';
        queryParams += '&pageNo=1';

        ODRCalloutMock fakeResponse = new ODRCalloutMock(RESPONSE_CODE,
                                                        'callout:ODR_Credentials/odr/sat/pnetsa/medHistory',
                                                        '',
                                                        null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        CalloutResponse calloutResponseObject = ODRIntegration.sendRequestAndReturnBody(saCase.Id,
                                                                                        'callout:ODR_Credentials/odr/sat/pnetsa/medHistory',
                                                                                        queryParams,
                                                                                        'GET',
                                                                                        null,
                                                                                        '3A');
        System.assertEquals(RESPONSE_CODE, calloutResponseObject.errorCode, 'Response code should be ' + RESPONSE_CODE);

        calloutResponseObject = ODRIntegration.sendRequestAndReturnBody(saCase.Id,
                                                                        'callout:ODR_Credentials/odr/sat/pnetsa/medHistory',
                                                                        queryParams,
                                                                        'POST',
                                                                        '{}',
                                                                        '3A');
        System.assertEquals(RESPONSE_CODE, calloutResponseObject.errorCode, 'Response code should be ' + RESPONSE_CODE);

        RESPONSE_CODE = 201;
        fakeResponse = new ODRCalloutMock(RESPONSE_CODE,
                                          'callout:ODR_Credentials/odr/sat/pnetsa/medHistory',
                                          '',
                                          null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        calloutResponseObject = ODRIntegration.sendRequestAndReturnBody(saCase.Id,
                                                                        'callout:ODR_Credentials/odr/sat/pnetsa/medHistory',
                                                                        queryParams,
                                                                        'POST',
                                                                        '{}',
                                                                        '3A');
        System.assertEquals(RESPONSE_CODE, calloutResponseObject.errorCode, 'Response code should be ' + RESPONSE_CODE);

        RESPONSE_CODE = 400;
        fakeResponse = new ODRCalloutMock(RESPONSE_CODE,
                                          'callout:ODR_Credentials/odr/sat/pnetsa/medHistory',
                                          '',
                                          null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        calloutResponseObject = ODRIntegration.sendRequestAndReturnBody(saCase.Id,
                                                                        'callout:ODR_Credentials/odr/sat/pnetsa/medHistory',
                                                                        queryParams,
                                                                        'POST',
                                                                        '{}',
                                                                        '3A');
        System.assertEquals(RESPONSE_CODE, calloutResponseObject.errorCode, 'Response code should be ' + RESPONSE_CODE);

        RESPONSE_CODE = 400;
        fakeResponse = new ODRCalloutMock(RESPONSE_CODE,
                                          'callout:ODR_Credentials/odr/sat/pnetsa/medHistory',
                                          '{}',
                                          null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        calloutResponseObject = ODRIntegration.sendRequestAndReturnBody(saCase.Id,
                                                                        'callout:ODR_Credentials/odr/sat/pnetsa/medHistory',
                                                                        queryParams,
                                                                        'POST',
                                                                        '{}',
                                                                        '3A');
        System.assertEquals(RESPONSE_CODE, calloutResponseObject.errorCode, 'Response code should be ' + RESPONSE_CODE);

        // Used to catch the catch code
        try {
          RESPONSE_CODE = 400;
          fakeResponse = new ODRCalloutMock(RESPONSE_CODE,
                                            'callout:ODR_Credentials/odr/sat/pnetsa/medHistory',
                                            '{}',
                                            null);
          Test.setMock(HttpCalloutMock.class, fakeResponse);
          calloutResponseObject = ODRIntegration.sendRequestAndReturnBody(saCase.Id,
                                                                          'callout:ODR_Credentials/odr/sat/pnetsa/medHistory',
                                                                          queryParams,
                                                                          'POST',
                                                                          '{}',
                                                                          '3A');
        } catch (JSONException e) {
          System.debug('Caught the JSON Exception.');
        }

        Test.stopTest();
    }
    @isTest static void verifyPatientInformationTest() {
        SpecialAuthorityRequest sar = new SobjectSarBuilder(
            new Drug__c(),
            new Account(),
            new Account(),
            new Account(),
            new Case(),
            new List<Request_Detail__c>(),
            new List<ContentVersion>()
        ).build();
        Patient p = ODRIntegration.verifyPatientInformation(sar);
        System.assertEquals(false, p.verified);
    }
    @isTest static void updateCasePHNStatusTest() {
        Drug__c drug = TestFactory.newDrug('Drug 1');
        insert drug;

        Account patient = TestFactory.newPatient('Patient 1');
        Account provider = TestFactory.newProvider('Provider 1');
        insert new Account[] { patient, provider };

        Case saCase = TestFactory.newCase(drug, patient, provider, 'Test case 1');
        insert saCase;

        List<Request_Detail__c> requestDetails = new List<Request_Detail__c>();
        requestDetails.add(TestFactory.newRequestDetail(saCase, 'question1', 'response1'));
        requestDetails.add(TestFactory.newRequestDetail(saCase, 'question2', 'response2'));
        insert requestDetails;

        ODRIntegration.updateCasePHNStatus(saCase.Id, true);

        Test.startTest();
        SpecialAuthorityRequest sar = new SobjectSarBuilder(saCase.Id).build();
        Test.stopTest();

        System.assertEquals(true, sar.saCase.patient_validated__c);
    }
    @isTest static void getPatientTest() {
        Patient p = ODRIntegration.getPatient('phn');

        System.assertEquals(true, p != null);
    }
   
    @isTest
    public static void calculateTerminationDateTest() {
      Date startDate;
      Integer duration;
      String durationUnit;

      Date dateRecieved = ODRIntegration.calculateTerminationDate(startDate, duration, durationUnit);
      System.assertEquals(Date.newInstance(3000, 1, 1), dateRecieved);

      startDate = Date.parse('2021-01-01');
      Date startDateModified = Date.parse('2021-01-03');

      durationUnit = 'End of year';
      Date endOfYear = ODRIntegration.calculateTerminationDate(startDate, duration, durationUnit);
      System.assertEquals(Date.newInstance(startDate.year(), 12, 31), endOfYear);

      duration = 1;

      durationUnit = 'Days';
      dateRecieved = ODRIntegration.calculateTerminationDate(startDate, duration, durationUnit);
      System.assertEquals(startDateModified, dateRecieved);

      durationUnit = 'Months';
      startDateModified = Date.parse('2021-02-02');
      dateRecieved = ODRIntegration.calculateTerminationDate(startDate, duration, durationUnit);
      System.assertEquals(startDateModified, dateRecieved);

      durationUnit = 'Years';
      startDateModified = Date.parse('2022-01-02');
      dateRecieved = ODRIntegration.calculateTerminationDate(startDate, duration, durationUnit);
      System.assertEquals(startDateModified, dateRecieved);
    }

    @isTest static void getPractitionerCodeTest() {
        String Physician = ODRIntegration.getPractitionerCode('Physician');
        System.assertEquals(Physician, '91');
        String nursePractitioner = ODRIntegration.getPractitionerCode('Nurse Practitioner');
        System.assertEquals(nursePractitioner, '96');
        String Nurse = ODRIntegration.getPractitionerCode('Nurse');
        System.assertEquals(Nurse, 'R9');
        String Dentist = ODRIntegration.getPractitionerCode('Dentist');
        System.assertEquals(Dentist, '95');
        String Midwife = ODRIntegration.getPractitionerCode('Midwife');
        System.assertEquals(Midwife, '98');
        String Podiatrist = ODRIntegration.getPractitionerCode('Podiatrist');
        System.assertEquals(Podiatrist, '93');
        String Naturopathic = ODRIntegration.getPractitionerCode('Naturopathic Practitioner');
        System.assertEquals(Naturopathic, '97');
        String Pharmacist = ODRIntegration.getPractitionerCode('Pharmacist');
        System.assertEquals(Pharmacist, 'P1');
        String Optometrist = ODRIntegration.getPractitionerCode('Optometrist');
        System.assertEquals(Optometrist, '94');
        String oop = ODRIntegration.getPractitionerCode('Out of province provider');
        System.assertEquals(oop, '81');
        String speech = ODRIntegration.getPractitionerCode('Speech and Hearing Professional');
        System.assertEquals(speech, '92');
        String oopS = ODRIntegration.getPractitionerCode('OOP Provider - Saskatchewan');
        System.assertEquals(oopS, '71');
        String oopM = ODRIntegration.getPractitionerCode('OOP Provider - Manitoba');
        System.assertEquals(oopM, '06');
        String oopO = ODRIntegration.getPractitionerCode('OOP Provider - Ontario');
        System.assertEquals(oopO, '01');
        String oopQ = ODRIntegration.getPractitionerCode('OOP Provider - Quebec');
        System.assertEquals(oopQ, '51');
        String oopN = ODRIntegration.getPractitionerCode('OOP Provider - Newfoundland and Labrador');
        System.assertEquals(oopN, '11');
        String oopNB = ODRIntegration.getPractitionerCode('OOP Provider - New Brunswick');
        System.assertEquals(oopNB, '41');
        String oopNV = ODRIntegration.getPractitionerCode('OOP Provider - Nova Scotia');
        System.assertEquals(oopNV, '31');
        String oopP = ODRIntegration.getPractitionerCode('OOP Provider - PEI');
        System.assertEquals(oopP, '21');
        String oopNo = ODRIntegration.getPractitionerCode('OOP Provider - Northwest Territories');
        System.assertEquals(oopNo, 'A1');
        String oopY = ODRIntegration.getPractitionerCode('OOP Provider- Yukon');
        System.assertEquals(oopY, 'B1');
        String oopNu = ODRIntegration.getPractitionerCode('OOP Provider - Nunavit');
        System.assertEquals(oopNu, 'C1');
        String psychiatricNurse = ODRIntegration.getPractitionerCode('Registered Psychiatric Nurse');
        System.assertEquals(psychiatricNurse, 'Y9');

    }
    @isTest static void formatToODRDateTest() {
        Date theDate = Date.newInstance(1960, 2, 17);
        String dateStringFormat = ODRIntegration.formatToODRDate(theDate);
        System.assertEquals(dateStringFormat, '1960/02/17');
    }
    @isTest static void updateCasePusedToPNetTest() {
        Drug__c drug = TestFactory.newDrug('Drug 1');
        insert drug;

        Account patient = TestFactory.newPatient('Patient 1');
        Account provider = TestFactory.newProvider('Provider 1');
        insert new Account[] { patient, provider };

        Case saCase = TestFactory.newCase(drug, patient, provider, 'Test case 1');
        insert saCase;

        List<Request_Detail__c> requestDetails = new List<Request_Detail__c>();
        requestDetails.add(TestFactory.newRequestDetail(saCase, 'question1', 'response1'));
        requestDetails.add(TestFactory.newRequestDetail(saCase, 'question2', 'response2'));
        insert requestDetails;

        ODRIntegration.updateCasePusedToPNet(saCase.Id);

        Test.startTest();
        SpecialAuthorityRequest sar = new SobjectSarBuilder(saCase.Id).build();
        Test.stopTest();

        System.assertEquals(true, sar.saCase.Pushed_to_Pnet__c);
    }
    @isTest static void getPatientIdentifierTest() {
        Drug__c drug = TestFactory.newDrug('Drug 1');
        insert drug;

        Account patient = TestFactory.newPatient('Patient 1');
        Account provider = TestFactory.newProvider('Provider 1');
        insert new Account[] { patient, provider };

        Case saCase = TestFactory.newCase(drug, patient, provider, 'Test case 1');
        insert saCase;

        List<Request_Detail__c> requestDetails = new List<Request_Detail__c>();
        requestDetails.add(TestFactory.newRequestDetail(saCase, 'question1', 'response1'));
        requestDetails.add(TestFactory.newRequestDetail(saCase, 'question2', 'response2'));
        insert requestDetails;

        String identifier = ODRIntegration.getPatientIdentifier(saCase.Id);

        Test.startTest();
        SpecialAuthorityRequest sar = new SobjectSarBuilder(saCase.Id).build();
        Test.stopTest();

        System.assertEquals(identifier, sar.saCase.Contact.Account.Patient_Identifier__pc);
    }
    @isTest static void getUserIdentifierTest() {
        String fedId = ODRIntegration.getUserIdentifier();
        System.assertEquals(fedId, [Select FederationIdentifier From User Where Id = :UserInfo.getUserId()][0].FederationIdentifier);
    }
    @isTest static void getUUIDStringTest() {
        String uuidString = ODRIntegration.getUUIDString();
        Boolean notZero = uuidString.length() > 0;
        System.assertEquals(true, notZero);
    }
    @isTest static void postSAApproval() {
        Contact myContact = new Contact(Firstname='Test', Lastname='Contact');
        insert myContact;

        Case myCase = new Case(ContactId=myContact.Id, Status='Received', Origin='Test', Pushed_to_Pnet__c=false);
        myCase.Pushed_to_Pnet__c = true;
        myCase.Pushed_to_Pnet_Date__c = Datetime.now();
        myCase.Effective_Date__c = Date.today();
        insert myCase;

        System.assertEquals(true, myCase.Pushed_to_Pnet__c);
    }
    @isTest static void fetchIntegrationLogs() {
        Account patient = TestFactory.newPatient('Patient 1');
        insert patient;
        String type = 'SA Approval Update Request';
        String[] keys = new List<String>();
        keys.add('abc123');

        Integration_Log__c log = TestFactory.newIntegrationLog(patient.Id, type, keys[0]);
        insert log;

        Map<String, Integration_Log__c> m1 = ODRIntegration.fetchIntegrationLogs('000000000', keys);
        Map<String, Integration_Log__c> m2 = ODRIntegration.fetchIntegrationLogs('222333444', keys);

        System.assertEquals(new Map<String, Integration_Log__c>(), m1);
    }
    @isTest
    static void fetchSaAapprovalHistoryByCaseTest(){  
        Case saCase = [SELECT Id FROM Case LIMIT 1];
        Integer RESPONSE_CODE = 200;

        Test.startTest();
        ODRCalloutMock fakeResponse = new ODRCalloutMock(RESPONSE_CODE,        
                                                        'callout:ODR_Credentials/odr/sat/pnetsa/saHistory',
                                                         '{"clientName":null, "error":null, "requestUUID":null, "saRecords":null, "totalRecords":null}',
                                                        null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        SAApprovalHistoryResponse saAprovalHistoryRes = ODRINtegration.fetchSAApprovalHistoryByCase(saCase.Id);
        Test.stopTest();
    }
     @isTest
    static void fetchSaAapprovalHistoryByCaseErrorTest(){  
        Case saCase = [SELECT Id FROM Case LIMIT 1];
        Integer RESPONSE_CODE = 404;

        Test.startTest();
        ODRCalloutMock fakeResponse = new ODRCalloutMock(RESPONSE_CODE,        
                                                        'callout:ODR_Credentials/odr/sat/pnetsa/saHistory',
                                                         '{"clientName":null, "error":null, "requestUUID":null, "saRecords":null, "totalRecords":null}',
                                                        null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        SAApprovalHistoryResponse saAprovalHistoryRes = ODRINtegration.fetchSAApprovalHistoryByCase(saCase.Id);
        Test.stopTest();
    }
   
    @isTest
    static void putSAApprovalUpdateTest(){
        Integer RESPONSE_CODE = 200;
        Case objCase = [Select Id FROM Case LIMIT 1];
        SAApprovalUpdateRequest saaur = new SAApprovalUpdateRequest();
        saaur.requestUUID = '12345';
        saaur.clientName = 'SpecAuth';
        saaur.userid = 'Salesforce';
        saaur.updateType = 'T';
        saaur.saRecordId.phn = '9000111222';
        saaur.saRecordId.specialItem.din = '9901-0065';
        saaur.saRecordId.specialItem.rdp = '02241113';
        saaur.saRecordId.specAuthType = 'Terminate';
        saaur.saRecordId.effectiveDate = '3000/01/01';
        saaur.saRevisedData.specialItem.din = '9901-0065';
        saaur.saRevisedData.specialItem.rdp = '02241113';
        saaur.saRevisedData.specAuthType = 'Terminate';
        saaur.saRevisedData.justificationCodes.add('123');
        saaur.saRevisedData.excludedPlans.add('456');
        saaur.saRevisedData.saRequester.practId = '0A0P1';
        saaur.saRevisedData.saRequester.practIdRef = '0A0P1';
        saaur.saRevisedData.saRequester.decCode = 'DEC1232';
        saaur.saRevisedData.effectiveDate = '3000/01/01';
        saaur.saRevisedData.terminationDate = '3000/01/01';
        saaur.saRevisedData.maxDaysSupply = 30;
        saaur.saRevisedData.maxPricePct = 100.0;
        saaur.saRecordId.phn='222333444554';
ODRCalloutMock fakeResponse = new ODRCalloutMock(RESPONSE_CODE,        
                                                        'callout:ODR_Credentials/odr/sat/pnetsa/saHistory',
                                                         '{"clientName":null, "status":0, "requestUUID":null, "statusMessage":null, "totalRecords":null}',
                                                        null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        Test.startTest();
        SAApprovalUpdateRequestResponse objUpdateReqRes = ODRIntegration.putSAApprovalUpdate(objCase.Id,saaur);
        Test.stopTest();
    }
    @isTest
    static void putSAApprovalUpdateDiffereentTypeTest(){
        Integer RESPONSE_CODE = 200;
        Case objCase = [Select Id FROM Case LIMIT 1];
        SAApprovalUpdateRequest saaur = new SAApprovalUpdateRequest();
        saaur.requestUUID = '12345';
        saaur.clientName = 'SpecAuth';
        saaur.userid = 'Salesforce';
        saaur.updateType = 'R';
        saaur.saRecordId.specialItem.din = '9901-0065';
        saaur.saRecordId.specialItem.rdp = '02241113';
        saaur.saRecordId.specAuthType = 'Terminate';
        saaur.saRecordId.effectiveDate = '3000/01/01';
        saaur.saRevisedData.specialItem.din = '9901-0065';
        saaur.saRevisedData.specialItem.rdp = '02241113';
        saaur.saRevisedData.specAuthType = 'Terminate';
        saaur.saRevisedData.justificationCodes.add('123');
        saaur.saRevisedData.excludedPlans.add('456');
        saaur.saRevisedData.saRequester.practId = '0A0P1';
        saaur.saRevisedData.saRequester.practIdRef = '0A0P1';
        saaur.saRevisedData.saRequester.decCode = 'DEC1232';
        saaur.saRevisedData.effectiveDate = '3000/01/01';
        saaur.saRevisedData.terminationDate = '3000/01/01';
        saaur.saRevisedData.maxDaysSupply = 30;
        saaur.saRevisedData.maxPricePct = 100.0;
        saaur.saRecordId.phn='222333444554';
ODRCalloutMock fakeResponse = new ODRCalloutMock(RESPONSE_CODE,        
                                                        'callout:ODR_Credentials/odr/sat/pnetsa/saHistory',
                                                         '{"clientName":null, "status":0, "requestUUID":null, "statusMessage":null, "totalRecords":null}',
                                                        null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        Test.startTest();
        SAApprovalUpdateRequestResponse objUpdateReqRes = ODRIntegration.putSAApprovalUpdate(objCase.Id,saaur);
        Test.stopTest();
    }
   
    @isTest
    static void putSAApprovalUpdateErrorTest(){
        Integer RESPONSE_CODE = 404;
        Case objCase = [Select Id FROM Case LIMIT 1];
        SAApprovalUpdateRequest saaur = new SAApprovalUpdateRequest();
        saaur.requestUUID = '12345';
        saaur.clientName = 'SpecAuth';
        saaur.userid = 'Salesforce';
        saaur.updateType = 'R';
        saaur.saRecordId.specialItem.din = '9901-0065';
        saaur.saRecordId.specialItem.rdp = '02241113';
        saaur.saRecordId.specAuthType = 'Terminate';
        saaur.saRecordId.effectiveDate = '3000/01/01';
        saaur.saRevisedData.specialItem.din = '9901-0065';
        saaur.saRevisedData.specialItem.rdp = '02241113';
        saaur.saRevisedData.specAuthType = 'Terminate';
        saaur.saRevisedData.justificationCodes.add('123');
        saaur.saRevisedData.excludedPlans.add('456');
        saaur.saRevisedData.saRequester.practId = '0A0P1';
        saaur.saRevisedData.saRequester.practIdRef = '0A0P1';
        saaur.saRevisedData.saRequester.decCode = 'DEC1232';
        saaur.saRecordId.phn='222333444554';
ODRCalloutMock fakeResponse = new ODRCalloutMock(RESPONSE_CODE,        
                                                        'callout:ODR_Credentials/odr/sat/pnetsa/saHistory',
                                                         '{"clientName":null, "status":0, "requestUUID":null, "statusMessage":null, "totalRecords":null}',
                                                        null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        Test.startTest();
        SAApprovalUpdateRequestResponse objUpdateReqRes = ODRIntegration.putSAApprovalUpdate(objCase.Id,saaur);
        Test.stopTest();
    }
   
    @isTest
    static void postSAApprovalTest(){
        Integer RESPONSE_CODE = 200;
        Case objCase = [SELECT Id FROM Case LIMIT 1];
        SAApprovalRequest saar = new SAApprovalRequest();
        saar.requestUUID = '12345';
        saar.clientName = 'SpecAuth';
        saar.userid = 'SALESFORCE';
        saar.saRecord.phn = '12345';
        saar.saRecord.specialItem.din = '12345';
        saar.saRecord.specialItem.rdp = '12345';
        saar.saRecord.specAuthType = '12345';
        ODRCalloutMock fakeResponse = new ODRCalloutMock(RESPONSE_CODE,        
                                                        'callout:ODR_Credentials/odr/sat/pnetsa/saHistory',
                                                         '{"clientName":null, "status":0, "requestUUID":null, "statusMessage":null, "totalRecords":null}',
                                                        null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        Test.startTest();
        SAApprovalRequestResponse objApprovalReqRes = ODRIntegration.postSAApproval(objCase.Id,saar);
        Test.stopTest();
    }
   
    @isTest
    static void postSAApprovalErrorTest(){
        Integer RESPONSE_CODE = 404;
        Case objCase = [SELECT Id FROM Case LIMIT 1];
        SAApprovalRequest saar = new SAApprovalRequest();
        saar.requestUUID = '12345';
        saar.clientName = 'SpecAuth';
        saar.userid = 'SALESFORCE';
        saar.saRecord.phn = '12345';
        saar.saRecord.specialItem.din = '12345';
        saar.saRecord.specialItem.rdp = '12345';
        saar.saRecord.specAuthType = '12345';
        ODRCalloutMock fakeResponse = new ODRCalloutMock(RESPONSE_CODE,        
                                                        'callout:ODR_Credentials/odr/sat/pnetsa/saHistory',
                                                         '{"clientName":null, "status":0, "requestUUID":null, "statusMessage":null, "totalRecords":null}',
                                                        null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        Test.startTest();
        SAApprovalRequestResponse objApprovalReqRes = ODRIntegration.postSAApproval(objCase.Id,saar);
        Test.stopTest();
    }
   
    @isTest
    static void verifyCollegeInformationTest(){
        Case objCase =[SELECT Id FROM Case LIMIT 1];
        Integer RESPONSE_CODE = 200;
        ODRCalloutMock fakeResponse = new ODRCalloutMock(RESPONSE_CODE,        
                                                        'callout:ODR_Credentials/odr/sat/pnetsa/saHistory',
                                                         '[{"applicationUUID":null, "firstName":0}]',
                                                        null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        Test.startTest();
        Provider objProvide = ODRIntegration.verifyCollegeInformation(objCase.Id);
        Test.stopTest();
    }
   
    @isTest
    static void verifyCollegeInformationErrorTest(){
        Case objCase =[SELECT Id FROM Case LIMIT 1];
        Integer RESPONSE_CODE = 404;
        ODRCalloutMock fakeResponse = new ODRCalloutMock(RESPONSE_CODE,        
                                                        'callout:ODR_Credentials/odr/sat/pnetsa/saHistory',
                                                         '{"message":null, "errorCode":200}',
                                                        null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        Test.startTest();
        Provider objProvide = ODRIntegration.verifyCollegeInformation(objCase.Id);
        Test.stopTest();
    }
   
    @isTest
    static void fetchBenefitsTest(){
        Case objCase =[SELECT Id FROM Case LIMIT 1];
        Integer RESPONSE_CODE = 200;
        ODRCalloutMock fakeResponse = new ODRCalloutMock(RESPONSE_CODE,        
                                                        'callout:ODR_Credentials/odr/sat/pnetsa/saHistory',
                                                         '{"PlanIExpenditure":null, "PlanEligibility":null}',
                                                        null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        Test.startTest();
        BenefitsResponse bojBResponse = ODRIntegration.fetchBenefits(objCase.Id);
        Test.stopTest();
    }
   
    @isTest
    static void fetchPrescriptionHistory(){
        Case objCase =[SELECT Id FROM Case LIMIT 1];
        Integer RESPONSE_CODE = 200;
        ODRCalloutMock fakeResponse = new ODRCalloutMock(RESPONSE_CODE,        
                                                        'callout:ODR_Credentials/odr/sat/pnetsa/saHistory',
                                                         '{"PrescriberInfo":null, "ClaimHistory":null}',
                                                        null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        Test.startTest();
       
        PrescriptionHistoryResponse objPHistory = ODRIntegration.fetchPrescriptionHistory(objCase.Id,'first','1', new List<Integer>{1});
        Test.stopTest();
    }
}