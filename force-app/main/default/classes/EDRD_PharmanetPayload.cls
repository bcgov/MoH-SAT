/*-------------------------------------------------------------------
Class Name : EDRD_PharmanetPayload
Test Class Name : EDRD_PharmanetPayload
Reference Class : EDRD_EmpiIntegrationTest/EmpiIntegration/Patient/EDRD_EmpiWrapper/ESA_cls_constants
Purpose : Get the Patient Information and Validate/Update/Create in Salesforce.
Version : 1.0
Devloper Name : Accenture.
Date : 19/Dec/2024
--------------------------------------------------------------------------*/
global with sharing class EDRD_PharmanetPayload implements Callable{
    
    
    public Object call(String action, Map<String,Object> args){        
        Map<String,Object> output = (Map<String,Object>)args.get('output');
        Map<String,Object> options = (Map<String,Object>)args.get('options');
        return invokeMethod(action, args, output, options);
    }
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outputMap, Map<String,Object> options) {
        Boolean result = true; 
        String jsonInput = Json.serialize(inputMap.get('input'));
        System.debug('jsonInput'+jsonInput);
        switch on methodName {
            when 'updateSubmitAllPharmanet'{
                this.updateSubmitAllPharmanet(jsonInput,outputMap);
            }
            when 'updateSubmitPharmanet'{
                this.updateSubmitPharmanet(jsonInput,outputMap);
            }
            when 'getPharmanetDecisionTable'{
                this.getPharmanetDecisionTable(jsonInput,outputMap);
            }
            when 'markPushedToPharmanet'{
                this.markPushedToPharmanet(jsonInput,outputMap);
            }
            when else{                
            }
        }
        return result;
    }  
/*-------------------------------------------------------------------
Method Name : getPharmanetDecisionTable
Purpose : Get the date from DecisionTable Name is : EDRD_PharmaNet_Payload.
Version : 1.0
Devloper Name : Accenture.
Date : 19/Feb/2025
--------------------------------------------------------------------------*/
    
    public void getPharmanetDecisionTable(String jsonInput, Map<String,Object> outputMap)
    {
        EDRD_PharmanetWrapper.InputWrapper inputWrapper = (EDRD_PharmanetWrapper.InputWrapper) JSON.deserialize(jsonInput, EDRD_PharmanetWrapper.InputWrapper.class);
        DecisionTable dt = new Elevated().getDTId('EDRD_PharmaNet_Payload');
        
        ConnectApi.DecisionTableInput input = new ConnectApi.DecisionTableInput();
        input.conditions = new List<ConnectApi.DecisionTableCondition>();
        
        ConnectApi.DecisionTableCondition condition1 = new ConnectApi.DecisionTableCondition();
        condition1.fieldName = 'EDRD_Medication_Name__c';
        condition1.value = inputWrapper.medicationName;
        input.conditions.add(condition1);
        
        ConnectApi.DecisionTableCondition condition2 = new ConnectApi.DecisionTableCondition();
        condition2.fieldName = 'EDRD_Indication_Name__c';
        condition2.value = inputWrapper.indication;
        input.conditions.add(condition2);
        
        ConnectApi.DecisionTableCondition condition3 = new ConnectApi.DecisionTableCondition();
        condition3.fieldName = 'EDRD_Case_Status__c';
        condition3.value = inputWrapper.caseStatus;
        input.conditions.add(condition3);
        
        ConnectApi.DecisionTableCondition condition4 = new ConnectApi.DecisionTableCondition();
        condition4.fieldName = 'RecordTypeId';
        condition4.value = ESA_cls_constants.PharmanetPayloadRecordTypeId;
        input.conditions.add(condition4);
        
        ConnectApi.DecisionTableOutcome decisionOutcome =  ConnectApi.DecisionTable.execute(dt.Id, input);
        if (decisionOutcome != null && decisionOutcome.successStatus) 
        {           
            List<ConnectApi.DecisionTableOutcomeItem> decisionTableItems = decisionOutcome.outcomeList;
            List<EDRD_PharmanetWrapper.OutputWrapper > outputWrappers = new List<EDRD_PharmanetWrapper.OutputWrapper >();
            for (ConnectApi.DecisionTableOutcomeItem item : decisionTableItems) 
            {
                EDRD_PharmanetWrapper.OutputWrapper wrapper = new EDRD_PharmanetWrapper.OutputWrapper(); 
                wrapper.justificationCodes = (String) item.values.get('EDRD_Justification_Code__c');
                wrapper.maxDaysSupply = (Double) item.values.get('EDRD_Max_Days_Supply__c');
                wrapper.rdp = (String) item.values.get('EDRD_RDP_Code__c');
                wrapper.specAuthType = (String) item.values.get('EDRD_SA_Type__c');
                wrapper.excludedPlans = (String) item.values.get('EDRD_Excluded_Plans__c');
                wrapper.din = (Double) item.values.get('EDRD_DIN__c');
                wrapper.maxPricePct = (Double) item.values.get('EDRD_Max_Price_Percent__c');
                wrapper.effectiveDate = (DateTime)item.values.get('EDRD_Effective_Date__c');
                wrapper.terminationDate = inputWrapper.terminationDate != 'null' ? (String) inputWrapper.terminationDate : null;
                wrapper.pharmaNetRecordId = (Id) item.values.get('Id');
                wrapper.isPharmaNetSubmitSuccessfull = (Boolean) item.values.get('EDRD_isPharmaNetSubmitSuccessful__c');
                wrapper.practId = inputWrapper.practId;
                wrapper.phn = inputWrapper.phn;
                outputWrappers.add(wrapper);
            }
            String result = Json.serialize(outputWrappers);
            outputMap.put('pharmanetOutput',JSON.deserializeuntyped(result)); 
            
        }
        return;              
    }
/*-------------------------------------------------------------------
Method Name : updateSubmitAllPharmanet
Purpose : Update the multiple payloads.
Version : 1.0
Devloper Name : Accenture.
Date : 19/Feb/2025
--------------------------------------------------------------------------*/
    public void updateSubmitAllPharmanet(String inputJSON, Map<String,Object> outputMap)
    { 
        Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(inputJSON);        
        List<Object> sObjectList = (List<Object>) jsonMap.get('updatedAllValue');        
        String recordsJson = JSON.serialize(sObjectList);
        List<EDRD_PharmanetWrapper.InputWrapper> recordList =  (List<EDRD_PharmanetWrapper.InputWrapper>) JSON.deserialize(recordsJson, List<EDRD_PharmanetWrapper.InputWrapper>.class);
        for(EDRD_PharmanetWrapper.InputWrapper inputwrap:recordList){
            saaRequestAPICallout(inputwrap);
            
        }
    }
/*-------------------------------------------------------------------
Method Name : updateSubmitPharmanet
Purpose : Update the single payloads.
Version : 1.0
Devloper Name : Accenture.
Date : 19/Feb/2025
--------------------------------------------------------------------------*/
    public void updateSubmitPharmanet(String jsonInput, Map<String,Object> outputMap)
    {
        Boolean isSuccess = false;
        EDRD_PharmanetWrapper.OutputWrapper wrapper = new EDRD_PharmanetWrapper.OutputWrapper();     
        EDRD_PharmanetWrapper.InputWrapper inputWrapper = (EDRD_PharmanetWrapper.InputWrapper) JSON.deserialize(jsonInput, EDRD_PharmanetWrapper.InputWrapper.class);
        try
        {
           	isSuccess = saaRequestAPICallout(inputWrapper);
            wrapper.isPharmaNetSubmitSuccessfull = isSuccess;
            wrapper.isSubmitSuccessful = true;
        	outputMap.put('isSubmitSuccessful',wrapper.isPharmaNetSubmitSuccessfull);
            outputMap.put('isSubmitMessage',wrapper.isSubmitSuccessful);
            updatePharmanet(inputWrapper.pharmaNetRecordId);
            updateCaseRec(inputWrapper.caseId);
        }
        Catch(Exception E)
        {
            wrapper.isPharmaNetSubmitSuccessfull = isSuccess;
            wrapper.isSubmitSuccessful = false;
            outputMap.put('isSubmitSuccessful', wrapper.isPharmaNetSubmitSuccessfull); 
            outputMap.put('isSubmitMessage',wrapper.isSubmitSuccessful); 
        }        
        return;
    }
/*-------------------------------------------------------------------
Method Name : markPushedToPharmanet
Purpose : Updating case Pharmanet.
Version : 1.0
Devloper Name : Accenture.
Date : 19/Feb/2025
--------------------------------------------------------------------------*/
    public void markPushedToPharmanet(String jsonInput, Map<String,Object> outputMap)
    {
        EDRD_PharmanetWrapper.InputWrapper inputWrapper = (EDRD_PharmanetWrapper.InputWrapper) JSON.deserialize(jsonInput, EDRD_PharmanetWrapper.InputWrapper.class);
        updateCaseRec(inputWrapper.CaseId);
    }
    public Boolean saaRequestAPICallout(EDRD_PharmanetWrapper.InputWrapper inputWrapper)
    {
        List<String> justificationCodesList = new List<String>{inputWrapper.justificationCodes};
        List<String> excludedPlansList = new List<String>{inputWrapper.excludedPlans};
        Boolean isSuccess = false;
      
        SAApprovalRequest saaRequest = new SAApprovalRequest();
        saaRequest.saRecord = new SAApprovalRequest.SARecord();
        saaRequest.saRecord.saRequester = new SAApprovalRequest.SARequester();
        saaRequest.saRecord.specialItem = new SAApprovalRequest.SpecialItem();
        saaRequest.saRecord.terminationDate = inputWrapper.terminationDate != 'null' ? String.ValueOf(inputWrapper.terminationDate) : 'null' ;
        saaRequest.saRecord.specAuthType = inputWrapper.specAuthType;
        saaRequest.saRecord.phn = inputWrapper.phn;
        saaRequest.saRecord.saRequester.practId = inputWrapper.practId;
        saaRequest.saRecord.saRequester.practIdRef = String.ValueOf(Label.EDRD_Pharmanet_Pract_ReftId);
        DateTime effectiveDate = inputWrapper.effectiveDate.addDays(1);
        String effectiveDateOnly = String.ValueOf(effectiveDate.Date());
        saaRequest.saRecord.effectiveDate =  effectiveDateOnly;
        saaRequest.saRecord.maxDaysSupply = Integer.valueof(inputWrapper.maxDaysSupply);
        saaRequest.saRecord.maxPricePct = inputWrapper.maxPricePct;
        saaRequest.saRecord.justificationCodes = justificationCodesList;
        saaRequest.saRecord.excludedPlans = excludedPlansList;       
        saaRequest.saRecord.specialItem.din =  String.valueof(inputWrapper.din);
        if(!Test.isRunningTest()){
            PharmanetPayloadController.submitSinglePnetSar(inputWrapper.caseId, saaRequest);
            Integration_Log__c intRecord = new Elevated().getIntegrationLogRecord(inputWrapper.caseId);
            isSuccess = ESA_cls_constants.EDRD_Success.equals(String.ValueOf(intRecord.Message__c));
        }
        return isSuccess;
    }
    
    private Static Void updatePharmanet(String pharmanetId){
        Pharmanet_Payload__c record = new Pharmanet_Payload__c();
        record.Id = pharmanetId;
        record.EDRD_isPharmaNetSubmitSuccessful__c = true;
        update record;
    }
    private static void updateCaseRec(String caseId){
        Case record = new Case();
        record.Id = caseId;
        record.Pushed_to_Pnet__c = true;
        record.Pushed_to_Pnet_Date__c = Datetime.now();
        record.Termination_Date__c = Date.Today();
        update record;
        
    }
/*---------------------------------------------------------------------
Class Name : Elevated
Purpose : This is Elevated class to get the salesforce data on System mode.
Version : 1.0
Devloper Name : Accenture.
Date : 19/Dec/2024
--------------------------------------------------------------------------*/
    public with sharing class Elevated{        
        public DecisionTable getDTId(String DecisionTableName){
            return [SELECT Id  FROM DecisionTable where  DeveloperName =: DecisionTableName LIMIT 1];
        }
        public Integration_Log__c getIntegrationLogRecord(String caseId){
            return [SELECT Id, Message__c FROM Integration_Log__c WHERE SA_Request__c =: caseId ORDER BY LastModifiedDate DESC LIMIT 1];
        }
    }    
}
