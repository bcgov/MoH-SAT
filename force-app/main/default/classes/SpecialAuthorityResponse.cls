public class SpecialAuthorityResponse {

	public class PresciberInfo {
		@AuraEnabled public PaymentAddress paymentAddress {get;set;} 
		@AuraEnabled public String licenseNo {get;set;} 
		@AuraEnabled public String code {get;set;} 
		@AuraEnabled public String phoneNumber {get;set;} 
		@AuraEnabled public String name {get;set;} 
		@AuraEnabled public String faxNumber {get;set;} 

		public PresciberInfo(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'paymentAddress') {
							paymentAddress = new PaymentAddress(parser);
						} else if (text == 'licenseNo') {
							licenseNo = parser.getText();
						} else if (text == 'code') {
							code = parser.getText();
						} else if (text == 'phoneNumber') {
							phoneNumber = parser.getText();
						} else if (text == 'name') {
							name = parser.getText();
						} else if (text == 'faxNumber') {
							faxNumber = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'PresciberInfo consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
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
		@AuraEnabled public PresciberInfo presciberInfo {get;set;} 
		@AuraEnabled public String rxStatus {get;set;} 
		@AuraEnabled public DispensingPharmacy dispensingPharmacy {get;set;} 

		public MedRecords(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'rxNumber') {
							rxNumber = parser.getIntegerValue();
						} else if (text == 'quantity') {
							quantity = parser.getIntegerValue();
						} else if (text == 'refills') {
							refills = parser.getIntegerValue();
						} else if (text == 'dinpin') {
							dinpin = parser.getIntegerValue();
						} else if (text == 'directions') {
							directions = parser.getText();
						} else if (text == 'drugStrength') {
							drugStrength = parser.getText();
						} else if (text == 'genericName') {
							genericName = parser.getText();
						} else if (text == 'daysSupply') {
							daysSupply = parser.getIntegerValue();
						} else if (text == 'dateDispensed') {
							dateDispensed = parser.getText();
						} else if (text == 'presciberInfo') {
							presciberInfo = new PresciberInfo(parser);
						} else if (text == 'rxStatus') {
							rxStatus = parser.getText();
						} else if (text == 'dispensingPharmacy') {
							dispensingPharmacy = new DispensingPharmacy(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'MedRecords consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class PaymentAddress {
		@AuraEnabled public String country {get;set;} 
		@AuraEnabled public String province {get;set;} 
		@AuraEnabled public String city {get;set;} 
		@AuraEnabled public String addrLine1 {get;set;} 
		@AuraEnabled public String postalCode {get;set;} 

		public PaymentAddress(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'country') {
							country = parser.getText();
						} else if (text == 'province') {
							province = parser.getText();
						} else if (text == 'city') {
							city = parser.getText();
						} else if (text == 'addrLine1') {
							addrLine1 = parser.getText();
						} else if (text == 'postalCode') {
							postalCode = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'PaymentAddress consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class DispensingPharmacy {
		@AuraEnabled public String pharmacyId {get;set;} 
		@AuraEnabled public String phoneNumber {get;set;} 
		@AuraEnabled public String name {get;set;} 
		@AuraEnabled public String faxNumber {get;set;} 
		@AuraEnabled public PaymentAddress siteAddress {get;set;} 

		public DispensingPharmacy(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'pharmacyId') {
							pharmacyId = parser.getText();
						} else if (text == 'phoneNumber') {
							phoneNumber = parser.getText();
						} else if (text == 'name') {
							name = parser.getText();
						} else if (text == 'faxNumber') {
							faxNumber = parser.getText();
						} else if (text == 'siteAddress') {
							siteAddress = new PaymentAddress(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'DispensingPharmacy consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class MedHistory {
		@AuraEnabled public Integer totalRecords {get;set;} 
		@AuraEnabled public Integer totalPages {get;set;} 
		@AuraEnabled public List<MedRecords> medRecords {get;set;} 

		public MedHistory(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'totalRecords') {
							totalRecords = parser.getIntegerValue();
						} else if (text == 'totalPages') {
							totalPages = parser.getIntegerValue();
						} else if (text == 'medRecords') {
							medRecords = arrayOfMedRecords(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'MedHistory consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	@AuraEnabled public String clientName {get;set;} 
	@AuraEnabled public String requestUUID {get;set;} 
	@AuraEnabled public MedHistory medHistory {get;set;} 

	public SpecialAuthorityResponse(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'clientName') {
						clientName = parser.getText();
					} else if (text == 'requestUUID') {
						requestUUID = parser.getText();
					} else if (text == 'medHistory') {
						medHistory = new MedHistory(parser);
					} else {
						System.debug(LoggingLevel.WARN, 'SpecialAuthorityResponse consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	public static SpecialAuthorityResponse parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new SpecialAuthorityResponse(parser);
	}
	
	public static void consumeObject(System.JSONParser parser) {
		Integer depth = 0;
		do {
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT || 
				curr == System.JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == System.JSONToken.END_OBJECT ||
				curr == System.JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}
	
    private static List<MedRecords> arrayOfMedRecords(System.JSONParser p) {
        List<MedRecords> res = new List<MedRecords>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new MedRecords(p));
        }
        return res;
    }



}