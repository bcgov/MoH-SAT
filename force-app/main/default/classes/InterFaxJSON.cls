public with sharing class InterFaxJSON {

    public class OutboundFaxDetail {

    public String submitTime {get;set;} 
    public Object contact {get;set;} 
    public String destinationFax {get;set;} 
    public String replyEmail {get;set;} 
    public Object subject {get;set;} 
    public Integer pagesSubmitted {get;set;} 
    public String senderCSID {get;set;} 
    public Integer attemptsToPerform {get;set;} 
    public String pageSize {get;set;} 
    public String pageResolution {get;set;} 
    public String pageOrientation {get;set;} 
    public String rendering {get;set;} 
    public Object pageHeader {get;set;} 
    public String userId {get;set;} 
    public Integer pagesSent {get;set;} 
    public String completionTime {get;set;} 
    public Object remoteCSID {get;set;} 
    public Integer duration {get;set;} 
    public Integer priority {get;set;} 
    public Integer units {get;set;} 
    public Double costPerUnit {get;set;} 
    public Integer attemptsMade {get;set;} 
    public Integer id1 {get;set;} 
    public String uri {get;set;} 
    public Integer status {get;set;} 
    
    public OutboundFaxDetail(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'submitTime') {
                        submitTime = parser.getText();
                    } else if (text == 'contact') {
                        contact = parser.getText();
                    } else if (text == 'destinationFax') {
                        destinationFax = parser.getText();
                    } else if (text == 'replyEmail') {
                        replyEmail = parser.getText();
                    } else if (text == 'subject') {
                        subject = parser.getText();
                    } else if (text == 'pagesSubmitted') {
                        pagesSubmitted = parser.getIntegerValue();
                    } else if (text == 'senderCSID') {
                        senderCSID = parser.getText();
                    } else if (text == 'attemptsToPerform') {
                        attemptsToPerform = parser.getIntegerValue();
                    } else if (text == 'pageSize') {
                        pageSize = parser.getText();
                    } else if (text == 'pageResolution') {
                        pageResolution = parser.getText();
                    } else if (text == 'pageOrientation') {
                        pageOrientation = parser.getText();
                    } else if (text == 'rendering') {
                        rendering = parser.getText();
                    } else if (text == 'pageHeader') {
                        pageHeader = parser.getText();
                    } else if (text == 'userId') {
                        userId = parser.getText();
                    } else if (text == 'pagesSent') {
                        pagesSent = parser.getIntegerValue();
                    } else if (text == 'completionTime') {
                        completionTime = parser.getText();
                    } else if (text == 'remoteCSID') {
                        remoteCSID = parser.getText();
                    } else if (text == 'duration') {
                        duration = parser.getIntegerValue();
                    } else if (text == 'priority') {
                        priority = parser.getIntegerValue();
                    } else if (text == 'units') {
                        units = parser.getIntegerValue();
                    } else if (text == 'costPerUnit') {
                        costPerUnit = parser.getDoubleValue();
                    } else if (text == 'attemptsMade') {
                        attemptsMade = parser.getIntegerValue();
                    } else if (text == 'id') {
                        id1 = parser.getIntegerValue();
                    } else if (text == 'uri') {
                        uri = parser.getText();
                    } else if (text == 'status') {
                        status = parser.getIntegerValue();
                    } else {
                        //System.debug(LoggingLevel.WARN, 'OutboundFaxDetail consuming unrecognized property: '+text);
                        consumeObject(parser);
                    }
                }
            }
        }
    }
    
    }
    
    
    public static List<OutboundFaxDetail> parseOutboundFaxDetail(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return arrayOfOutboundFaxDetail(parser);
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
    

    private static List<OutboundFaxDetail> arrayOfOutboundFaxDetail(System.JSONParser p) {
        List<OutboundFaxDetail> res = new List<OutboundFaxDetail>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new OutboundFaxDetail(p));
        }
        return res;
    }

    public class InboundFaxDetail {

    public String userId {get;set;} 
    public Integer messageId {get;set;} 
    public String phoneNumber {get;set;} 
    public String remoteCSID {get;set;} 
    public Integer messageStatus {get;set;} 
    public Integer pages {get;set;} 
    public Integer messageSize {get;set;} 
    public Integer messageType {get;set;} 
    public String receiveTime {get;set;} 
    public String callerId {get;set;} 
    public Integer recordingDuration {get;set;} 
    public String imageStatus {get;set;} 
    public Integer numOfEmails {get;set;} 
    public Integer numOfFailedEmails {get;set;} 

    public InboundFaxDetail(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'userId') {
                        userId = parser.getText();
                    } else if (text == 'messageId') {
                        messageId = parser.getIntegerValue();
                    } else if (text == 'phoneNumber') {
                        phoneNumber = parser.getText();
                    } else if (text == 'remoteCSID') {
                        remoteCSID = parser.getText();
                    } else if (text == 'messageStatus') {
                        messageStatus = parser.getIntegerValue();
                    } else if (text == 'pages') {
                        pages = parser.getIntegerValue();
                    } else if (text == 'messageSize') {
                        messageSize = parser.getIntegerValue();
                    } else if (text == 'messageType') {
                        messageType = parser.getIntegerValue();
                    } else if (text == 'receiveTime') {
                        receiveTime = parser.getText();
                    } else if (text == 'callerId') {
                        callerId = parser.getText();
                    } else if (text == 'recordingDuration') {
                        recordingDuration = parser.getIntegerValue();
                    } else if (text == 'imageStatus') {
                        imageStatus = parser.getText();
                    } else if (text == 'numOfEmails') {
                        numOfEmails = parser.getIntegerValue();
                    } else if (text == 'numOfFailedEmails') {
                        numOfFailedEmails = parser.getIntegerValue();
                    } else {
                        System.debug(LoggingLevel.WARN, 'InboundFaxDetail consuming unrecognized property: '+text);
                        consumeObject(parser);
                    }
                }
            }
        }
    }
    }
    
    
    public static List<InboundFaxDetail> parseInboundFaxDetail(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return arrayOfInboundFaxDetail(parser);
    }
    
    

    private static List<InboundFaxDetail> arrayOfInboundFaxDetail(System.JSONParser p) {
        List<InboundFaxDetail> res = new List<InboundFaxDetail>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new InboundFaxDetail(p));
        }
        return res;
    }

    public class FaxErrorDetail {
        public String errorCode {get;set;}
        public String errorMessage {get;set;}

        public FaxErrorDetail(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'code') {
                            errorCode = parser.getText();
                        } else if (text == 'message') {
                            errorMessage = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'FaxErrorDetail consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
        
        public static List<FaxErrorDetail> parseFaxErrorDetails(String json) {
            System.JSONParser parser = System.JSON.createParser(json);
            return arrayOfFaxErrorDetails(parser);
        }        
    
        private static List<FaxErrorDetail> arrayOfFaxErrorDetails(System.JSONParser p) {
            List<FaxErrorDetail> res = new List<FaxErrorDetail>();
            if (p.getCurrentToken() == null) p.nextToken();
            while (p.nextToken() != System.JSONToken.END_ARRAY) {
                res.add(new FaxErrorDetail(p));
            }
            return res;
        }


    }