/**********************************************************************************************
* @Author:      Accenture 
* @Date:        07 Jan 2025
* @Description: The purpose of this class is to get Assessment Response Summary based on AssessmentId.
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]
                07 Jan -  EDRD-1112         -  Accenture   - method is to return sessionId
***********************************************************************************************/
public with sharing class EDRD_cls_AssessmentResponseService {
    private static final String ENDPOINT = '/services/data/v56.0/actions/standard/getAssessmentResponseSummary';
/**
* @author: Deepak
* @date: 07 Jan 2025
* @description: The purpose of this method is to return sessionId.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/     
    public static String getUserSessionId(){
        String sessionId = '';
        // Refer to the Page
        PageReference reportPage = Page.EDRD_vf_SessionId;
        // Get the content of the VF page
        String vfContent = !test.isRunningTest() ? reportPage.getContent().toString() : '';
        
        // Find the position of Start_Of_Session_Id and End_Of_Session_Id
        Integer startP = vfContent.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length(),
            endP = vfContent.indexOf('End_Of_Session_Id');
        // Get the Session Id
        sessionId = !test.isRunningTest() ? vfContent.substring(startP, endP) : 'ABC';
        // Return Session Id
        return sessionId;
    }
 
/**
* @author: Deepak
* @date: 07 Jan 2025
* @description: The purpose of this method is to return string of Assessment response summary.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/  
    @auraEnabled
    public static String getAssessmentResponseSummary(String assessmentId) {
        String responseBody = '';
        String mockResponse = '[]';
        Map<String, String> keyVsValue = new Map<String, String>();
        Map<String, List<String>> mainHeadingVsHeadingList = new Map<String, List<String>>();
        // Validate input
        if (String.isBlank(assessmentId)) {
            throw new IllegalArgumentException('Assessment ID cannot be blank');
        }
        
        // Construct the HTTP request
        HttpRequest req = new HttpRequest();
        req.setEndpoint(System.Url.getOrgDomainUrl().toExternalForm() + ENDPOINT);
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + getUserSessionId());
        req.setHeader('Content-Type', 'application/json');
        
        // Create the payload
        EDRD_cls_Payload p = new EDRD_cls_Payload();
        EDRD_cls_Payload.cls_inputs c = new EDRD_cls_Payload.cls_inputs();
        c.assessmentId = assessmentId;
        p.inputs = new List<EDRD_cls_Payload.cls_inputs>{c};
        req.setBody(JSON.serialize(p));
        
        // Send the request
        Http http = new Http();
        HttpResponse res;
        if(!test.isRunningTest()){
            res = http.send(req);
        }else{
            res= new HttpResponse();
            res.setStatusCode(200);
            res.setBody(mockResponse);
        }
        
        // Parse and return the response
        if (res.getStatusCode() == 200) {
            responseBody = res.getBody().removeEnd(']').removeStart('['); 
            keyVsValue.put('Response', responseBody);
        } else {
            throw new CalloutException('HTTP Error: ' + res.getStatusCode() + ' - ' + res.getBody());
        }
        List<Assessment_Summary_Mapping__mdt> aSMList = Assessment_Summary_Mapping__mdt.getAll().values();
        for(Assessment_Summary_Mapping__mdt aSMObj: aSMList){
            if(!mainHeadingVsHeadingList.ContainsKey(aSMObj.Drug_Main_Heading__c)){
                mainHeadingVsHeadingList.put(aSMObj.Drug_Main_Heading__c, new List<String>());
            }            
            mainHeadingVsHeadingList.get(aSMObj.Drug_Main_Heading__c).add(aSMObj.Heading__c);
        }
        keyVsValue.put('headingList', JSON.serialize(mainHeadingVsHeadingList));
        
        return JSON.serialize(keyVsValue);
    }    
}