@RestResource(urlMapping='/SA/*')
global with sharing class SaRestApi {
    @HttpPost
    global static void doPost() {
        RestRequest req = RestContext.request;
        
        SpecialAuthorityRequest sar = SarBuilder.build(req.requestBody.toString());
        sar.save();

        Case c = [select Id, CaseNumber from Case where Id = :sar.saCase.Id];

        RestResponse res = RestContext.response;
        res.statusCode = 201;
        res.headers.put('X-eForms-Message', c.CaseNumber);
    }

    @HttpGet
    global static HealthGateway.SaList doGet() {
        RestRequest req = RestContext.request;

        String patientIdentifier = req.headers.get('phn');
        
        HealthGateway.SaList payload = new HealthGateway.SaList();
        payload.items = new List<HealthGateway.SaItem>();

        for (Case c : queryCases(patientIdentifier)) {
            payload.items.add(new HealthGateway.SaItem(c));
        }

        return payload;
    }

    private static List<Case> queryCases(String patientIdentifier) {
        return [
            select
                Contact.Patient_Identifier__c, Contact.FirstName, Contact.LastName, Drug_Name__c,
                Provider__r.FirstName, Provider__r.LastName, 
                Status, CaseNumber, CreatedDate, Effective_Date__c, Termination_Date__c
            from Case
            where Contact.Patient_Identifier__c = :patientIdentifier
        ];
    }
}
