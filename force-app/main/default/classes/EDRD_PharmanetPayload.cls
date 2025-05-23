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
        switch on methodName {
            when 'updateSubmitPharmanet'{
                this.updateSubmitPharmanet(jsonInput,outputMap);
            }
            when 'getPharmanetDecisionTable'{
                this.getPharmanetDecisionTable(jsonInput,outputMap);
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
        
        DecisionTable dt = new Elevated().getDTId(ESA_cls_constants.PharmaNetPayloads); 
        ConnectApi.DecisionTableInput input = new ConnectApi.DecisionTableInput();
        input.conditions = new List<ConnectApi.DecisionTableCondition>();
		
		ConnectApi.DecisionTableCondition condition1 = new ConnectApi.DecisionTableCondition();
        condition1.fieldName = ESA_cls_constants.ApplicationName;
        condition1.value = ESA_cls_constants.ApplicationNameValue;
        input.conditions.add(condition1);	
        
      	ConnectApi.DecisionTableCondition condition2 = new ConnectApi.DecisionTableCondition();
        condition2.fieldName = ESA_cls_constants.CaseType;
        condition2.value = inputWrapper.caseType;
        input.conditions.add(condition2);
        
        ConnectApi.DecisionTableCondition condition3 = new ConnectApi.DecisionTableCondition();
        condition3.fieldName = ESA_cls_constants.IndicationName;
        condition3.value = inputWrapper.indication;
        input.conditions.add(condition3);
        
        ConnectApi.DecisionTableCondition condition4 = new ConnectApi.DecisionTableCondition();
        condition4.fieldName = ESA_cls_constants.MedicationName;
        condition4.value = inputWrapper.medicationName;
        input.conditions.add(condition4);

        ConnectApi.DecisionTableOutcome decisionOutcome =  ConnectApi.DecisionTable.execute(dt.Id, input);
        if (decisionOutcome != null && decisionOutcome.successStatus) 
        {           
            List<ConnectApi.DecisionTableOutcomeItem> decisionTableItems = decisionOutcome.outcomeList;
            List<EDRD_PharmanetWrapper.OutputWrapper > outputWrappers = new List<EDRD_PharmanetWrapper.OutputWrapper >();    
            for (ConnectApi.DecisionTableOutcomeItem item : decisionTableItems) 
            {
                EDRD_PharmanetWrapper.OutputWrapper wrapper = new EDRD_PharmanetWrapper.OutputWrapper();  
                wrapper.din = (String) item.values.get(ESA_cls_constants.DIN);
                wrapper.effectiveDate = inputWrapper.caseFundingStartdate;
                wrapper.excludedPlans = (String) item.values.get(ESA_cls_constants.ExcludedPlans);
                wrapper.isPharmaNetSubmitSuccessfull = Boolean.ValueOf(inputWrapper.casePushToPnet);
                wrapper.justificationCodes = (String) item.values.get(ESA_cls_constants.JustificationCode);
                wrapper.maxDaysSupply = (Double) item.values.get(ESA_cls_constants.MaxDaysSupply);
                wrapper.maxPricePct = (Double) item.values.get(ESA_cls_constants.MaxPricePercent);                
                wrapper.medName = (String) item.values.get(ESA_cls_constants.MedName);
                wrapper.practId = inputWrapper.practId;
                wrapper.practIdRef = (String) System.Label.EDRD_Pharmanet_Pract_ReftId;
                wrapper.phn = inputWrapper.phn;
                wrapper.rdp = (String) item.values.get(ESA_cls_constants.RDPCode);                
                wrapper.specAuthType = (String) item.values.get(ESA_cls_constants.SAType);               
                wrapper.terminationDate = inputWrapper.terminationDate != 'null' ? (String) inputWrapper.terminationDate : null;
                outputWrappers.add(wrapper);
            }
            String result = Json.serialize(outputWrappers);
            outputMap.put('pharmanetOutput',JSON.deserializeuntyped(result));             
        }
        return;              
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
        EDRD_PharmanetWrapper.OutputWrapper wrapper = new EDRD_PharmanetWrapper.OutputWrapper();     
        EDRD_PharmanetWrapper.InputWrapper inputWrapper = (EDRD_PharmanetWrapper.InputWrapper) JSON.deserialize(jsonInput, EDRD_PharmanetWrapper.InputWrapper.class);              
        try{
            if(!Test.isRunningTest()){
            saaRequestAPICallout(inputWrapper);
            wrapper = getDataFromIntLog(inputWrapper);
            }           
        }
        catch(Exception e){
             if(!Test.isRunningTest()){
            	wrapper = getDataFromIntLog(inputWrapper);
             }
        }
        outputMap.put('isPharmaNetSubmitSuccessfull', wrapper.isPharmaNetSubmitSuccessfull); 
        outputMap.put('isSubmitMessage',wrapper.isSubmitSuccessful); 
        outputMap.put('ErrorMessage',wrapper.ErrorMessage);      
        return ;
    }
    private EDRD_PharmanetWrapper.OutputWrapper getDataFromIntLog(EDRD_PharmanetWrapper.InputWrapper inputWrapper){
     	EDRD_PharmanetWrapper.OutputWrapper wrapper = new EDRD_PharmanetWrapper.OutputWrapper();
        datetime start = System.Now();
        while(System.Now() < start.addSeconds(5)){}
        Integration_Log__c intRecord = [SELECT Id, Message__c,CreatedDate,Code__c FROM Integration_Log__c WHERE SA_Request__c =: inputWrapper.caseId ORDER BY CreatedDate DESC LIMIT 1];
        if(ESA_cls_constants.EDRD_Success.equalsIgnoreCase(String.ValueOf(intRecord.Message__c)) || intRecord.Code__c == 201 ||  intRecord.Code__c == 200){
            wrapper.isSubmitSuccessful = true;
            wrapper.isPharmaNetSubmitSuccessfull = true;
            wrapper.ErrorMessage = intRecord.Message__c;
            updateCaseRec(inputWrapper);
        }
        else
        {
            wrapper.isSubmitSuccessful = false;
            wrapper.isPharmaNetSubmitSuccessfull = false;
            wrapper.ErrorMessage = intRecord.Message__c; 
        }      
       return wrapper;                
 }
    public void saaRequestAPICallout(EDRD_PharmanetWrapper.InputWrapper inputWrapper)
    {
        List<String> justificationCodesList = new List<String>{inputWrapper.justificationCodes};
        List<String> excludedPlansList = new List<String>();
        if(inputWrapper.excludedPlans.contains(',')){
             excludedPlansList = inputWrapper.excludedPlans.split(',');
        }
        else{ excludedPlansList = new List<String>{inputWrapper.excludedPlans}; }        
        if(inputWrapper.rdp.contains('-')){
            inputWrapper.rdp = inputWrapper.rdp.replace('-', '');
        }        
        Boolean isSuccess = false;        
        SAApprovalRequest saaRequest = new SAApprovalRequest();
        saaRequest.saRecord = new SAApprovalRequest.SARecord();
        saaRequest.saRecord.saRequester = new SAApprovalRequest.SARequester();
        saaRequest.saRecord.specialItem = new SAApprovalRequest.SpecialItem();        
        saaRequest.saRecord.terminationDate = inputWrapper.terminationDate != 'null' ? String.ValueOf(inputWrapper.terminationDate) : 'null' ;
        saaRequest.saRecord.specAuthType = inputWrapper.specAuthType;
        saaRequest.saRecord.phn = inputWrapper.phn;
        saaRequest.saRecord.saRequester.practId = inputWrapper.practId;
        saaRequest.saRecord.saRequester.practIdRef = String.ValueOf(inputWrapper.practIdRef);
        DateTime effectiveDate = inputWrapper.effectiveDate;
        String effectiveDateOnly = String.ValueOf(effectiveDate.Date());
        saaRequest.saRecord.effectiveDate =  effectiveDateOnly;
        saaRequest.saRecord.maxDaysSupply = Integer.valueof(inputWrapper.maxDaysSupply);
        saaRequest.saRecord.maxPricePct = inputWrapper.maxPricePct;
        saaRequest.saRecord.justificationCodes = justificationCodesList;
        saaRequest.saRecord.excludedPlans = excludedPlansList;      
        if(!String.isBlank(inputWrapper.din) && inputWrapper.din != 'null'){saaRequest.saRecord.specialItem.din =  String.valueof(inputWrapper.din);}
        if(!String.isBlank(inputWrapper.rdp) && inputWrapper.rdp != 'null'){saaRequest.saRecord.specialItem.rdp =  String.valueof(inputWrapper.rdp);}
        if(!Test.isRunningTest()){
            PharmanetPayloadController.submitSinglePnetSar(inputWrapper.caseId, saaRequest);           
        }
    }

    private static void updateCaseRec(EDRD_PharmanetWrapper.InputWrapper inputWrapper){
        Case record = new Case();     
        record.Id = inputWrapper.caseId;
        record.Pushed_to_Pnet__c = true;
        record.Pushed_to_Pnet_Date__c = Datetime.now();
        record.Termination_Date__c = getTerminationDate(inputWrapper);       
        update record;

    }
    private Static Date getTerminationDate(EDRD_PharmanetWrapper.InputWrapper inputWrapper){
         Date TerminationDate;
        List<Case>  lstcase = [Select Id,EDRD_MOHFunding_Decision__c,EDRD_MOHFunding_Extension_Date__c,EDRD_MOHFunding_Expiry_Date__c From case where Id =:inputWrapper.caseId Limit 1];
        if(lstcase.size() > 0){
          TerminationDate = Date.ValueOf(ESA_cls_constants.Extended.equalsIgnoreCase(String.ValueOf(lstcase[0].EDRD_MOHFunding_Decision__c)) && lstcase[0].EDRD_MOHFunding_Extension_Date__c != null ? lstcase[0].EDRD_MOHFunding_Extension_Date__c : ( ESA_cls_constants.Approved.equalsIgnoreCase(String.ValueOf(lstcase[0].EDRD_MOHFunding_Decision__c)) && lstcase[0].EDRD_MOHFunding_Expiry_Date__c != null ? lstcase[0].EDRD_MOHFunding_Expiry_Date__c : null));      
        }
        return TerminationDate; 
        
    }
/*---------------------------------------------------------------------
Class Name : Elevated
Purpose : This is Elevated class to get the salesforce data on System mode.
Version : 1.0
Devloper Name : Accenture.
Date : 19/Dec/2024
--------------------------------------------------------------------------*/
    public without sharing class Elevated{        
        public DecisionTable getDTId(String DecisionTableName){
            return [SELECT Id  FROM DecisionTable where  DeveloperName =: DecisionTableName LIMIT 1];
        }        
    }    
}