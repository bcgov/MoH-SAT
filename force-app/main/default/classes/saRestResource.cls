@RestResource(urlMapping='/SA/*')
global with sharing class saRestResource {
    // Class for exposing API interface on Special Authority Cases
    // POST: Incoming from eForms
    // GET: Check on status of SA
    // @HttpGet
    // global static SAResponse doGet() {
    //     RestRequest req = RestContext.request;
    //     System.debug('Incoming GET SA request');
    //     System.debug(req);
    //     // TODO: Get an SA status and return it
    //     SAResponse sar = new SAResponse();
    //     sar.status = 'Approved';
    //     return sar;
    // }

    @HttpPost
    global static EFormResponse doPost() {
        RestRequest req = RestContext.request;
        system.debug(req.params);
        system.debug(req.requestBody.toString());
        // Process the incoming data and return a CaseID
        EFormResponse eformResponse = new EFormResponse();
        String hexString = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(DateTime.now().getTime().format())));
        eformResponse.guid = hexString.SubString(0,8)
                           + '-' + hexString.SubString(8,12)
                           + '-' + hexString.SubString(12,16)
                           + '-' + hexString.SubString(16,20)
                           + '-' + hexString.substring(20);
        return eformResponse;
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
