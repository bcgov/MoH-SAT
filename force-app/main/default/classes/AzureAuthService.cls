public class AzureAuthService {

    @TestVisible
    private static Boolean isTest = false;

    public static String getAccessToken() {
        // Fetch config from Custom Metadata
        Azure_Config__mdt config = getConfig();

        String tokenEndpoint = 
            'https://login.microsoftonline.com/' +
            config.Tenant_Id__c +
            '/oauth2/v2.0/token';

        // Create JWT
        String jwt = createJWT(config.Client_Id__c, tokenEndpoint);

        HttpRequest req = new HttpRequest();
        req.setEndpoint(tokenEndpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');

        String body = 'grant_type=client_credentials'
            + '&client_id=' + EncodingUtil.urlEncode(config.Client_Id__c, 'UTF-8')
            + '&scope=' + EncodingUtil.urlEncode(config.Scope__c, 'UTF-8')
            + '&client_assertion_type=' + EncodingUtil.urlEncode(
                'urn:ietf:params:oauth:client-assertion-type:jwt-bearer',
                'UTF-8'
            )
            + '&client_assertion=' + EncodingUtil.urlEncode(jwt, 'UTF-8');

        req.setBody(body);

        Http http = new Http();
        HttpResponse res = http.send(req);

        Map<String, Object> result = 
            (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

        return (String) result.get('access_token');
    }

    @TestVisible
    private static String createJWT(String clientId, String audience) {
        Azure_Config__mdt config = getConfig();

        Long now = DateTime.now().getTime() / 1000;
        String thumbprint = config.Thumbprint__c;
        Blob thumbBlob = EncodingUtil.convertFromHex(thumbprint);
        String x5t = base64UrlEncode(thumbBlob);

        String header = 
            '{"alg":"RS256","typ":"JWT","x5t":"' + x5t + '"}';

        Map<String, Object> claims = new Map<String, Object>{
            'aud' => audience,
            'iss' => clientId,
            'sub' => clientId,
            'jti' => String.valueOf(Crypto.getRandomInteger()),
            'nbf' => now,
            'exp' => now + 300
        };

        String encodedHeader = base64UrlEncode(Blob.valueOf(header));
        String encodedClaims = base64UrlEncode(
            Blob.valueOf(JSON.serialize(claims))
        );

        String unsignedToken = encodedHeader + '.' + encodedClaims;

        Blob signature;
        if (Test.isRunningTest() && isTest) {
            signature = Blob.valueOf('mock_signature');
        } else {
            signature = Crypto.signWithCertificate(
                'RSA-SHA256',
                Blob.valueOf(unsignedToken),
                config.Certificate_Name__c
            );
        }

        String encodedSignature = base64UrlEncode(signature);

        return unsignedToken + '.' + encodedSignature;
    }

    @TestVisible
    private static String base64UrlEncode(Blob input) {
        String base64 = EncodingUtil.base64Encode(input);
        base64 = base64.replace('+', '-');
        base64 = base64.replace('/', '_');
        base64 = base64.replace('=', '');
        return base64;
    }

    // Helper method to fetch metadata
    private static Azure_Config__mdt getConfig() {
        return Azure_Config__mdt.getInstance('Azure_Config');
    }
}