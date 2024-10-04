/**********************************************************************************************
* @Author:      Accenture EDRD Team 
* @Date:        27 Aug 2024
* @Description: The purpose of this class is to send sorted queries to OmniScripts
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]
***********************************************************************************************/
global with sharing class EDRD_cls_omniSObjectQueryCallable implements Callable {
    
    /**
    * @author: Deepak
    * @date: 27 Aug 2024
    * @description: The purpose of this method is to return SOQL in ASC Order.
    * @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
    */   
    public Object call(String action, Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>)args.get('input');
        Map<String, Object> output = (Map<String, Object>)args.get('output');
        Map<String, Object> options = (Map<String, Object>)args.get('options');

        return invokeMethod(action, input, output, options);
    }

    private Object invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options) {
        if (methodName.equals('MedicationNames')) {
            List<Map<String, String>> UIoptions = new List<Map<String, String>>();
            
            for (Medication medObj : [SELECT Id, Name FROM Medication WHERE Status = 'Active' ORDER BY Name ASC]) {
                Map<String, String> tempMap = new Map<String, String>();
                tempMap.put('name', medObj.Id);
                tempMap.put('value', medObj.Name);  
                UIoptions.add(tempMap);
            }
            outMap.put('options', UIoptions);
        } else if (methodName.equals('RenewalMedicationNames')) {
            List<Map<String, String>> UIoptions = new List<Map<String, String>>();
            
            for (Medication medObj : [SELECT Id, Name FROM Medication WHERE Status = 'Active' AND One_time_Dose__c = FALSE ORDER BY Name ASC]) {
                Map<String, String> tempMap = new Map<String, String>();
                tempMap.put('name', medObj.Id);
                tempMap.put('value', medObj.Name);  
                UIoptions.add(tempMap);
            }
            outMap.put('options', UIoptions);
        }
        return true;
    } 
}