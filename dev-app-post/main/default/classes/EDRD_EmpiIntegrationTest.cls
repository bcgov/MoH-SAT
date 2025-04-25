/*-----------------------------------------
Test Class Name : EDRD_EmpiIntegrationTest
Main Class Name : EDRD_EmpiIntegration
Version : 1.0
Devloper Name : Accenture.
------------------------------------------*/
@isTest
public class EDRD_EmpiIntegrationTest {
  @testSetup
    static void setupTestData() {
        
        // Step 1: Create and insert an Account
        Id recordTypeProvider = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Provider').getRecordTypeId();
        Account testAccountUser = TestFactory.newProvider('Provider Test');
        
        insert testAccountUser;
        Id providerContactId = [SELECT Id FROM Contact Where accountId =: testAccountUser.Id].get(0).Id;

        // Step 2: Create and insert a Contact related to the Account
        /*Contact testContactUser = new Contact(
            FirstName = 'Test',
            LastName = 'ContactUser987',
            Email = 'test.contact@example.com',
            AccountId = testAccountUser.Id
        );
        insert testContactUser; */

        // Step 3: Create a User with associated Account and Contact
        Profile userProfile = [SELECT Id FROM Profile WHERE Name = 'EDRD Prescriber Community User' LIMIT 1];
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'test.user@example.com',
            Username = 'test.user00978@abc.xyz.com',
            Alias = 'tuser',
            ProfileId = userProfile.Id,
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ContactId = providerContactId
        );
        insert testUser;
        
        
         // Step 1: Create CareProgram
         CareProgram testCP = new CareProgram();
         testCP.Name = 'EDRD';
         testCP.Status = 'New';         
         insert testCP;
         
        // Step 2: Create a test Account for Salesforce data mock
        Account testAccount = new Account(
            FirstName = 'John',
            LastName = 'Doe',
            Patient_Identifier__pc = '9879450112',
            PersonBirthdate = Date.newInstance(1990, 01, 01),
            PersonGender = 'Male',
            RecordTypeId = ESA_cls_constants.PatientRecordTypeId
        );
        insert testAccount;
        
         // Step 3: Create a CareProgramEnrollee
        CareProgramEnrollee testCPERecords = new CareProgramEnrollee();
        testCPERecords.AccountId = testAccount.Id;
        testCPERecords.Name = 'testCPE';
        testCPERecords.Status = 'Active';
        testCPERecords.CareProgramId = testCP.Id;
        insert testCPERecords;        
    }
/*---------------------------------------------------------------------
Method Name : testgetEMPIData
Method Calling for : getEMPIData
Purpose : Pass the PHN and get the Patient Infomation form EMPI database.
Version : 1.0
Devloper Name : Accenture.
--------------------------------------------------------------------------*/
    @isTest
    static void testgetEMPIData() {
        // Instantiate the class
        EDRD_EmpiIntegration integration = new EDRD_EmpiIntegration();

        // Mock input data
        Map<String, Object> inputMap = new Map<String, Object>{
            'input' => new Map<String, Object>{
                'elementName' => 'searchPatient',
                'omniScriptId' => '0jNAq000000VXJ3MAO',
                'phn' => '9879450112',
                'clickBy' => 'EMPICreatedRenewal'
            },
            'options' => new Map<String, Object>{
                'ignoreCache' => false,
                'postTransformBundle' => '',
                'preTransformBundle' => '',
                'useContinuation' => false,
                'useQueueableApexRemoting' => false,
                'vlcClass' => 'EDRD_EmpiIntegration'
            },
            'output' => new Map<String, Object>{}
        };

        // Call the method
        Object result = integration.call('getEmpidata', inputMap);

        // Assert results
        System.assertNotEquals(null, result, 'Result should not be null');
    }   

/*---------------------------------------------------------------------
Method Name : testCreateUpdatePatient
Method Calling for : CreateUpdatePatient
Purpose : If we found the Patient information in EMPI we update or create same dataCheck 
          PHN is Exsit in salesforce Database or Not.
Version : 1.0
Devloper Name : Accenture.
--------------------------------------------------------------------------*/
    @isTest
    static void testCreateUpdatePatient() {
        // Instantiate the class
        EDRD_EmpiIntegration integration = new EDRD_EmpiIntegration();

        // Mock data
        Map<String, Object> inputMap = new Map<String, Object>{
            'firstName' => 'John',
            'lastName' => 'Doe',
            'dateOfBirth' => Date.newInstance(1990, 01, 01),
            'gender' => 'Male',
            'phn' => '9879450112'
        };
        Map<String, Object> outputMap = new Map<String, Object>();
		Map<String, Object> inputMapMain = new Map<String, Object>();
        inputMapMain.put('input',inputMap);
		String jsonInput = Json.serialize(inputMapMain.get('input'));
  
        EDRD_EmpiWrapper.InputWrapper inputWrapper = (EDRD_EmpiWrapper.InputWrapper) JSON.deserialize(jsonInput, EDRD_EmpiWrapper.InputWrapper.class);
        // Call the method
        integration.createUpdatePatient(inputWrapper, outputMap);

        // Assert results
        System.assert(outputMap.containsKey('searchOutput'), 'Output should contain searchOutput');
    }
/*---------------------------------------------------------------------
Method Name : testCreatePatientInSF
Method Calling for : CreatePatientInSF
Purpose : Create Date in salesforce database.
Version : 1.0
Devloper Name : Accenture.
--------------------------------------------------------------------------*/
    @isTest
    static void testCreatePatientInSF() {
        // Instantiate the class
        EDRD_EmpiIntegration integration = new EDRD_EmpiIntegration();

        // Mock data

        Map<String, Object> inputMap = new Map<String, Object>{
            'firstName' => 'Jane',
            'lastName' => 'Smith',
            'dateOfBirth' => Date.newInstance(1985, 07, 15),
            'phn' => '1234567890',
            'clickBy' => ESA_cls_constants.ManullyCreated
        };
        Map<String, Object> outputMap = new Map<String, Object>();
        
     Map<String, Object> inputMapMain = new Map<String, Object>();
        inputMapMain.put('input',inputMap);
		String jsonInput = Json.serialize(inputMapMain.get('input'));
        EDRD_EmpiWrapper.InputWrapper inputWrapper = (EDRD_EmpiWrapper.InputWrapper) JSON.deserialize(jsonInput, EDRD_EmpiWrapper.InputWrapper.class);
        // Call the method
        integration.createPatientInSF(InputWrapper, outputMap);

        // Assert results
        System.assert(outputMap.containsKey('searchOutput'), 'Output should contain searchOutput');
        Map<String, Object> searchOutput = (Map<String, Object>) outputMap.get('searchOutput');
    } 
/*---------------------------------------------------------------------
Method Name : testCreateACR
Method Calling for : CreateACR
Purpose : Create ACR Recods.
Version : 1.0
Devloper Name : Accenture.
--------------------------------------------------------------------------*/ 
    @isTest
    static void testCreateACR() {
        
         User us =[Select AccountId from user where Username ='test.user00978@abc.xyz.com' Limit 1];
         Account acc =[Select PersonContactId from Account where Patient_Identifier__pc = '9879450112' Limit 1];
        
         EDRD_EmpiWrapper.InputWrapper inputWrapper = new EDRD_EmpiWrapper.InputWrapper();
        inputWrapper.LoginUserAccountId = us.AccountId;
        inputWrapper.PatientContactId = acc.PersonContactId;
        
         Map<String, Object> outputMap = new Map<String, Object>();
	
        // Step 4: Call the createACR method
        EDRD_EmpiIntegration controller = new EDRD_EmpiIntegration();
        Test.startTest();
        controller.createACR(inputWrapper, outputMap);
        Test.stopTest();

        // Step 5: Validate that the AccountContactRelation record is created
        List<AccountContactRelation> acrList = [
            SELECT Id, AccountId, ContactId, Roles
            FROM AccountContactRelation
            WHERE AccountId = :us.AccountId AND ContactId =: acc.PersonContactId
        ];

        System.assertEquals(1, acrList.size(), 'One AccountContactRelation record should be created.');
        System.assertEquals(ESA_cls_constants.EDRD_PHYSICIAN, acrList[0].Roles, 'The Role should be EDRD_PHYSICIAN.');
       
    }
}