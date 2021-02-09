@RestResource(urlMapping='/SA/*')
global with sharing class SaRestApi {
    @HttpPost
    global static EForm.Bundle doPost() {
        RestRequest req = RestContext.request;
        
        Eform.Bundle bundle = EformParser.parse(req.requestBody.toString());

        SpecialAuthorityRequest sar = SarBuilder.build(bundle);
        
        sar.save();
        
        return bundle;
    }

    @HttpGet
    global static HealthGateway.SaList doGet() {
        RestRequest req = RestContext.request;

        String patientIdentifier = req.params.get('phn');
        
        HealthGateway.SaList payload = new HealthGateway.SaList();
        payload.items = new List<HealthGateway.SaItem>();

        for (Case c : queryCases(req.params.get('phn'))) {
            payload.items.add(new HealthGateway.SaItem(c));
        }

        return payload;
    }

    private static List<Case> queryCases(String patientIdentifier) {
        return [
            select
                Contact.Patient_Identifier__c, Contact.FirstName, Contact.LastName,
                Provider__r.FirstName, Provider__r.LastName,
                Drug__r.Brand_Drug_Name__c,
                Status, CaseNumber, CreatedDate, Effective_Date__c, Termination_Date__c
            from Case
            where Contact.Patient_Identifier__c = :patientIdentifier
        ];
    }
}
