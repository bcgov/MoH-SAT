### Certificates setup for ODR Connection

General configuration steps:
* Setup a Named Credential
* Create a self-signed cert
* Secure access to PFX file from ODR
* PFX to JKS conversion
* Import JKS
* Configure Named Credential Certificate
* Enable Identity Provider
* Testing

### Setup a Named Credential:

Best practise in salesforce is to make authenticated calls from within Apex to external services using a named credential.  This simplifies the connection handshake and allows your Apex code to be cleaner and portable to other orgs/environments.

Follow detailed instructions [here](https://help.salesforce.com/articleView?id=named_credentials_about.htm)

### Create a self-signed cert:

1. From Setup, search for Certificate and Key Management in the Quick Find box.
2. Select Create Self-Signed Certificate.
3. Enter a descriptive label for the Salesforce certificate.
4. Enter a unique name.
5. Select a key size for your generated certificate and keys.
6. Click Save

Now your Salesforce org is able to Import a JKS file (it won't be able until this step)

More detailed instructions [here](https://help.salesforce.com/articleView?id=security_keys_creating.htm)

### Secure access to PFX file from ODR:

Make sure you receive the PFX certificate file and it's password securely from the ODR custodian.

### PFX to JKS conversion:

Salesforce does not support PFX, but JKS (Java Key Store).  You must first convert it to JKS before importing it in setup.

Make sure you have keytool command line utility from Java installed.  OSX will have this natively installed in the terminal.

In order to convert the PFX file correctly, you need to obtain the source alias used for the certiicate.  To obtain that, run the following command:

`keytool -list -keystore <your file name here>.pfx -storetype pkcs12`

The output will be similar to the following:

```Enter keystore password:  
Keystore type: PKCS12
Keystore provider: SUN

Your keystore contains 1 entry

MyCertificateAlias, Nov. 3, 2020, PrivateKeyEntry, 
Certificate fingerprint (SHA-256): CF:80:A2:59:16:FC:FE:8A:D6:5A:7B:AF:80:A8:22:09:89:8A:DF:52:61:20:DB:71:26:12:36:D4:14:88:9D:C1
```

In the case above, the alias is `MyCertificateAlias`.

You can now use that alias and generate the JKS file.  It will ask you for the passphrase to use for encrypting the key and the passphrase of the pfx file.  Use the same password for encrypting as decrypting.

`keytool -importkeystore -srckeystore <your cert file name here>.pfx -destkeystore keystorefile.jks -srcstoretype pkcs12 -deststoretype jks -destalias <name_your_certificate_here> -srcalias MyCertificateAlias`

This will generate a file called `keystorefile.jks`.

### Import JKS:

You can now load the `keystorefile.jks` file created above into *Certificate and Key Management* in Salesforce Setup.  Click the `Import from Keystore` button and select the jks file and put in the password you used in the above step.

### Add Cert to Named Credential:

Make sure to go back to the named credential you configured in the first step, and select the cert you just created.

### Enable Identity Provider

In Salesforce, go to Setup -> Identity -> Identity Provider -> Enable.  Select the certificate you named when importing the JKS.

### Testing

At this point, your SSL cert and named credential should be linked up, and you will be able to call your named credential in Apex code easily.  See below for an example:

```
HttpRequest req = new HttpRequest();
req.setEndpoint('callout:My_ORD_Named_Credential/path/to/endpoint');
req.setMethod('GET');
Http http = new Http();
HTTPResponse res = http.send(req);
System.debug(res.getBody());
```