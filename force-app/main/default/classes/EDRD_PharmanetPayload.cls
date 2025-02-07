/*-------------------------------------------------------------------
Class Name : EDRD_PharmanetPayload
Test Class Name : EDRD_PharmanetPayload
Referance Class : EDRD_EmpiIntegrationTest/EmpiIntegration/Patient/EDRD_EmpiWrapper/ESA_cls_constants
Purpose : Get the Patient Information and Validate/Update/Create in Salesforce.
Version : 1.0
Devloper Name : Accenture.
Date : 19/Dec/2024
--------------------------------------------------------------------------*/
global without sharing class EDRD_PharmanetPayload implements Callable{
    
       public Object call(String action, Map<String,Object> args){
        
        Map<String,Object> output = (Map<String,Object>)args.get('output');
        Map<String,Object> options = (Map<String,Object>)args.get('options');
        return invokeMethod(action, args, output, options);
    }
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outputMap, Map<String,Object> options) {
        Boolean result = true; 
        String jsonInput = Json.serialize(inputMap.get('input'));
        EDRD_PharmanetWrapper.InputWrapper inputWrapper = (EDRD_PharmanetWrapper.InputWrapper) JSON.deserialize(jsonInput, EDRD_PharmanetWrapper.InputWrapper.class);
        
        switch on methodName {
            when 'updateSubmitAllPharmanet'{
                this.updateSubmitAllPharmanet(inputWrapper,outputMap);
            }
            when 'getPharmanetDecisionTable'{
                this.getPharmanetDecisionTable(inputWrapper,outputMap);
            }
            when else {                
            }           
        }
        return result;
    } 
   
   
  public void getPharmanetDecisionTable(EDRD_PharmanetWrapper.InputWrapper inputWrapper, Map<String,Object> outputMap)
  {
       DecisionTable dt = [SELECT Id   FROM DecisionTable where  DeveloperName = 'EDRD_PharmaNet_Payload' LIMIT 1];
       List<EDRD_PharmanetWrapper.OutputWrapper> lstpharmanetOW = new List<EDRD_PharmanetWrapper.OutputWrapper>();
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

   
      	ConnectApi.DecisionTableOutcome decisionOutcome =  ConnectApi.DecisionTable.execute(dt.Id, input);/* Your API call or object */
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
                wrapper.effectiveDate = (DateTime) item.values.get('EDRD_Effective_Date__c');
                wrapper.terminationDate = inputWrapper.terminationDate !=null ? (Date)inputWrapper.terminationDate : null;
                wrapper.practId = inputWrapper.practId;
                wrapper.phn = inputWrapper.phn;
            	outputWrappers.add(wrapper);
        }
      
           if(outputWrappers.size() > 0){
               String result = Json.serialize(outputWrappers);
               outputMap.put('pharmanetOutput',JSON.deserializeuntyped(result));
              }
              else{outputMap.put('pharmanetOutput','NoDataFound'); }      
        }
        return;
      
  	
  }
    public void updateSubmitAllPharmanet(EDRD_PharmanetWrapper.InputWrapper inputWrapper, Map<String,Object> outputMap)
    {       
        
    }

 

}