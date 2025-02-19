/*-------------------------------------------------------------------
Class Name : EDRD_PharmanetWrapper
Referance Class : EDRD_Pharmanet/ESA_cls_constants
Purpose : Dispaly the data in Pharmanet.
Version : 1.0
Devloper Name : Accenture.
Date : 02/Feb/2024
-------------------------------------------------------------------------*/
public class EDRD_PharmanetWrapper {
    
    public class InputWrapper 
    {
        public String caseId {get;set;}
        public String caseType {get;set;}
        public String medicationName {get; set;}
        public String indication {get; set;}
        public String caseStatus {get;set;}
        public String practId {get; set;}
        public String phn {get; set;}
		public String terminationDate {get; set;}
        public String practitiner {get;set;}
        public String practIdRef {get; set;}
        
        public String rdp {get; set;}     
        public String excludePlan {get;set;}       
		public String decCode {get; set;}
		public Double din {get; set;}
		public String specAuthType {get; set;}
		public String justificationCodes {get; set;}
		public String excludedPlans {get; set;}
		public DateTime effectiveDate {get; set;}
        public Double maxDaysSupply {get;set;}
	    public Double maxPricePct {get;set;}
        public Id pharmaNetRecordId {get;set;}
     
    }
    public class OutputWrapper 
    {
        public String phn {get; set;}
        public String practId {get; set;}
        public String practIdRef {get; set;}
        public String rdp {get; set;}
        public String terminationDate {get; set;}
        public String practitiner {get;set;}
        public String excludePlan {get;set;}        
		public String decCode {get; set;}
		public Double din {get; set;}
		public String specAuthType {get; set;}
		public String justificationCodes {get; set;}
		public String excludedPlans {get; set;}
		public DateTime effectiveDate {get; set;}
        public Double maxDaysSupply {get;set;}
        public Double maxPricePct {get;set;}
        public Id pharmaNetRecordId {get;set;}
        public Boolean isPharmaNetSubmitSuccessfull {get;set;}
        public Boolean isSubmitSuccessful{get;set;}
       
    }
   

}