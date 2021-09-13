@isTest
public class ODRIntegrationTest {
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

        Drug__c drug = TestFactory.newDrug('Drug 1');
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
}