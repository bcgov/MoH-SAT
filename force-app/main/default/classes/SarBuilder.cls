public with sharing class SarBuilder {
    private static Integer SORT_ORDER = 100;

    public static SpecialAuthorityRequest build(Eform.Bundle bundle) {
        Drug__c drug;
        Account provider;
        Account patient;
        Case saCase;
        List<Request_Detail__c> requestDetails = new List<Request_Detail__c>();
        List<ContentVersion> contentVersions = new List<ContentVersion>();

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

        save(provider, patient, saCase, requestDetails, contentVersions);

        return null;
    }

    private static void save(Account provider, Account patient, Case saCase, List<Request_Detail__c> requestDetails, List<ContentVersion> contentVersions) {
        insert new Account[] {patient, provider};
        
        Contact patientContact = [select Id from Contact where AccountId = :patient.Id];
        Contact providerContact = [select Id from Contact where AccountId = :provider.Id];
        
        Drug__c drug = [select Id, Name from Drug__c where Drug_Code__c = :findDrugCode(requestDetails)];

        saCase = buildCase('SA - ' + drug.Name);
        saCase.ContactId = patientContact.Id;
        saCase.Provider__c = providerContact.Id;
        saCase.Drug__c = drug.Id;
        insert saCase;

        for (Request_Detail__c rd : requestDetails) {
            rd.Case__c = saCase.Id;
        }

        insert requestDetails;

        insert contentVersions;

        List<ContentDocumentLink> cdls = new List<ContentDocumentLink>();
        for (ContentVersion cv : [select ContentDocumentId from ContentVersion where Id in :contentVersions]) {
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = saCase.Id;
            cdl.ContentDocumentId = cv.ContentDocumentId;
            cdl.ShareType = 'V';
            cdls.add(cdl);
        }

        insert cdls;
    }

    public static Case buildCase(String subject) {
        Case caseRecord = new Case();
        caseRecord.Subject = subject;
        caseRecord.Origin = 'eForm';
        caseRecord.Status = 'Received';
        return caseRecord;
    }

    public static Account buildPatient(Eform.Patient patient) {
        Account account = new Account();
        account.RecordTypeId = SchemaUtil.getRecordTypeInfosByDeveloperName('Account', 'Patient').getRecordTypeId();
        account.Patient_Identifier__pc = patient.patientIdentifier;
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
        Account account = new Account();
        account.RecordTypeId = SchemaUtil.getRecordTypeInfosByDeveloperName('Account', 'Provider').getRecordTypeId();
        account.Provider_Identifier__pc = provider.providerIdentifier;
        account.Provider_Type__pc = provider.providerIdentifierType;
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

    private static String findDrugCode(List<Request_Detail__c> requestDetails) {
        for (Request_Detail__c rd : requestDetails) {
            if (rd.Question_ID__c == 'select') return rd.String_Value__c;
        }

        return null;
    } 
    
    public static ContentVersion buildFile(Eform.Binary binary) {
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.ContentLocation = 'S';
        contentVersion.PathOnClient = binary.id + '.pdf';
        contentVersion.Title = binary.id + '.pdf';
        contentVersion.VersionData = EncodingUtil.base64Decode(binary.data);
        return contentVersion;
    }
}
