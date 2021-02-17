public with sharing class SarBuilder {
    private static Integer SORT_ORDER = 100;

    public static SpecialAuthorityRequest build(String bundleJsonStr) {
        Drug__c drug;
        Account provider;
        Account patient;
        Case saCase;
        List<Request_Detail__c> requestDetails = new List<Request_Detail__c>();
        List<ContentVersion> contentVersions = new List<ContentVersion>();

        Eform.Bundle bundle;
        
        try {
            bundle = EformParser.parse(bundleJsonStr);
        } catch (Exception e) {
            system.debug(e.getMessage());
        }

        if (bundle != null && !bundle.entry.isEmpty()) {
            for (Eform.BundleEntry bundleEntry : bundle.entry) {
                if (bundleEntry.resource instanceof Eform.Patient) {
                    patient = buildPatient((Eform.Patient) bundleEntry.resource);
                } else if (bundleEntry.resource instanceof Eform.Provider) {
                    provider = buildProvider((Eform.Provider) bundleEntry.resource);
                } else if (bundleEntry.resource instanceof Eform.Binary) {
                    contentVersions.add(buildFile((Eform.Binary) bundleEntry.resource));                
                } else if (bundleEntry.resource instanceof Eform.QuestionnaireResponse) {
                    requestDetails.addAll(buildRequestDetails((Eform.QuestionnaireResponse) bundleEntry.resource));
                }
            }
        }

        String drugCode = findDrugCode(requestDetails);
        List<Drug__c> drugs = [select Id, Name, Drug_Code__c from Drug__c where Drug_Code__c = :drugCode];
        String drugLabel = drugs.isEmpty() ? drugCode: drugs[0].Name;
        drug = drugs.isEmpty() ? new Drug__c() : drugs[0];

        saCase = buildCase(drug.Id, drugLabel, findReferenceNumber(bundle?.meta?.tag));
        
        contentVersions.add(buildFile('bundle.json', Blob.valueOf(bundleJsonStr)));

        return SpecialAuthorityRequest.build(drug, patient, provider, saCase, requestDetails, contentVersions);
    }

    public static Case buildCase(Id drugId, String drugLabel, String refNo) {
        Case caseRecord = new Case();
        caseRecord.Drug__c = drugId;
        caseRecord.Drug_Name__c = drugLabel;
        caseRecord.Subject = 'SA - ' + drugLabel;
        caseRecord.Origin = 'eForm';
        caseRecord.Status = 'Received';
        caseRecord.Description = 'Ref. No.: ' + refNo;
        return caseRecord;
    }

    public static Account buildPatient(Eform.Patient patient) {
        List<Account> existing = [select Id from Account where Patient_Identifier__pc = :patient.patientIdentifier];
        Account account = existing == null || existing.isEmpty() ? new Account() : existing[0];
        account.Patient_Identifier__pc = patient.patientIdentifier;
        account.RecordTypeId = SchemaUtil.getRecordTypeInfosByDeveloperName('Account', 'Patient').getRecordTypeId();
        account.FirstName = patient.firstName;
        account.LastName = patient.lastName;
        account.PersonBirthdate = patient.birthdate;
        account.PersonEmail = patient.primaryEmail;
        account.Phone = patient.primaryPhone;
        account.PersonMailingStreet = patient.streetLine1 + ' ' + patient.streetLine2;
        account.PersonMailingCity = patient.city;
        account.PersonMailingCountry = patient.country;
        account.PersonMailingState = patient.province;
        account.PersonMailingPostalCode = patient.postalCode;
        return account;
    }

    public static Account buildProvider(Eform.Provider provider) {
        List<Account> existing = [select Id from Account where Provider_Identifier__pc = :provider.providerIdentifier and Provider_Type__pc = :provider.providerIdentifierType];
        Account account = existing == null || existing.isEmpty() ? new Account() : existing[0];
        account.Provider_Identifier__pc = provider.providerIdentifier;
        account.Provider_Type__pc = provider.providerIdentifierType;
        account.RecordTypeId = SchemaUtil.getRecordTypeInfosByDeveloperName('Account', 'Provider').getRecordTypeId();
        account.FirstName = provider.firstName;
        account.LastName = provider.lastName;
        account.PersonBirthdate = provider.birthdate;
        account.Phone = provider.primaryPhone;
        account.PersonMailingStreet = provider.streetLine1 + ' ' + provider.streetLine2;
        account.PersonMailingCity = provider.city;
        account.PersonMailingCountry = provider.country;
        account.PersonMailingState = provider.province;
        account.PersonMailingPostalCode = provider.postalCode;
        return account;
    }

    public static List<Request_Detail__c> buildRequestDetails(Eform.QuestionnaireResponse QR) {
        return buildRequestDetails(new List<String>(), QR.item);
    }

    private static List<Request_Detail__c> buildRequestDetails(List<String> questionIds, List<Eform.QRItem> qrItems) {
        List<Request_Detail__c> requestDetails = new List<Request_Detail__c>();

        for (Eform.QRItem qri : qrItems) {
            List<String> newQuestionIds = new List<String>(questionIds);
            newQuestionIds.add(qri.linkId);

            if (qri.answer != null && qri.answer.isEmpty() == false) {
                requestDetails.addAll(buildRequestDetails(newQuestionIds, qri));
            } else {
                requestDetails.addAll(buildRequestDetails(newQuestionIds, qri.item)); 
            }
        }

        return requestDetails;
    }

    private static List<Request_Detail__c> buildRequestDetails(List<String> questionIds, Eform.QRItem qrItem) {
        List<Request_Detail__c> requestDetails = new List<Request_Detail__c>();
        
        String newQuestionId = String.join(questionIds, '.');

        for (Eform.QRAnswer qra : qrItem.answer) {
            Request_Detail__c rd = new Request_Detail__c();
            rd.Question__c = qrItem.text;
            rd.Question_ID__c = newQuestionId;
            rd.Sort_Order__c = SORT_ORDER++;
            rd.String_Value__c = qra.valueString;
            rd.Decimal_Value__c = qra.valueDecimal;
            rd.Date_Value__c = qra.valueDate;
            rd.Datetime_Value__c = qra.valueDatetime;
            requestDetails.add(rd);
        }

        return requestDetails;
    }
    
    public static ContentVersion buildFile(Eform.Binary binary) {
        return buildFile(binary.id + '.pdf', EncodingUtil.base64Decode(binary.data));
    }

    private static ContentVersion buildFile(String fileNameAndExt, Blob data) {
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.ContentLocation = 'S';
        contentVersion.PathOnClient = fileNameAndExt;
        contentVersion.Title = fileNameAndExt;
        contentVersion.VersionData = data;
        return contentVersion;
    }

    private static String findDrugCode(List<Request_Detail__c> requestDetails) {
        for (Request_Detail__c rd : requestDetails) {
            if (String.isNotBlank(rd.Question_ID__c) && rd.Question_ID__c.endsWithIgnoreCase('medication')) return rd.String_Value__c;
        }

        return 'No drug found.';
    } 

    private static String findReferenceNumber(List<Eform.Tag> tags) {
        String defaultCode = 'No reference number found.';

        if (tags == null) return defaultCode;

        for (Eform.Tag tag : tags) {
            if (tag.system_x.contains('correlationId')) {
                return tag.code;
            }
        }

        return defaultCode;
    }
}
