public class AzureAuthService {

    public static String getAccessToken() {

        String tenantId = Label.Azure_Tenant_Id;
        String clientId = Label.Azure_Client_Id;
        String scope = Label.Azure_Scope;

        String tokenEndpoint =
            'https://login.microsoftonline.com/' +
            tenantId +
            '/oauth2/v2.0/token';

        // Create JWT
        String jwt = createJWT(clientId, tokenEndpoint);

        HttpRequest req = new HttpRequest();
        req.setEndpoint(tokenEndpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');

        String body = 'grant_type=client_credentials'
            + '&client_id=' + EncodingUtil.urlEncode(clientId, 'UTF-8')
            + '&scope=' + EncodingUtil.urlEncode(scope, 'UTF-8')
            + '&client_assertion_type=' + EncodingUtil.urlEncode(
                'urn:ietf:params:oauth:client-assertion-type:jwt-bearer',
                'UTF-8'
            )
            + '&client_assertion=' + EncodingUtil.urlEncode(jwt, 'UTF-8');

        req.setBody(body);

        Http http = new Http();
        HttpResponse res = http.send(req);

        System.debug('Status: ' + res.getStatus());
        System.debug('Response: ' + res.getBody());

        Map<String, Object> result =
            (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

        return (String) result.get('access_token');
    }

    private static String createJWT(String clientId, String audience) {

        Long now = DateTime.now().getTime() / 1000;

        String thumbprint = Label.Azure_Thumbprint;

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

        String encodedHeader =
            base64UrlEncode(Blob.valueOf(header));

        String encodedClaims =
            base64UrlEncode(
                Blob.valueOf(JSON.serialize(claims))
            );

        String unsignedToken =
            encodedHeader + '.' + encodedClaims;

        Blob signature = Crypto.signWithCertificate(
            'RSA-SHA256',
            Blob.valueOf(unsignedToken),
            Label.Azure_Certificate_Name
        );

        String encodedSignature =
            base64UrlEncode(signature);

        return unsignedToken + '.' + encodedSignature;
    }

    private static String base64UrlEncode(Blob input) {

        String base64 =
            EncodingUtil.base64Encode(input);

        base64 = base64.replace('+', '-');
        base64 = base64.replace('/', '_');
        base64 = base64.replace('=', '');

        return base64;
    }
}