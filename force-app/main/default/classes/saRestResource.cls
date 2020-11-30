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
    global static EFormResponse doPost(EForm eForm) {
        System.debug('Incoming eForm POST');
        System.debug(eForm);
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
}
