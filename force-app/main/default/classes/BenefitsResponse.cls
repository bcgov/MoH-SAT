public class BenefitsResponse {

	public class PlanIExpenditure {
		@AuraEnabled public String amount {get;set;}
		@AuraEnabled public String year {get;set;}
	}

	public class PlanEligibility {
		@AuraEnabled public String terminationDate {get;set;}
		@AuraEnabled public String authorityCode {get;set;}
		@AuraEnabled public String authorityValue {get;set;}
		@AuraEnabled public String authorityDesc {get;set;}
		@AuraEnabled public String effectiveDate {get;set;}
    }

    public class PRACRestricts {
        @AuraEnabled public String terminationDate {get;set;}
        @AuraEnabled public String practitionerName {get;set;}
        @AuraEnabled public String practitionerDesc {get;set;}
        @AuraEnabled public String pracitionerId {get;set;}
        @AuraEnabled public String effectiveDate {get;set;}
        @AuraEnabled public String pracitionerRefId {get;set;}
    }

    public class PharmRestricts {
		@AuraEnabled public String terminationDate {get;set;}
		@AuraEnabled public String pharmacyId {get;set;}
		@AuraEnabled public String pharmacyName {get;set;}
		@AuraEnabled public String effectiveDate {get;set;}
    }

    public class RestrctedClaimant {
		@AuraEnabled public List<PRACRestricts> pracRestricts {get;set;}
		@AuraEnabled public List<PharmRestricts> pharmRestricts {get;set;}
	}

	@AuraEnabled public String clientName {get;set;}
	@AuraEnabled public String requestUUID {get;set;}
  @AuraEnabled public PlanIExpenditure planIExpenditure {get;set;}
	@AuraEnabled public List<PlanEligibility> planEligibility {get;set;}
	@AuraEnabled public RestrctedClaimant restrictedClaimant {get;set;}
	@AuraEnabled public CalloutResponse error {get;set;}
}