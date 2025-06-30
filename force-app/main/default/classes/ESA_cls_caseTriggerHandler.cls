/**********************************************************************************************
* @Author:      Deepak 
* @Date:        23 Feb 2023
* @Description: The purpose of this class is to create methods which can be used by different trigger event
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description] 
                1 Dec23 -   EDRD-170          -   Rahul       -  Manage case assignment
                4 Dec23 -   EDRD-332          -  Accenture    -  Change case status according to RPH, SC, AC Review Field
                16 Dec23 -  EDRD-282          -  Accenture    -  Sync MR Fields values to Case Fields values
                09 Jan -    EDRD-139          -  Accenture    -  calculate DrugForecast on Case
                15 Jan -    EDRD-525          -  Accenture    -  Update AC Recommendation Review
                19 Jan-     EDRD-338		  -  Accenture	  -  Update Funding Expiry Date
                19 Jan-     EDRD-382		  -  Accenture	  -  Validate Eligibility Form Sign date and Eligibility form Attachment
                20 Jun-     EDRD-764		  -  Accenture    -  Populate EDRD Reference number
                07 Jun-     EDRD-679		  -  Accenture    -  Generate FY forecasting records
                17 Oct-     EDRD-1010		  -  Accenture    -  Collect set of caseId's and pass it to future method
                17 Oct-     EDRD-1010		  -  Accenture    -  Future method(Private) is to update EDRD Provider field on Person Account.
                19 May-     EDRD-1216		  -  Accenture    -  Method to update Status of Care Program Enrolee From Inactive to Active
                30 May-     EDRD-1469		  -  Accenture    -  Method to update EDRD Provider Account field on Case if Provider lookup gets updated.
***********************************************************************************************/

public with sharing class ESA_cls_caseTriggerHandler {    
    public static boolean firstrun= true;  
    public static boolean FYOnce= true;
    public static Id recordTypeCaseEDRD = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('EDRD').getRecordTypeId();
    public static Decimal costPerDose = 0;
    public static Map<Id, Decimal> caseIdVsCostPerDose = new Map<Id, Decimal>();
/**
* @author: Deepak
* @date: 23 Feb 2023
* @description: The purpose of this method is to populate termination date based on Approval time/time unit
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/    
    public static void populateTerminationDate(List<Case> allNewCases, Map<id,Case> allOldCaseMap, Map<id,Case> allNewCaseMap){

        List<Case> newCases = new List<Case>();
        Map<id,Case> oldCaseMap = new Map<id,Case>();
        Map<id,Case> newCaseMap = new Map<id,Case>();

        for(Case cs : allNewCases){

            if(cs.Record_Type_Name__c == 'Special_Authority_Request'){
                newCases.add(cs);
                if(allOldCaseMap != NULL && allOldCaseMap.size()>0){
                    oldCaseMap.put(cs.Id, allOldCaseMap.get(cs.Id));
                }
                if(allNewCaseMap != NULL && allNewCaseMap.size()>0){
                    newCaseMap.put(cs.Id, allNewCaseMap.get(cs.Id));
                }
            }
            if(cs.RecordTypeId == recordTypeCaseEDRD &&  cs.Pushed_to_Pnet__c == true){                   
                cs.Termination_Date__c =  ESA_cls_constants.Extended.equalsIgnoreCase(String.ValueOf(cs.EDRD_MOHFunding_Decision__c)) && cs.EDRD_MOHFunding_Extension_Date__c != null ? cs.EDRD_MOHFunding_Extension_Date__c : ( ESA_cls_constants.Approved.equalsIgnoreCase(String.ValueOf(cs.EDRD_MOHFunding_Decision__c)) && cs.EDRD_MOHFunding_Expiry_Date__c != null ? cs.EDRD_MOHFunding_Expiry_Date__c : null);   
            }
        }

        if(newCases != NULL && newCases.size()>0){
            for(Case caseObj:newCases){
                Boolean isInputsChange = trigger.isUpdate && (oldCaseMap.get(caseObj.id).ESA_Approval_Time__c != newCaseMap.get(caseObj.id).ESA_Approval_Time__c ||
                                                              oldCaseMap.get(caseObj.id).ESA_Approval_Time_Unit__c != newCaseMap.get(caseObj.id).ESA_Approval_Time_Unit__c);
                if((trigger.isInsert && caseObj.Termination_Date__c == NULL) || isInputsChange){
                    if(caseObj.ESA_Approval_Time__c != NULL && caseObj.ESA_Approval_Time_Unit__c != NULL){
                        caseObj.Termination_Date__c = ESA_cls_constants.CASE_APPROVAL_TIME_UNIT_WEEK.containsIgnoreCase(caseObj.ESA_Approval_Time_Unit__c) ? System.Today().addDays((Integer.valueOf(caseObj.ESA_Approval_Time__c)*7)+1)
                            : ESA_cls_constants.CASE_APPROVAL_TIME_UNIT_MONTH.containsIgnoreCase(caseObj.ESA_Approval_Time_Unit__c) ? System.Today().addMonths(Integer.valueOf(caseObj.ESA_Approval_Time__c)).addDays(1)
                                : ESA_cls_constants.CASE_APPROVAL_TIME_UNIT_DAYS.containsIgnoreCase(caseObj.ESA_Approval_Time_Unit__c) ? System.Today().addDays((Integer.valueOf(caseObj.ESA_Approval_Time__c))+1)
                                    : NULL;
                        
                    }
                    else {
                        caseObj.Termination_Date__c = NULL;
                    }
                }
                
            }
        }   
    }
    
/**
* @author: Rahul
* @date: 9 Dec 2023
* @description: The purpose of this method is to manage the case assignment in case of inline edit
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/  
    public static void manageAssignmentRule(List<Case> cases, Map<Id, Case> oldCaseMap){
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.useDefaultRule = true;
        List<Case> caseAssignment = new List<Case>();
        For(Case newCase :[Select Id,OwnerId, Status FROM Case WHERE Id in :cases]){
            if(newCase.OwnerId == oldCaseMap.get(newCase.Id).OwnerId && newCase.status != oldCaseMap.get(newCase.Id).Status){
                newCase.setOptions(dmlOpts);
                caseAssignment.add(newCase);
            }
        }
        update caseAssignment;
    }

/**
* @author: Deepak
* @date: 04 Dec 2023
* @description: The purpose of this method is to Change case status according to RPH, SC, AC Review Field
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
                     08 Apr -     EDRD-1450		  -  Deepak    -  Adding EDRD RecordType check
*/ 
    
    public static void assignStatus(Map<Id,Case> oldCaseMap, Map<Id,Case> newCaseMap){
        for(Case caseObj: newCaseMap.values()){
            Boolean isRPHReviewChanged = (caseObj.RecordTypeId == recordTypeCaseEDRD) && (oldCaseMap.get(caseObj.Id).EDRD_RPH_Review_Pathway__c != newCaseMap.get(caseObj.Id).EDRD_RPH_Review_Pathway__c);
            Boolean isSCReviewChanged = (caseObj.RecordTypeId == recordTypeCaseEDRD) && (oldCaseMap.get(caseObj.Id).EDRD_SC_Review_Pathway__c != newCaseMap.get(caseObj.Id).EDRD_SC_Review_Pathway__c);
            Boolean isACReviewChanged = (caseObj.RecordTypeId == recordTypeCaseEDRD) && (oldCaseMap.get(caseObj.Id).EDRD_AC_Review_Pathway__c != newCaseMap.get(caseObj.Id).EDRD_AC_Review_Pathway__c);
            if((isRPHReviewChanged && isSCReviewChanged) || (isSCReviewChanged && isACReviewChanged) || (isRPHReviewChanged && isACReviewChanged)){
                caseobj.addError(Label.EDRD_label_pathwayValidationErrorMsg);
            }
            
            if(isRPHReviewChanged && !String.isEmpty(caseObj.EDRD_RPH_Review_Pathway__c)){
                caseObj.Status = returnStatus(caseObj.EDRD_RPH_Review_Pathway__c);
            }else if(isSCReviewChanged && !String.isEmpty(caseObj.EDRD_SC_Review_Pathway__c)){
                caseObj.Status = returnStatus(caseObj.EDRD_SC_Review_Pathway__c);
                caseObj.EDRD_AC_Review_Requested__c = caseObj.EDRD_SC_Review_Pathway__c == 'Sent to AC' ? true : false;
                caseObj.EDRD_Advisory_Committee__c = caseObj.EDRD_SC_Review_Pathway__c == 'Sent to AC' ? 'EDRD Advisory Committee' : NULL;
            }else if(isACReviewChanged && !String.isEmpty(caseObj.EDRD_AC_Review_Pathway__c)){
                caseObj.Status = returnStatus(caseObj.EDRD_AC_Review_Pathway__c);
            }
        }
    }
    
    private static String returnStatus(String reviewPathWay){
        String status = '';
        if(reviewPathWay == 'Sent to SC'){
            status = 'SC Review';
        }else if(reviewPathWay == 'Sent to AC'){
            status = 'AC Review';
        }else if(reviewPathWay == 'Sent to MOH'){
            status = 'MOH Review';
        }
        return status;
    }
    
/**
* @author: Deepak
* @date: 15 Dec 2023
* @description: The purpose of this method is to Sync case field values with Medication Request.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
                     08 Apr -     EDRD-1450		  -  Deepak    -  Adding Provider change logic for EDRD Case
*/ 
    public static void syncCaseToMR(Map<id,Case> oldCaseMap, Map<id,Case> newCaseMap){
        List<MedicationRequest> MRListToUpdate = new List<MedicationRequest>();
        Set<String> caseStatusValueSet = new Set<String>{'Received - Awaiting Verification', 'SC Review', 'AC Review', 'MOH Review'};
        Set<Id> caseIdSet = new Set<Id>();
        Id recordTypeCaseEDRD = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('EDRD').getRecordTypeId();
        for(Case caseObj: newCaseMap.values()){
            Boolean isStatusChanged = oldCaseMap.get(caseObj.id).Status != newCaseMap.get(caseObj.id).Status;
            Boolean isProrityChanged = oldCaseMap.get(caseObj.id).Priority != newCaseMap.get(caseObj.id).Priority;
            Boolean isTypeChanged = oldCaseMap.get(caseObj.id).Type != newCaseMap.get(caseObj.id).Type;
            Boolean isEDRDRefChanged = oldCaseMap.get(caseObj.id).EDRD_Ref_No__c != newCaseMap.get(caseObj.id).EDRD_Ref_No__c;
            Boolean isProviderChanged = oldCaseMap.get(caseObj.id).Provider__c != newCaseMap.get(caseObj.id).Provider__c;
            if(caseObj.RecordTypeId == recordTypeCaseEDRD && (isStatusChanged || isProrityChanged || isTypeChanged || isEDRDRefChanged || isProviderChanged)){
                caseIdSet.add(caseObj.Id);
            }
        }
        for(MedicationRequest MRObj:[SELECT Id, Case__r.Type, Case__r.Status, Case__r.Priority, Case__r.EDRD_Ref_No__c, Case__r.Provider__r.AccountId FROM MedicationRequest WHERE Case__c IN: caseIdSet]){
            MRObj.Status = caseStatusValueSet.Contains(MRObj.Case__r.Status) ? 'Active' : MRObj.Case__r.Status;
            MRObj.Type = MRObj.Case__r.Type;
            MRObj.Priority = MRObj.Case__r.Priority;
            MRObj.EDRD_Reference_Number__c = !String.isBlank(MRObj.Case__r.EDRD_Ref_No__c) ? MRObj.Case__r.EDRD_Ref_No__c : NULL;
            MRObj.RequesterId = (!String.isEmpty(MRObj.Case__c) && !String.isEmpty(MRObj.Case__r.Provider__c) && !String.isEmpty(MRObj.Case__r.Provider__r.AccountId)) ? MRObj.Case__r.Provider__r.AccountId : NULL;
            MRListToUpdate.add(MRObj);
        }
        
        if(!MRListToUpdate.isEmpty()){
            Update MRListToUpdate;
        }
    }

/**
* @author: Deepak
* @date: 09 Jan 2024
* @description: The purpose of this method is to calculate DrugForecast on Case.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/    
    public static void calDrugForecast(Map<Id,Case> oldCaseMap, Map<Id,Case> newCaseMap){
        Map<Id, case> caseIdVsRec = new Map<Id, case>();
        for(Case caseObj: newCaseMap.values()){
            Boolean isInputFieldsChanged = (newCaseMap.get(caseObj.Id).EDRD_MOHApproved_Dosage__c != oldCaseMap.get(caseObj.Id).EDRD_MOHApproved_Dosage__c ||
                                            newCaseMap.get(caseObj.Id).EDRD_MOHApproved_Dosage_Unit__c != oldCaseMap.get(caseObj.Id).EDRD_MOHApproved_Dosage_Unit__c ||
                                            newCaseMap.get(caseObj.Id).EDRD_MOHApproved_Frequency__c != oldCaseMap.get(caseObj.Id).EDRD_MOHApproved_Frequency__c ||
                                            newCaseMap.get(caseObj.Id).EDRD_MOHApproved_Frequency_Unit__c != oldCaseMap.get(caseObj.Id).EDRD_MOHApproved_Frequency_Unit__c ||
                                            newCaseMap.get(caseObj.Id).EDRD_MOHIndefinite_Funding__c != oldCaseMap.get(caseObj.Id).EDRD_MOHIndefinite_Funding__c || 
                                            newCaseMap.get(CaseObj.Id).Status != oldCaseMap.get(CaseObj.Id).Status && caseObj.Status == 'Funding Approved' ||
                                            newCaseMap.get(caseObj.Id).EDRD_MOHApproved_Funding_Duration__c != oldCaseMap.get(caseObj.Id).EDRD_MOHApproved_Funding_Duration__c ||
                                            newCaseMap.get(caseObj.Id).EDRD_MOHApproved_Funding_Duration_Unit__c != oldCaseMap.get(caseObj.Id).EDRD_MOHApproved_Funding_Duration_Unit__c);
            if(isInputFieldsChanged){
                caseIdVsRec.put(CaseObj.id, caseObj);
            }
        }
        Map<Id, Decimal> caseIdVsForcastAmnt = medicationRequestTriggerHandler.calDrugForecastOnCase(caseIdVsRec.KeySet(), caseIdVsRec);
        if(!caseIdVsForcastAmnt.isEmpty()){
            for(Case caseObj: newCaseMap.values()){
                caseObj.EDRD_MOHDrug_Cost_Forecast__c = caseIdVsForcastAmnt.ContainsKey(caseObj.Id) ? caseIdVsForcastAmnt.get(caseObj.Id) : NULL;
                caseObj.EDRD_Cost_Per_Dose__c = caseIdVsCostPerDose.ContainsKey(caseObj.Id) ? caseIdVsCostPerDose.get(caseObj.Id) : NULL;
            }  
        }
    } 
    
/**
* @author: Deepak
* @date: 15 Jan 2024
* @description: The purpose of this method is to Update AC Recommendation Review.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/  
    public static void assignACRecReview(Map<id,Case> oldCaseMap, Map<id,Case> newCaseMap){
        Set<String> caseSCReviewValueSet = new Set<String>{'Sent to MOH'};
        Id recordTypeCaseEDRD = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('EDRD').getRecordTypeId();
        for(Case caseObj: newCaseMap.values()){
            Boolean isSCReviewChanged = oldCaseMap.get(caseObj.id).EDRD_SC_Review_Pathway__c != newCaseMap.get(caseObj.id).EDRD_SC_Review_Pathway__c;
            
            if(recordTypeCaseEDRD == caseObj.RecordTypeId && isSCReviewChanged && caseSCReviewValueSet.Contains(caseObj.EDRD_SC_Review_Pathway__c)){
                caseObj.EDRD_AC_Recommendation_Review__c = 'Not Applicable';
            }else if(recordTypeCaseEDRD == caseObj.RecordTypeId && isSCReviewChanged && !String.isEmpty(caseObj.EDRD_SC_Review_Pathway__c)){
                caseObj.EDRD_AC_Recommendation_Review__c = NULL;
            }
        }
    }
    
/**
* @author: Rahul
* @date: 19 Jan 2024
* @description: The purpose to Update Funding Expiry and Extension dates
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/  
    public static void calculateFundingExpiryDate(List<Case> cases, Map<Id, Case> oldCaseMap){
        for(Case caseObj : cases){
            if(caseObj.EDRD_MOHFunding_Decision__c != null && caseObj.EDRD_MOHFunding_Decision__c != 'Denied'){
                Boolean updateExpiryDate = (caseObj.EDRD_MOHFunding_Start_Date__c != null || caseObj.EDRD_MOHFunding_Extension_Date__c!= null) && 
                    caseObj.EDRD_MOHApproved_Funding_Duration__c != null &&
                    caseObj.EDRD_MOHApproved_Funding_Duration_Unit__c!= null &&
                    (caseObj.EDRD_MOHFunding_Decision__c == 'Approved' || caseObj.EDRD_MOHFunding_Decision__c == 'Extended');
                Boolean isStartDateChanged = false;
                Boolean isEndDateChanged = false;
                if(trigger.isUpdate && updateExpiryDate){
                    isEndDateChanged = (caseObj.EDRD_MOHFunding_Expiry_Date__c != oldCaseMap.get(caseObj.id).EDRD_MOHFunding_Expiry_Date__c) ||
                        (caseObj.EDRD_MOHFunding_Extension_Date__c != oldCaseMap.get(caseObj.id).EDRD_MOHFunding_Extension_Date__c);
                    isStartDateChanged = (caseObj.EDRD_MOHFunding_Start_Date__c != oldCaseMap.get(caseObj.id).EDRD_MOHFunding_Start_Date__c);
                }
                if(trigger.isInsert && updateExpiryDate){
                    isEndDateChanged = caseObj.EDRD_MOHFunding_Expiry_Date__c != null || caseObj.EDRD_MOHFunding_Extension_Date__c != null;
                    isStartDateChanged = caseObj.EDRD_MOHFunding_Start_Date__c != null;
                }
                if(!isEndDateChanged && !caseObj.EDRD_MOHIndefinite_Funding__c && caseObj.EDRD_MOHFunding_Start_Date__c != null && caseObj.EDRD_MOHApproved_Funding_Duration__c != null){
                    if(caseObj.EDRD_MOHFunding_Decision__c == 'Approved'){
                        caseObj.EDRD_MOHFunding_Expiry_Date__c = populateExpiryDate(caseObj.EDRD_MOHFunding_Start_Date__c,caseObj.EDRD_MOHApproved_Funding_Duration__c,caseObj.EDRD_MOHApproved_Funding_Duration_Unit__c);
                    }else if(caseObj.EDRD_MOHFunding_Decision__c == 'Extended'){
                        caseObj.EDRD_MOHFunding_Extension_Date__c = populateExpiryDate(caseObj.EDRD_MOHFunding_Start_Date__c,Integer.valueOf(caseObj.EDRD_MOHApproved_Funding_Duration__c),caseObj.EDRD_MOHApproved_Funding_Duration_Unit__c);
                    }
                }
                if(caseObj.EDRD_MOHIndefinite_Funding__c){
                    caseObj.EDRD_MOHFunding_Expiry_Date__c = null;
                    caseObj.EDRD_MOHFunding_Extension_Date__c = null;
                }
            }
        }
    }
    public static Date populateExpiryDate(Date startDate, Decimal duration, String unit){
        Date expDate;
        Integer durationRound = Integer.valueOf(duration.round(System.RoundingMode.CEILING));
        if(unit == 'Days'){
            expDate = startDate.addDays(durationRound).addDays(-1);
        }else if(unit == 'Weeks'){
            expDate = startDate.addDays(durationRound*7).addDays(-1);
        }else if(unit == 'Months'){
            expDate = startDate.addMonths(durationRound).addDays(-1);
        }else if(unit == 'Years'){
            expDate = startDate.addYears(durationRound).addDays(-1);
        }else if(unit == 'Once'){
            expDate = startDate;
        }
        return expDate;
    }
    
/**
* @author: Deepak
* @date: 20 Jun 2024
* @description: The purpose of this method is to Populate EDRD Reference number from CareProgramEnrollee.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/
    public static void populateEDRDRefNumber(List<Case> newCaseList, Map<Id, Case> newCaseMap, Map<Id, Case> oldCaseMap){
        Map<Id, Case> patientIdVsCase = new Map<Id, Case>();
        Map<Id, CareProgramEnrollee> patientIdVsCarePrgEnrolle = new Map<Id, CareProgramEnrollee>();
        
        for(Case caseObj: newCaseList){
            Boolean isAccountIdChanged = trigger.isUpdate && newCaseMap.get(caseObj.Id).ContactId != oldCaseMap.get(caseObj.Id).ContactId;
            if(!String.isEmpty(caseObj.ContactId) && caseObj.RecordTypeId == recordTypeCaseEDRD && 
               (trigger.isInsert || isAccountIdChanged)){
                   patientIdVsCase.put(caseObj.ContactId, caseObj);
               }
        }
        if(!patientIdVsCase.isEmpty()){
            List<Account> accList = [SELECT Id, Name, Account.PersonContactId, (SELECT Id, Name, CareProgramId FROM AccountCareProgramEnrollees 
                                                       WHERE CareProgram.Name = 'EDRD') FROM Account 
                                     WHERE PersonContactId IN: patientIdVsCase.keySet()];
            
            for(Account accObj : accList){
                if(!accObj.AccountCareProgramEnrollees.isEmpty()){
                    patientIdVsCarePrgEnrolle.put(accObj.PersonContactId, accOBj.AccountCareProgramEnrollees[0]);
                }            
            }
            
            for(Case caseObj: newCaseList){
                caseObj.EDRD_Ref_No__c = patientIdVsCarePrgEnrolle?.get(CaseObj?.ContactId)?.Name;
            }
        }
    }

 

/**
* @author: Deepak
* @date: 07 Jul 2024
* @description: The purpose of this method is to generate FY forecastings.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/    
    public static void forecastDrugCost(Map<Id, Case> newCaseMap, Map<Id, Case> oldCaseMap){
        Set<Id> caseIdSet = new Set<Id>();
        Map<Id, Case> caseIdVsRec = new Map<Id, Case>();
        Boolean isRunOnce = true;
        
        for(Case caseObj: newCaseMap.values()){
            Boolean isFundingRevoked = (newCaseMap.get(CaseObj.Id).Status == 'Funding Approved' && 
                (newCaseMap.get(CaseObj.Id).EDRD_MOHFunding_Expiry_Date__c != oldCaseMap.get(CaseObj.Id).EDRD_MOHFunding_Expiry_Date__c ||
                 newCaseMap.get(CaseObj.Id).EDRD_MOHFunding_Extension_Date__c != oldCaseMap.get(CaseObj.Id).EDRD_MOHFunding_Extension_Date__c ||
                 newCaseMap.get(CaseObj.Id).EDRD_MOHIndefinite_Funding__c != oldCaseMap.get(CaseObj.Id).EDRD_MOHIndefinite_Funding__c));
            
            Boolean isStatusChanged = newCaseMap.get(CaseObj.Id).Status != oldCaseMap.get(CaseObj.Id).Status && caseObj.Status == 'Funding Approved';
            Boolean isStatusChangedFrmFundingApp = newCaseMap.get(CaseObj.Id).Status != oldCaseMap.get(CaseObj.Id).Status && oldCaseMap.get(CaseObj.Id).Status == 'Funding Approved';
            if((isFundingRevoked || isStatusChangedFrmFundingApp) && caseObj.RecordTypeId == recordTypeCaseEDRD){
                caseIdSet.add(caseObj.Id);
            }
            
            if((isStatusChanged || isFundingRevoked) && caseObj.EDRD_MOHFunding_Start_Date__c != NULL && caseObj.EDRD_MOHDrug_Cost_Forecast__c != NULL &&
               (caseObj.EDRD_MOHFunding_Expiry_Date__c != NULL || caseObj.EDRD_MOHIndefinite_Funding__c || caseObj.EDRD_MOHFunding_Extension_Date__c != NULL)
               && caseObj.EDRD_MOHFunding_Decision__c != NULL && caseObj.RecordTypeId == recordTypeCaseEDRD && !caseIdVsRec.containskey(caseObj.Id)){
                   caseIdVsRec.put(caseObj.Id, caseObj);
               }
        }
        if(!caseIdSet.isEmpty()){
            deleteRelatedFYF(caseIdSet);
        }
        
        if(!caseIdVsRec.isEmpty()){
            EDRD_cls_FundingForecastController.generateForecastRecords(caseIdVsRec.values());
        }
    }
    
    private static void deleteRelatedFYF(Set<Id> caseIdSet){
        List<MedicationDispense> caseRelatedFYF = [SELECT Id FROM MedicationDispense 
                                                   Where Case__c IN: caseIdSet];
        if(!caseRelatedFYF.isEmpty()){
            Database.delete(caseRelatedFYF, true);
        }
    }
    
/**
* @author: Deepak
* @date: 17 Oct 2024
* @description: The purpose of this method collect set of caseId's and pass it to future method.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/    
    public static void UpdateProviderOnEDRDCase(List<Case> newCaseList) {
        Set<Id> caseIdSet = new Set<Id>();
        
        for (Case caseObj : newCaseList) {
            if (caseObj.RecordTypeId == recordTypeCaseEDRD) {
                caseIdSet.add(caseObj.Id);
            }
        }
        
        if (!caseIdSet.isEmpty()) {
            UpdateProviderAccountsAsync(caseIdSet);
        }
    }

/**
* @author: Deepak
* @date: 17 Oct 2024
* @description: The purpose of this future method is to update EDRD Provider field on Person Account.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/    
    @future
    private static void UpdateProviderAccountsAsync(Set<Id> caseIdSet) {
        Map<Id, Account> accIdVsRecToUpdate = new Map<Id, Account>();
        
        List<Case> caseList = [SELECT Id, Provider__r.AccountId FROM Case WHERE Id IN :caseIdSet AND Provider__c != NULL 
                               AND Provider__r.Account.Is_EDRD_Provider__pc = FALSE];
        
        for (Case caseObj : caseList) {
            accIdVsRecToUpdate.put(caseObj.Provider__r.AccountId, new Account(Id = caseObj.Provider__r.AccountId, Is_EDRD_Provider__pc = TRUE));
        }
        
        if (!accIdVsRecToUpdate.isEmpty()) {
            Database.Update(accIdVsRecToUpdate.values(), true);
        }
    }
/**
* @author: Accenture
* @date: 19 Oct 2025
* @description: The purpose of this method is to update Status of Care Program Enrolee From Inactive to Active while creating the case from Provider Portal.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/
    public static void updateCareProgramEnrolee(List<case> newCases){
        Set<Id> personAccounts = new Set<Id>();
        List<CareProgramEnrollee> cpeRecordsToUpdate = new List <CareProgramEnrollee>();
        for(Case caseRec : newCases){
            if(caseRec.AccountId != null){
                personAccounts.add(caseRec.AccountId);
            }
        }
        List<CareProgramEnrollee> cpeRecords = [SELECT Id, Status FROM CareProgramEnrollee WHERE AccountId IN : personAccounts];
        if(!cpeRecords.isEmpty()){
            for(CareProgramEnrollee cpeRec : cpeRecords){
                if(ESA_cls_constants.EDRD_Inactive.equals(String.ValueOf(cpeRec.Status))){
                    cpeRec.Status = ESA_cls_constants.EDRD_Active;
                    cpeRecordsToUpdate.add(cpeRec);
                }
            }
            if(!cpeRecordsToUpdate.isEmpty()){
                update cpeRecordsToUpdate;
            }
        }
    }
    
/**
* @author: Deepak
* @date: 30 May 2025
* @description: The purpose of this method is to update EDRD Provider Account field on Case if Provider lookup gets updated.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/   
    public static void updateProviderAcc(Map<Id, Case> oldCaseMap, Map<Id, Case> newCaseMap){
        Map<Id, Id> contactToproviderAccIdMap = new Map<Id, Id>();
        Set<Id> providerContactIdSet = new Set<Id>();
        List<Case> caseListToUpdate = new List<Case>();
        
        for(Case caseObj: newCaseMap.values()){
            Boolean isProviderChanged = oldCaseMap.get(caseObj.id).Provider__c != newCaseMap.get(caseObj.id).Provider__c && caseObj.Provider__c != NULL;
            if(caseObj.RecordTypeId == recordTypeCaseEDRD && isProviderChanged){
                providerContactIdSet.add(caseObj.provider__c);
            }
        }
        
        if (!providerContactIdSet.isEmpty()){
            for (Contact conObj : [SELECT Id, AccountId FROM Contact WHERE Id IN :providerContactIdSet]){
                contactToproviderAccIdMap.put(conObj.Id, conObj.AccountId);
            }
        }
        
        for (Case caseObj : newCaseMap.values()){
            Id providerAccountId = contactToproviderAccIdMap.get(caseObj.Provider__c);
            if (providerAccountId != null && caseObj.Provider_Account__c != providerAccountId) {
                caseObj.Provider_Account__c = providerAccountId;
            }
        }
    }
}