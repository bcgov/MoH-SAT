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
        switch on methodName {
            when 'getEmpidata'{
                this.getEmpidata(jsonInput,outputMap);
            }
            when 'createPatient'{
                this.createPatient(jsonInput,outputMap);
            }
            when else {
                result = false;                   
            }
        }
        return result;
    }      
    
    public void getEmpidata(String jsonInput, Map<String,Object> outputMap) {
        
        EDRD_EmpiWrapper.OutputWrapper patientOutputWrapper = new EDRD_EmpiWrapper.OutputWrapper();
        EDRD_EmpiWrapper.InputWrapper inputWrapper = (EDRD_EmpiWrapper.InputWrapper) JSON.deserialize(jsonInput, EDRD_EmpiWrapper.InputWrapper.class);
        String phn = inputWrapper.phn;
        String result = null;

        //Search PHN in EMPI
        Patient patientOutput = new Patient();      
        patientOutput = EmpiIntegration.getPatient(phn);
        String patientJSON = Json.serialize(patientOutput);
        patientOutputWrapper = getOutput(patientJSON);
        
        // if patient found in EMPI and but deceased
        if(patientOutputWrapper.isPatientFound == true && patientOutputWrapper.deceased == true){
            result = Json.serialize(patientOutputWrapper);
            outputMap.put('searchOutput',JSON.deserializeuntyped(result));
            return;
        }

        // Search PHN in Salesforce 
        List<Account> patientRecord = new Elevated().selectByPHN(phn);

        // if patient found in EMPI and in Salesforce EDRD
        if(patientOutputWrapper.isPatientFound == true && !patientRecord.isEmpty()){
            for(Account acc : patientRecord){
                acc.FirstName = patientOutputWrapper.firstName;
                acc.LastName = patientOutputWrapper.lastName;
                acc.PersonBirthdate = patientOutputWrapper.dateOfBirth;
                acc.Patient_is_Deceased__pc = patientOutputWrapper.deceased;
                patientOutputWrapper.patientId = acc.Id;
            }

            update patientRecord;  // updating record in Salesforce if found in EMPI and Salesforce   
        }
        // if patient found in EMPI and not in Salesforce EDRD
        else if(patientOutputWrapper.isPatientFound == true && patientRecord.isEmpty()){
            
            // create account record in Salesforce EDRD
            patientOutputWrapper.patientId = createPatientFromEMPI(patientOutputWrapper, phn);

        }else if(patientOutputWrapper.isPatientFound == false && !patientRecord.isEmpty()){
            for(Account acc : patientRecord){
                    patientOutputWrapper.firstName = acc.FirstName;
                    patientOutputWrapper.lastName = acc.LastName;
                    patientOutputWrapper.dateOfBirth = acc.PersonBirthdate;
                    patientOutputWrapper.deceased = acc.Patient_is_Deceased__pc;
                    patientOutputWrapper.responseMessage = 'Patient Found in Salesforce';
                    patientOutputWrapper.isPatientFound = true;
                    patientOutputWrapper.patientId = acc.Id;
                
            }
        }else if(patientOutputWrapper.isPatientFound == false && patientRecord.isEmpty()){
            patientOutputWrapper.responseMessage = 'Result not found';
        }
        result = Json.serialize(patientOutputWrapper);
        outputMap.put('searchOutput',JSON.deserializeuntyped(result));   
    }
    
    public EDRD_EmpiWrapper.OutputWrapper getOutput(String patientJSON){   
        
        EDRD_EmpiWrapper.OutputWrapper patientOutputWrapper = new EDRD_EmpiWrapper.OutputWrapper();
        EDRD_EmpiWrapper.Patient patient = (EDRD_EmpiWrapper.Patient) JSON.deserialize(patientJSON, EDRD_EmpiWrapper.Patient.class);
        
        if(String.isBlank(patient.dob) || String.isBlank(patient.gender) || patient.names.isEmpty()){
            patientOutputWrapper.firstName = null;
            patientOutputWrapper.lastName = null;
            patientOutputWrapper.dateOfBirth = null;
            patientOutputWrapper.deceased = null;
            patientOutputWrapper.gender = null; 
            patientOutputWrapper.isPatientFound = false;
        }else{
            patientOutputWrapper.firstName = patient.names[0].givenNames[0];
            patientOutputWrapper.lastName = patient.names[0].familyName;
            patientOutputWrapper.dateOfBirth = Date.valueOf(patient.dob);
            patientOutputWrapper.deceased = patient.deceased;
            patientOutputWrapper.gender = patient.gender.equals('F') ? 'Female' : patient.gender.equals('M') ? 'Male' : 'Other';
            patientOutputWrapper.isPatientFound = true;
        }
        return patientOutputWrapper;
    }
    
    public void createPatient(String jsonInput, Map<String,Object> outputMap) {
        EDRD_EmpiWrapper.OutputWrapper patientOutputWrapper = new EDRD_EmpiWrapper.OutputWrapper();
        EDRD_EmpiWrapper.InputWrapper inputWrapper = (EDRD_EmpiWrapper.InputWrapper) JSON.deserialize(jsonInput, EDRD_EmpiWrapper.InputWrapper.class);
        Account patientAccount = new Account();
        patientAccount.FirstName = inputWrapper.firstName;
        patientAccount.LastName = inputWrapper.lastName;
        patientAccount.PersonBirthdate = inputWrapper.dateOfBirth;
        //patientAccount.Reason__c = inputWrapper.reason;
        patientAccount.RecordTypeId = ESA_cls_constants.PatientRecordTypeId;   
        insert patientAccount;
        
        patientOutputWrapper.patientId = patientAccount.Id;
        String result = Json.serialize(patientOutputWrapper);
        outputMap.put('searchOutput',JSON.deserializeuntyped(result));
    }
    
    public String createPatientFromEMPI(EDRD_EmpiWrapper.OutputWrapper patientWrapper, String phn) {
        Account patientAccount = new Account();
        patientAccount.FirstName = patientWrapper.firstName;
        patientAccount.LastName = patientWrapper.lastName;
        patientAccount.PersonBirthdate = patientWrapper.dateOfBirth;
        patientAccount.RecordTypeId = ESA_cls_constants.PatientRecordTypeId;
        
        insert patientAccount;
        return patientAccount.Id;
    }
    
    public without sharing class Elevated{
        
        public List<Account> selectByPHN(String phn){
            return [Select Id, FirstName, LastName, Patient_is_Deceased__pc, PersonBirthdate from Account where Patient_Identifier__pc =: phn];
        }
    } 
}