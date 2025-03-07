/**********************************************************************************************
* @Author:       
* @Date:        
* @Description: The purpose of this Trigger is to trigger on particular events
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
                23 Feb -  ESA- 1835         -  Accenture   -  Populate Termination Date on Case
				01 Dec -  EDRD-170          -  Accenture   -  Assignment rule for Cases
                04 Dec -  EDRD-332          -  Accenture   -  Change Case Status on EDRD
                15 Dec -  EDRD-282          -  Accenture   -  Sync MR Fields values to Case Fields values
                09 Jan -  EDRD-139          -  Accenture   -  update Forecast On Case
                15 Jan -  EDRD-525          -  Accenture   -  Update AC Recommendation Review
                19 Jan -  EDRD-338          -  Accenture   -  Update Funding Expiry and Extension Date
                19 Jan-   EDRD-382			-  Accenture   -  Validate Eligibility Form Sign date and Eligibility form Attachment
                20 Jun-   EDRD-764			-  Accenture   -  Populate EDRD Reference number
                17 Oct-   EDRD-1010		    -  Accenture    -  Update Provider's - EDRD Checkbox On EDRD Case Insert
***********************************************************************************************/
trigger CaseTrigger on Case (before insert, before update, after insert, after update) {    
    
    if (Trigger.isAfter && Trigger.isInsert){
        if (SaSettings.triggersEnabled() && Trigger.size == 1) {
            for (Case saCase : Trigger.new) {
                Boolean runEvaluate = !saCase.isClosed && saCase.Drug__c != null;

                //Filtering the case based on record type for SA Request
                if (runEvaluate && saCase.Record_Type_Name__c == 'Special_Authority_Request') {
                    System.debug('!!!saCase.Id'+ saCase.Id);
                    AdjudicationService.evaluateFuture(saCase.Id, true);
                }
            }
        }  
        ESA_cls_caseTriggerHandler.UpdateProviderOnEDRDCase(trigger.new);
        ESA_cls_caseTriggerHandler.updateCareProgramEnrolee(trigger.new);
    }
    
    if(trigger.isBefore){
        if(trigger.isInsert){
            ESA_cls_caseTriggerHandler.populateTerminationDate(trigger.new, NULL, NULL);
            ESA_cls_caseTriggerHandler.populateEDRDRefNumber(trigger.new, NULL, NULL);
        }
        
        if(trigger.isUpdate){
            ESA_cls_caseTriggerHandler.populateTerminationDate(trigger.new, trigger.oldMap, trigger.newMap);
            ESA_cls_caseTriggerHandler.assignStatus(trigger.oldMap, trigger.newMap);
            ESA_cls_caseTriggerHandler.calDrugForecast(trigger.oldMap, trigger.newMap);
            ESA_cls_caseTriggerHandler.assignACRecReview(trigger.oldMap, trigger.newMap);
            ESA_cls_caseTriggerHandler.populateEDRDRefNumber(trigger.new, trigger.newMap, trigger.oldMap);
        }
        ESA_cls_caseTriggerHandler.calculateFundingExpiryDate(trigger.new, trigger.oldMap);
    }
    
    if(trigger.isAfter && trigger.isUpdate){
        
        if(ESA_cls_caseTriggerHandler.firstrun || test.isRunningTest()){
            ESA_cls_caseTriggerHandler.firstrun = false;
            ESA_cls_caseTriggerHandler.manageAssignmentRule(trigger.new, trigger.oldMap);
            ESA_cls_caseTriggerHandler.syncCaseToMR(trigger.oldMap, trigger.newMap);
            if(ESA_cls_caseTriggerHandler.FYOnce){
                ESA_cls_caseTriggerHandler.forecastDrugCost(trigger.newMap, trigger.oldMap);  
            }
        }
    } 
  
}