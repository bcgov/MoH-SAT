# Certificates
## Renewing SSL Certificates
Go to Salesforce > Setup > Security Controls > Certificate and Key Management, and click the certificate record to be renewed.

Click the “Download Certificate Signing Request” button to download a .csr file.

Securely send the CSR file to the custodian of the external system. Request the custodian to return a CA-signed and renewed certificate as a .cer or .crt file. This process may take a few days.

If the custodian returns with a .cer or .crt file, go to Salesforce > Setup > Security Controls > Certificate and Key Management, and click the certificate record being renewed.

Click “Update Signed Certificate” and upload the .cer or .crt file. A successful renewal will accept the certificate with a new expiration date.

Seek help from an Salesforce or IT professional if:
- The custodian returns a signed and renewed certificate in any format other than a .cer or
.crt file.
- Salesforce does not accept the .cer or .crt file.

## PFX to JKS conversion
Follow these steps for uploading a new certificate provided in PFX format.

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

