@RestResource(urlMapping='/SA/*')
global with sharing class SaRestApi {
    @HttpPost
    global static EForm.Bundle doPost() {
        RestRequest req = RestContext.request;
        
        Eform.Bundle bundle = EformParser.parse(req.requestBody.toString());

        SarBuilder.build(bundle);
        
        return bundle;
    }

    @HttpGet
    global static PhnSars doGet() {
        RestRequest req = RestContext.request;
        system.debug(req.params.get('phn'));
        system.debug(req.requestBody.toString());
        
        PhnSars payload = new PhnSars();
        payload.items = new List<Sar>();

        for (Case c : [select CaseNumber, Status, Drug_Name__c, CreatedDate from Case]) {
            Sar sar = new Sar(c);
            sar.sampleInt = 10;
            sar.sampleDouble = 10.50;
            sar.sampleDateField = Date.today();
            sar.sampleBoolean = false;
            payload.items.add(sar);
        }

        return payload;
    }
    
    global class PhnSars {
        List<Sar> items { get; set; }
    }

    global class Sar {
        String caseNumber { get; set; }
        String status { get; set; }
        String drugName { get; set; }
        Datetime requestedDate { get; set; }
        Date sampleDateField { get; set; }
        Integer sampleInt { get; set; }
        Double sampleDouble { get; set; }
        Boolean sampleBoolean { get; set; }

        global Sar(Case c) {
            this.caseNumber = c.CaseNumber;
            this.status = c.Status;
            this.drugName = c.Drug_Name__c;
            this.requestedDate = c.CreatedDate;
        }
    }
}
