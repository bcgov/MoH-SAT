/**********************************************************************************************
* @Author:      Deepak 
* @Date:        23/02/2023
* @Description: The purpose of this class is to have constant values to be reffered by main class
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
***********************************************************************************************/

public class ESA_cls_constants {
    
    public static final String CASE_APPROVAL_TIME_UNIT_WEEK = 'Weeks';
    public static final String CASE_APPROVAL_TIME_UNIT_MONTH = 'Months';
    public static final String CASE_APPROVAL_TIME_UNIT_DAYS = 'Days';
    public static final String EDRD_BUSINESS_SC_ACCOUNT = 'Subcommittee';
    public static final String EDRD_BUSINESS_AC_ACCOUNT = 'Advisory Committee';
    public static final String EDRD_CASE_CLOSER_REASON_PATIENT_DECEASED = 'Patient Deceased';
    public static final String EDRD_CASE_MOHFUNDING_DENIED = 'Denied';
    public static final String EDRD_CASE_STATUS_CANCELLED = 'Cancelled';
    public static final String EDRD_CASE_STATUS_FUNDING_APPROVED = 'Funding Approved';
    public static final String EDRD_FORMULATION_BOTTLE = 'Bottle';
    public static final String EDRD_FUNDING_DECISION_DENIED = 'Denied';
    public static final String EDRD_NAME = 'EDRD';
    public static final String EDRD_PERSONACCOUNT_SC = 'EDRD Sub Committee'; 
    public static final String EDRD_PERSONACCOUNT_AC = 'EDRD Advisory Committee';
    public static final String EDRD_PERSONACCOUNT_ACSC = 'EDRD Advisory/ Sub Committee';
    public static final String EDRD_PHYSICIAN = 'Physician';
    public static final String EDRD_PRESCRIBER_COMMUNITY_USER = 'EDRD Prescriber Community User';
    public static final String EDRD_PROVIDER = 'Provider';
    public static final Id PatientRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Patient').getRecordTypeId();
    public static final String ManullyCreated = 'manullyCreated';
    public static final String EMPICreated = 'EMPICreated';   
}