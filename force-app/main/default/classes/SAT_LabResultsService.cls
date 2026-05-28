public with sharing class SAT_LabResultsService {

    private static Integration_Log__c createLog(String message, Integer code, Id caseId) {
        final Integer MAX_LENGTH = 255;
    
        if (String.isNotBlank(message) && message.length() > MAX_LENGTH) {
            message = message.substring(0, MAX_LENGTH - 3) + '...';
        }
        Integration_Log__c log = new Integration_Log__c(
            Message__c = message,
            Type__c = 'PLIS Lab Data',
            Code__c = code,
            SA_Request__c = caseId
        );
        insert log;
        return log;
    }

    public class LabResultDTO {
        @AuraEnabled public String test;
        @AuraEnabled public Datetime observationDateTime;
        @AuraEnabled public String value;
        @AuraEnabled public String unit;
        @AuraEnabled public String referenceRangeTxt;
        @AuraEnabled public String abnormalFlagCd;
        @AuraEnabled public String coding;

        public LabResultDTO(
            String test,
            Datetime observationDateTime,
            String value,
            String unit,
            String referenceRangeTxt,
            String abnormalFlagCd,
            String coding
        ) {
            this.test = test;
            this.observationDateTime = observationDateTime;
            this.value = value;
            this.unit = unit;
            this.referenceRangeTxt = referenceRangeTxt;
            this.abnormalFlagCd = abnormalFlagCd;
            this.coding = coding;
        }
    }

    @AuraEnabled(cacheable=true)
    public static String getCurrentUser() {
        User currentUser = [
            SELECT Id, LastName 
            FROM User 
            WHERE Id = :UserInfo.getUserId() 
            LIMIT 1
        ];
        return currentUser.LastName;
    }

    @AuraEnabled(cacheable=false)
    public static List<LabResultDTO> getLabResults(
        String caseId,
        String testType,
        String asOfDate,
        String requester
    ) {
        List<LabResultDTO> results = new List<LabResultDTO>();

        try {
            // Query Case to get Patient_Identifier__c
            Case caseRecord = [
                SELECT Id, Patient_Identifier__c 
                FROM Case 
                WHERE Id = :caseId 
                LIMIT 1
            ];

            String personalHealthNumber = caseRecord.Patient_Identifier__c;

            // Validate required fields
            if (String.isBlank(personalHealthNumber)) {
                createLog('Error: Patient Identifier is missing from Case', 400, caseId);
                throw new AuraHandledException('Patient Identifier is missing from the Case record.');
            }

            if (String.isBlank(testType)) {
                createLog('Error: Test Type is required', 400, caseId);
                throw new AuraHandledException('Test Type is required.');
            }

            if (String.isBlank(asOfDate)) {
                createLog('Error: As Of Date is required', 400, caseId);
                throw new AuraHandledException('As Of Date is required.');
            }

            if (String.isBlank(requester)) {
                createLog('Error: Requester is required', 400, caseId);
                throw new AuraHandledException('Requester is required.');
            }

            System.debug('PHN: ' + personalHealthNumber);
            System.debug('testType: ' + testType);
            System.debug('asOfDate: ' + asOfDate);
            System.debug('requester: ' + requester);

            String accessToken = AzureAuthService.getAccessToken();

            String endpoint = Label.SAT_Lab_Result_Endpoint;//'https://moh-dms-m-sit-api.azure-api.net/api/plissit/getResults';

            Map<String, Object> bodyMap = new Map<String, Object>{
                'requester' => requester,
                'personalHealthNumber' => personalHealthNumber,
                'testType' => testType,
                'asOfDate' => asOfDate
            };

            System.debug('REQUEST BODY: ' + JSON.serializePretty(bodyMap));

            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', 'Bearer ' + accessToken);
            req.setBody(JSON.serialize(bodyMap));
            req.setTimeout(120000);

            Http http = new Http();
            HttpResponse res = http.send(req);

            System.debug('STATUS CODE: ' + res.getStatusCode());
            System.debug('RESPONSE BODY: ' + res.getBody());

            if (res.getStatusCode() == 200) {
                Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                Map<String, Object> content = (Map<String, Object>) parsed.get('content');

                if (content != null && (Boolean) content.get('success')) {
                    List<Object> plisData = (List<Object>) content.get('plisData');

                    if (plisData != null && !plisData.isEmpty()) {
                        for (Object rowObj : plisData) {
                            Map<String, Object> row = (Map<String, Object>) rowObj;

                            Datetime obsDateTime = null;
                            String dt = (String) row.get('observationDateTime');
                            if (dt != null) {
                                obsDateTime = Datetime.valueOf(dt.replace('T', ' '));
                            }

                            String refRange = (String) row.get('referenceRangeTxt');
                            if (String.isNotBlank(refRange)) {
                                refRange = refRange
                                    .replace('&lt;', '<')
                                    .replace('&gt;', '>')
                                    .replace('&amp;', '&')
                                    .replace('&quot;', '"')
                                    .replace('&#39;', '\'');
                            }

                            results.add(new LabResultDTO(
                                testType,
                                obsDateTime,
                                String.valueOf(row.get('value') != null ? row.get('value') : row.get('observationValue')),
                                (String) row.get('unit'),
                                refRange,
                                (String) row.get('abnormalFlagCd'),
                                String.valueOf(row.get('observationTypeCd')) + ' / ' + (String) row.get('loincGroup')
                            ));
                        }
                        createLog('Success - Retrieved ' + results.size() + ' lab results by ' + requester, 200, caseId);
                    } else {
                        createLog('No data found for the given criteria - Requester: ' + requester, 204, caseId);
                    }
                } else {
                    createLog('API returned unsuccessful response', 400, caseId);
                    throw new AuraHandledException('Unable to retrieve lab results. Please try again.');
                }
            } else {
                createLog('HTTP Error: ' + res.getStatus(), res.getStatusCode(), caseId);
                throw new AuraHandledException('HTTP Error: ' + res.getStatus());
            }

        } catch (QueryException qe) {
            createLog('QueryException: ' + qe.getMessage(), 404, null);
            throw new AuraHandledException('Case record not found.');
        } catch (AuraHandledException ahe) {
            throw ahe;
        } catch (Exception e) {
            createLog('Exception: ' + e.getMessage(), 500, null);
            throw new AuraHandledException(e.getMessage());
        }

        return results;
    }
}