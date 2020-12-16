public class PrescriptionHistoryResponse {

	public class PrescriberInfo {
		@AuraEnabled public PaymentAddress paymentAddress {get;set;} 
		@AuraEnabled public String licenseNo {get;set;} 
		@AuraEnabled public String code {get;set;} 
		@AuraEnabled public String phoneNumber {get;set;} 
		@AuraEnabled public String name {get;set;} 
		@AuraEnabled public String faxNumber {get;set;} 
	}
	
	public class MedRecords {
		@AuraEnabled public Integer rxNumber {get;set;} 
		@AuraEnabled public Integer quantity {get;set;} 
		@AuraEnabled public Integer refills {get;set;} 
		@AuraEnabled public Integer dinpin {get;set;} 
		@AuraEnabled public String directions {get;set;} 
		@AuraEnabled public String drugStrength {get;set;} 
		@AuraEnabled public String genericName {get;set;} 
		@AuraEnabled public Integer daysSupply {get;set;} 
		@AuraEnabled public String dateDispensed {get;set;} 
		@AuraEnabled public PrescriberInfo prescriberInfo {get;set;} 
		@AuraEnabled public String rxStatus {get;set;} 
		@AuraEnabled public DispensingPharmacy dispensingPharmacy {get;set;} 
	}
	
	public class PaymentAddress {
		@AuraEnabled public String country {get;set;} 
		@AuraEnabled public String province {get;set;} 
		@AuraEnabled public String city {get;set;} 
		@AuraEnabled public String addrLine1 {get;set;} 
		@AuraEnabled public String postalCode {get;set;} 
	}
	
	public class DispensingPharmacy {
		@AuraEnabled public String pharmacyId {get;set;} 
		@AuraEnabled public String phoneNumber {get;set;} 
		@AuraEnabled public String name {get;set;} 
		@AuraEnabled public String faxNumber {get;set;} 
		@AuraEnabled public PaymentAddress siteAddress {get;set;} 
	}
	
	public class MedHistory {
		@AuraEnabled public Integer totalRecords {get;set;} 
		@AuraEnabled public Integer totalPages {get;set;} 
		@AuraEnabled public List<MedRecords> medRecords {get;set;} 
	}

	public class Comment {
		@AuraEnabled public String dateEntered {get;set;}
		@AuraEnabled public String practitionerName {get;set;}
		@AuraEnabled public String text {get;set;}
		@AuraEnabled public String practitionerRefId {get;set;}
		@AuraEnabled public String practitionerId {get;set;}
	}

	public class AdverseReactions {
		@AuraEnabled public Integer dinpin {get;set;}
		@AuraEnabled public String drugStrength {get;set;}
		@AuraEnabled public String genericName {get;set;}
		@AuraEnabled public String doseForm {get;set;}
		@AuraEnabled public String dateReported {get;set;}
		@AuraEnabled public Comment comment {get;set;}
		@AuraEnabled public String reportedBy {get;set;}

	}

	@AuraEnabled public String clientName {get;set;}
	@AuraEnabled public String requestUUID {get;set;}
	@AuraEnabled public MedHistory medHistory {get;set;}
	@AuraEnabled public List<AdverseReactions> adverseReactions {get;set;}
	@AuraEnabled public CalloutResponse error {get;set;}
}