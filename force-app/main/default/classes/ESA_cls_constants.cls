/**********************************************************************************************
* @Author:      Deepak 
* @Date:        23/02/2023
* @Description: The purpose of this class is to have constant values to be reffered by main class
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
***********************************************************************************************/

public class ESA_cls_constants {
    
    public static final String ApplicationName = 'Application_Name__c';
    public static final String ApplicationNameValue = 'EDRD';
    public static final String CASE_APPROVAL_TIME_UNIT_WEEK = 'Weeks';
    public static final String CASE_APPROVAL_TIME_UNIT_MONTH = 'Months';
    public static final String CASE_APPROVAL_TIME_UNIT_DAYS = 'Days';
    public static final String CaseType = 'Case_Type__c';
    public static final String DIN = 'DIN__c';    
    public static final String EDRD_ACR_ROLES_CHAIR = 'Chair';
    public static final String EDRD_ACR_ROLES_REVIEWER = 'Reviewer';
    public static final String EDRD_ACR_ROLES_VICE_CHAIR = 'Vice Chair';  
    public static final String EDRD_BUSINESS_SC_ACCOUNT = 'Subcommittee';
    public static final String EDRD_BUSINESS_AC_ACCOUNT = 'Advisory Committee';
    public static final String EDRD_CASE_CLOSER_REASON_PATIENT_DECEASED = 'Patient Deceased';
    public static final String EDRD_CASE_MOHFUNDING_DENIED = 'Denied';
    public static final String EDRD_CASE_STATUS_CANCELLED = 'Cancelled';
    public static final String EDRD_CASE_STATUS_FUNDING_APPROVED = 'Funding Approved';
    public static final String EDRD_COMMITTEE_REVIEWER = 'Committee_Reviewer';
    public static final String EDRD_FORMULATION_BOTTLE = 'Bottle';
    public static final String EDRD_FUNDING_DECISION_DENIED = 'Denied';
    public static final String EDRD_NAME = 'EDRD';
    public static final String EDRD_PERSONACCOUNT_SC = 'EDRD Sub Committee';
    public static final String EDRD_PERSONACCOUNT_SC_METABOLIC_SUBCOMMITTEE = 'Metabolic Subcommittee';
    public static final String EDRD_PERSONACCOUNT_AC = 'EDRD Advisory Committee';
    public static final String EDRD_PERSONACCOUNT_ACSC = 'EDRD Advisory/ Sub Committee';
    public static final String EDRD_PHYSICIAN = 'Physician';
    public static final String EDRD_PRESCRIBER_COMMUNITY_USER = 'EDRD Prescriber Community User';
    public static final String EDRD_PROVIDER = 'Provider';
    public static final String EDRD_Inactive = 'Inactive';
    public static final String EDRD_Active = 'Active';
    public static final String EDRD_Success = 'Success';
    public static final String EMPICreated = 'EMPICreated';
    public static final String EMPICreatedRenewal = 'EMPICreatedRenewal';
    public static final String EMPISearchRenewal = 'EMPISearchRenewal';
    public static final String EMPICreatedNew = 'EMPICreatedNew';
    public static final String ExcludedPlans = 'Excluded_Plans__c'; 
    public static final String FundingApproved = 'Funding Approved';    
    public static final String IndicationName = 'Indication_Name__c';
    public static final String JustificationCode = 'Justification_Code__c';    
    public static final String ManullyCreated = 'manullyCreated'; 
    public static final String MaxDaysSupply = 'Max_Days_Supply__c';   
    public static final String MaxPricePercent = 'Max_Price_Percent__c'; 
    public static final String MedicationName = 'Medication_Name__c';
    public static final String MedName = 'Med_Name__c';
    public static final String NewSearch = 'NewSearch';   
    public static final Id PatientRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Patient').getRecordTypeId();
    public static final String PharmaNetPayloads = 'PharmaNet_Payloads' ;
    public static final String RenewalSFSearch = 'RenewalSFSearch';
    public static final String RDPCode = 'RDP_Code__c';
    public static final String SAType = 'SA_Type__c';
   
}