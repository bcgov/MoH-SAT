/*-------------------------------------------------------------------
Class Name : EDRD_EmpiIntegration
Test Class Name : EDRD_EmpiIntegrationTest
Referance Class : EDRD_EmpiIntegrationTest/EmpiIntegration/Patient/EDRD_EmpiWrapper/ESA_cls_constants
Purpose : Get the Patient Information and Validate/Update/Create in Salesforce.
Version : 1.0
Devloper Name : Accenture.
Date : 19/Dec/2024
-------------------------------------------------------------------------*/
global without sharing class EDRD_EmpiIntegration implements Callable
{
    public Object call(String action, Map<String,Object> args){
        
        Map<String,Object> output = (Map<String,Object>)args.get('output');
        Map<String,Object> options = (Map<String,Object>)args.get('options');
        return invokeMethod(action, args, output, options);
    }
    
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outputMap, Map<String,Object> options) {
        Boolean result = true; 
        String jsonInput = Json.serialize(inputMap.get('input'));
        EDRD_EmpiWrapper.OutputWrapper patientOutputWrapper = new EDRD_EmpiWrapper.OutputWrapper();
        EDRD_EmpiWrapper.InputWrapper inputWrapper = (EDRD_EmpiWrapper.InputWrapper) JSON.deserialize(jsonInput, EDRD_EmpiWrapper.InputWrapper.class);

        switch on methodName {
            when 'getEmpidata'{
                this.getEmpidata(inputWrapper,outputMap);
            }
            when 'createUpdatePatient'{
                this.createUpdatePatient(inputWrapper,outputMap);
            }
            when 'createACR'{
                this.createACR(inputWrapper,outputMap);
            }            
            when else {
                result = false;                   
            }
        }
        return result;
    }   
/*---------------------------------------------------------------------
Method Name : createUpdatePatient
Purpose : If we found the Patient information in EMPI we update or create same dataCheck 
          PHN is Exsit in salesforce Database or Not.
Version : 1.0
Devloper Name : Accenture.
Date : 19/Dec/2024
--------------------------------------------------------------------------*/
    public void createUpdatePatient(EDRD_EmpiWrapper.InputWrapper inputWrapper, Map<String,Object> outputMap) {
        EDRD_EmpiWrapper.OutputWrapper patientOutputWrapper = new EDRD_EmpiWrapper.OutputWrapper();        
        List<Account> outAccRecord = new  List<Account>();
        List<Account> patientRecord = new Elevated().selectByPHN(String.ValueOf(inputWrapper.phn));
        if(!patientRecord.isEmpty()){
              for(Account acc : patientRecord){
                acc.FirstName = inputWrapper.firstName;
                acc.LastName = inputWrapper.lastName;
                acc.PersonBirthdate = inputWrapper.dateOfBirth;
                acc.PersonGender = inputWrapper.gender; 
                patientOutputWrapper.patientId = acc.PersonContactId;
        		patientOutputWrapper.patientaccountId = acc.Id; 
                outAccRecord.add(acc);
                createCareProgramEnrollee(acc.Id);
          }                 
          new Elevated().updateAccounts(outAccRecord);          
          String result = Json.serialize(patientOutputWrapper);
          outputMap.put('searchOutput',JSON.deserializeuntyped(result)); 
          return;            
        }
        else if(!ESA_cls_constants.EMPICreatedRenewal.equals(String.ValueOf(inputWrapper.clickBy))){
            createPatientInSF(inputWrapper,outputMap);
            return;
        }
    }   
/*---------------------------------------------------------------------
Method Name : validatePHN
Purpose : Pass the PHN and get the Patient Infomation form EMPI database.
Version : 1.0
Devloper Name : Accenture.
Date : 19/Dec/2024
--------------------------------------------------------------------------*/
    public void getEmpidata(EDRD_EmpiWrapper.InputWrapper inputWrapper, Map<String,Object> outputMap) {
        EDRD_EmpiWrapper.OutputWrapper patientOutputWrapper = new EDRD_EmpiWrapper.OutputWrapper();
        String phn = inputWrapper.phn;
        Patient patientOutput = new Patient();      
        patientOutput = EmpiIntegration.getPatient(phn);
        String patientJSON = Json.serialize(patientOutput);
        patientOutputWrapper = getOutput(patientJSON);
        patientOutputWrapper.isClickEmpiSearch = true;
        patientOutputWrapper.clickByNew = ESA_cls_constants.NewSearch.equals(String.ValueOf(inputWrapper.clickBy)) ? 'EMPI' : null;                   

        if(ESA_cls_constants.EMPICreatedRenewal.equals(String.ValueOf(inputWrapper.clickBy)))
        {
            List<Account> patientRecord = new Elevated().selectByPHN(String.ValueOf(inputWrapper.phn));
            if(!patientRecord.isEmpty() && patientOutputWrapper.isPatientFound == true){
                for(Account acc : patientRecord)
                {
                    patientOutputWrapper.patientId = acc.PersonContactId;
                    patientOutputWrapper.patientaccountId = acc.Id;
                    patientOutputWrapper.isPatientFound = true;
                    patientOutputWrapper.isPatientInSF = true;
                    patientOutputWrapper.isPatientInEMPI = true;
                }
        	}
            else if(!patientRecord.isEmpty()){
                for(Account acc : patientRecord)
                {
                    patientOutputWrapper.patientId = acc.PersonContactId;
                    patientOutputWrapper.patientaccountId = acc.Id;
                    patientOutputWrapper.isPatientFound = true;
                    patientOutputWrapper.isPatientInSF = true;
                    patientOutputWrapper.isPatientInEMPI = false;                 
                }
        	}
            else{
               patientOutputWrapper.isPatientFound = false; 
               patientOutputWrapper.isPatientInSF = false;
            }
        }       
        String result = Json.serialize(patientOutputWrapper);
        outputMap.put('searchOutput',JSON.deserializeuntyped(result)); 
        return;
    }
/*---------------------------------------------------------------------
Method Name : getOutput
Purpose : Innter method.
Version : 1.0
Devloper Name : Accenture.
Date : 19/Dec/2024
--------------------------------------------------------------------------*/
    public EDRD_EmpiWrapper.OutputWrapper getOutput(String patientJSON){   
        
        EDRD_EmpiWrapper.OutputWrapper patientOutputWrapper = new EDRD_EmpiWrapper.OutputWrapper();
        EDRD_EmpiWrapper.Patient patient = (EDRD_EmpiWrapper.Patient) JSON.deserialize(patientJSON, EDRD_EmpiWrapper.Patient.class);
        if(String.isBlank(patient.dob) || String.isBlank(patient.gender) || patient.names[0].givenNames == null || patient.names[0].familyName == null) {
            patientOutputWrapper.firstName = null;
            patientOutputWrapper.lastName = null;
            patientOutputWrapper.dateOfBirth = null;
            patientOutputWrapper.deceased = null;
            patientOutputWrapper.gender = null; 
            patientOutputWrapper.isPatientFound = false;
            patientOutputWrapper.isPatientInEMPI = false;        
        }else{
            patientOutputWrapper.firstName = patient.names[0].givenNames[0];
            patientOutputWrapper.lastName = patient.names[0].familyName;
            patientOutputWrapper.dateOfBirth = Date.valueOf(patient.dob);
            patientOutputWrapper.deceased = patient.deceased;
            patientOutputWrapper.gender = patient.gender.equals('F') ? 'Female' : 'Male'; 
            patientOutputWrapper.isPatientFound = true;
            patientOutputWrapper.phn = patient.phn;
            patientOutputWrapper.isPatientInEMPI = true;
        }
        return patientOutputWrapper;
    } 
/*---------------------------------------------------------------------
Method Name : createPatientInSF
Purpose : Create Date in salesforce database.
Version : 1.0
Devloper Name : Accenture.
Date : 19/Dec/2024
--------------------------------------------------------------------------*/
    public void createPatientInSF(EDRD_EmpiWrapper.InputWrapper inputWrapper, Map<String,Object> outputMap) 
    {
        EDRD_EmpiWrapper.OutputWrapper patientOutputWrapper = new EDRD_EmpiWrapper.OutputWrapper();
        Account patientAccount = new Account();        
        patientAccount.Patient_Identifier__pc  = inputWrapper.phn;
        patientAccount.FirstName = inputWrapper.firstName;
        patientAccount.LastName = inputWrapper.lastName;
        patientAccount.PersonBirthdate =  inputWrapper.dateOfBirth;
        patientAccount.RecordTypeId = ESA_cls_constants.PatientRecordTypeId;  
        Id patientAccountId = new Elevated().createAccounts(patientAccount);
               
        List<Account> patientRecord = new Elevated().selectAccountById(patientAccountId);
        if(!patientRecord.isEmpty()){
            for(Account acc : patientRecord){
                patientOutputWrapper.patientId = acc.PersonContactId;
                patientOutputWrapper.patientaccountId = acc.Id;
                patientOutputWrapper.phn = acc.Patient_Identifier__pc;
                
            }
        }
        createCareProgramEnrollee(patientAccount.Id);        
        if(ESA_cls_constants.EMPICreated.equals(String.ValueOf(inputWrapper.clickBy))){
            patientOutputWrapper.isClickEmpiSearch = true;  
        }        
        String result = Json.serialize(patientOutputWrapper);
        outputMap.put('searchOutput',JSON.deserializeuntyped(result)); 
        return;
    }
/*---------------------------------------------------------------------
Method Name : createPatientInSF
Purpose : Create Date in salesforce database.
Version : 1.0
Devloper Name : Accenture.
Date : 19/Dec/2024
--------------------------------------------------------------------------*/
    public void createPatientInSF(EDRD_EmpiWrapper.InputWrapper inputWrapper, Map<String,Object> outputMap) 
    {
        EDRD_EmpiWrapper.OutputWrapper patientOutputWrapper = new EDRD_EmpiWrapper.OutputWrapper();
        Account patientAccount = new Account();        
        patientAccount.Patient_Identifier__pc  = inputWrapper.phn;
        patientAccount.FirstName = inputWrapper.firstName;
        patientAccount.LastName = inputWrapper.lastName;
        patientAccount.PersonBirthdate =  inputWrapper.dateOfBirth;
        patientAccount.RecordTypeId = ESA_cls_constants.PatientRecordTypeId;  
        Id patientAccountId = new Elevated().createAccounts(patientAccount);               
        List<Account> patientRecord = new Elevated().selectAccountById(patientAccountId);
        if(!patientRecord.isEmpty()){
            for(Account acc : patientRecord){
                patientOutputWrapper.patientId = acc.PersonContactId;
                patientOutputWrapper.patientaccountId = acc.Id;
                patientOutputWrapper.phn = acc.Patient_Identifier__pc;                
            }
        }
        createCareProgramEnrollee(patientAccount.Id);        
        if(ESA_cls_constants.EMPICreated.equals(String.ValueOf(inputWrapper.clickBy))){
            patientOutputWrapper.isClickEmpiSearch = true;  
        }        
        String result = Json.serialize(patientOutputWrapper);
        outputMap.put('searchOutput',JSON.deserializeuntyped(result)); 
        return;
    }
/*---------------------------------------------------------------------
Method Name : createCareProgramEnrollee
Purpose : Create CareProgramEnrollee to associcated Account.
Version : 1.0
Devloper Name : Accenture.
Date : 19/Dec/2024
--------------------------------------------------------------------------*/
    public void createCareProgramEnrollee(Id patientId){
            List<CareProgramEnrollee> cpeRecords = new Elevated().creByAccountId(patientId);
            if(cpeRecords.isEmpty()){
                List<CareProgram> CareProgramName = new Elevated().CareProgramByName(ESA_cls_constants.EDRD_NAME);
                CareProgramEnrollee careProgram = new CareProgramEnrollee();
                careProgram.AccountId = patientId;
                careProgram.Name = 'test';
                careProgram.Status = 'Active';
                careProgram.CareProgramId = !CareProgramName.isEmpty() ? CareProgramName[0].Id : null;
                new Elevated().insertCareProgramEnrollee(careProgram);
           }
    }
/*---------------------------------------------------------------------
Method Name : createACR
Purpose : Craete ACR
Version : 1.0
Devloper Name : Accenture.
Date : 19/Dec/2024
--------------------------------------------------------------------------*/  
    public void createACR(EDRD_EmpiWrapper.InputWrapper inputWrapper,Map<String,Object> outputMap){
      
        List<AccountContactRelation> acrListRecords = new Elevated().selectACR(Id.ValueOf(inputWrapper.LoginUserAccountId),Id.ValueOf(inputWrapper.PatientContactId));
        if(acrListRecords.isEmpty()){
            AccountContactRelation acrRecords = new AccountContactRelation(); 
            acrRecords.AccountId = inputWrapper.LoginUserAccountId; 
            acrRecords.ContactId = inputWrapper.PatientContactId;
            acrRecords.Roles = ESA_cls_constants.EDRD_PHYSICIAN;
            insert acrRecords;       
        }
    }
/*---------------------------------------------------------------------
Class Name : Elevated
Purpose : This is Elevated class to get the salesforce data on System mode.
Version : 1.0
Devloper Name : Accenture.
Date : 19/Dec/2024
--------------------------------------------------------------------------*/
    public without sharing class Elevated
    {
        
        public List<CareProgramEnrollee> creByAccountId(Id accountId){
            return [SELECT Id FROM CareProgramEnrollee WHERE AccountId = :accountId Limit 1];
        }
        public List<CareProgram> CareProgramByName(String Name){
            return [Select Id from CareProgram where Name =: Name Limit 1];
        }
        public List<AccountContactRelation> selectACR(Id LoginUserAccountId,Id PatientContactId){
            return [Select Id from AccountContactRelation where AccountId =: LoginUserAccountId AND ContactId =: PatientContactId];
        }
        public List<Account> selectAccountById(Id accountId){
            return [Select Id, FirstName, LastName, Patient_is_Deceased__pc, PersonBirthdate,Patient_Identifier__pc,PersonGender,PersonContactId from Account where Id =: accountId];
        }
        public List<Account> selectByPHN(String phn){
            return [Select Id,FirstName,LastName,Patient_Identifier__pc, Patient_is_Deceased__pc, PersonBirthdate,PersonGender,PersonContactId from Account where Patient_Identifier__pc =: phn];
        } 
        public void insertCareProgramEnrollee(CareProgramEnrollee careProgram){
            insert careProgram;
        }   
        public void updateAccounts(List<Account> accounts){
            update accounts;
        }
         public Id createAccounts(Account patientAccount){
            insert patientAccount;
            return patientAccount.Id;
        } 
     }    
    
}