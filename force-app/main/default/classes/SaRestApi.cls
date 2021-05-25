@RestResource(urlMapping='/SA/*')
global with sharing class SaRestApi {
    @HttpPost
    global static void doPost() {
        RestRequest req = RestContext.request;
        
        SpecialAuthorityRequest sar = new JsonSarBuilder(req.requestBody.toString()).build();
        sar.save();

        Case c = [select Id, CaseNumber from Case where Id = :sar.saCase.Id];

        RestResponse res = RestContext.response;
        res.statusCode = 201;
        res.headers.put('X-eForms-Message', postResponse(c.CaseNumber));
    }

    @HttpGet
    global static HealthGateway.SaList doGet() {
        RestRequest req = RestContext.request;

        HealthGateway.SaList payload = new HealthGateway.SaList();
        payload.items = new List<HealthGateway.SaItem>();

        String patientIdentifier = req.headers.get('phn');
        
        if (String.isBlank(patientIdentifier)) return payload;

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
            and Status in ('Received', 'Under Review', 'Approved', 'Not Approved', 'Cancelled')
        ];
    }

    private static String postResponse(String caseNumber) {
        return String.format(
            'Special Authority (SA) has received your request. Your reference number is {0}. ' + 
            'The coverage decision will be sent to the fax number entered on the eForm. ' +
            'Patients can view the status of the SA request on their Health Gateway profile.', new String[] {
            caseNumber
        });
    }
}
