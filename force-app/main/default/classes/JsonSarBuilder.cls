public with sharing class JsonSarBuilder implements SarBuilder {
    public class SarBuilderException extends Exception {}
    
    private static Integer SORT_ORDER = 100;
    
    public List<String> ERRORS = new List<String>();
    
    private String bundleJsonStr;
    
    public JsonSarBuilder(String bundleJsonStr) {
        this.bundleJsonStr = bundleJsonStr;
    }
    
    public SpecialAuthorityRequest build() {
        Drug__c drug;
        Account provider;
        Account patient;
        Account dec;
        Case saCase;
        List<Request_Detail__c> requestDetails = new List<Request_Detail__c>();
        List<ContentVersion> contentVersions = new List<ContentVersion>();
        
        Eform.Bundle bundle = Eform.parse(bundleJsonStr);
        
        if (bundle.entry == null || bundle.entry.isEmpty()) return null;
        
        for (Eform.Entry bundleEntry : bundle.entry) {
            Eform.Resource resource = bundleEntry.resource;
            
            try {
                if (resource.resourceType.equalsIgnoreCase('Patient')) {
                    patient = buildPatient(bundleEntry.resource);
                } else if (resource.resourceType.equalsIgnoreCase('Practitioner')) {
                    provider = buildProvider(bundleEntry.resource);
                } else if (resource.resourceType.equalsIgnoreCase('Binary') && resource.contentType != 'application/eforms') {
                    contentVersions.add(buildFile(bundleEntry.resource));
                } else if (resource.resourceType.equalsIgnoreCase('QuestionnaireResponse')) {
                    requestDetails.addAll(buildRequestDetails(bundleEntry.resource));
                }
            } catch (Exception e) {
                addError('Error processing ' + resource.resourceType + ' resource.', e);
            }
        }
        
        dec = buildDec(requestDetails);
        
        String drugCode = findDrugCode(requestDetails);
        List<Drug__c> drugs = [select Id, Name, Drug_Code__c from Drug__c where Drug_Code__c = :drugCode];
        String drugLabel = drugs.isEmpty() ? drugCode: drugs[0].Name;
        drug = drugs.isEmpty() ? new Drug__c() : drugs[0];
        
        String refNo = findReferenceNumber(bundle);
        String formSubmitter = findFormSubmitterUserName(bundle);
        
        saCase = buildCase(drug.Id, drugLabel, refNo, formSubmitter);
        
        if (!ERRORS.isEmpty()) {
            saCase.Description += '\n\n' + printErrors();
            saCase.OwnerId = SaSettings.getEformFaultQueueId();
        }
        
        contentVersions.add(buildBundleJsonFile(refNo, bundleJsonStr));
        
        return new SobjectSarBuilder(
            drug, 
            patient, 
            provider,
            dec,
            saCase, 
            requestDetails, 
            contentVersions
        ).build();
    }
    
    private Case buildCase(Id drugId, String drugLabel, String refNo, String formSubmitter) {
        Case caseRecord = new Case();
        caseRecord.Drug__c = drugId;
        caseRecord.Drug_Name__c = drugLabel;
        caseRecord.Subject = 'SA - ' + drugLabel;
        caseRecord.Origin = 'eForm';
        caseRecord.Status = 'Received';
        caseRecord.Description = 'Ref. No.: ' + refNo;
        caseRecord.eForm_Submitter__c = formSubmitter;
        return caseRecord;
    }
    
    private Account buildPatient(Eform.Resource resource) {
        Account account = buildAccount(resource);
        account.RecordTypeId = SchemaUtil.getRecordTypeInfosByDeveloperName('Account', 'Patient').getRecordTypeId();
        
        String identifier = getIdentifier(resource.identifier);
        account.Patient_Identifier__pc = identifier;
        account.PersonBirthdate = Date.valueOf(resource.birthDate);
        
        List<Account> existing = [select Id from Account where Patient_Identifier__pc = :identifier];
        account.Id = existing.isEmpty() ? null : existing[0].Id;
        
        return account;
    }
    
    private Account buildProvider(Eform.Resource resource) {
        Account account = buildAccount(resource);
        account.RecordTypeId = SchemaUtil.getRecordTypeInfosByDeveloperName('Account', 'Provider').getRecordTypeId();
        
        String providerType = toProviderRole(findProviderRole(resource));
        String identifier = getProviderIdentifier(resource.identifier);
        identifier = requiresTruncation(providerType) ? identifier?.right(5) : identifier;
        
        account.Provider_Type__pc = providerType;
        account.Provider_Identifier__pc = requiresTruncation(providerType) ? identifier?.right(5) : identifier;
        account.Provider_Specialty__pc = findProviderSpecialty(resource);
        
        List<Account> existing = [select Id,Provider_Specialty__pc from Account where Provider_Identifier__pc = :identifier and Provider_Type__pc =:providerType];
        account.Id = existing.isEmpty() ? null : existing[0].Id;
        String existingValues = !existing.isEmpty() && !string.isEmpty(existing.get(0).Provider_Specialty__pc) ? existing.get(0).Provider_Specialty__pc : '';
        List<String> existingProviderValueList = !existing.isEmpty() && !String.isEmpty(existing.get(0).Provider_Specialty__pc) ? existingValues.split(';') : new List<String>();
        Set<String> existingProviderValueSet = new Set<String>();
        String newProviderValuesSTR = '';
        for(String existingProviderValue: existingProviderValueList){
            existingProviderValueSet.add(existingProviderValue.normalizeSpace());
        }
        if(!String.isEmpty(account.Provider_Specialty__pc)){
        for(String newSpecialities: account.Provider_Specialty__pc.split(';')){
            if(!existingProviderValueSet.contains(newSpecialities.normalizeSpace())){
                if(!String.isEmpty(newProviderValuesSTR) && !newProviderValuesSTR.containsIgnoreCase(newSpecialities)){
                    newProviderValuesSTR = !String.isBlank(newSpecialities) ? (newProviderValuesSTR + ';' + newSpecialities) : newProviderValuesSTR;
                } else{
                    newProviderValuesSTR = newSpecialities;
                }
            }
        }
        }
        newProviderValuesSTR = newProviderValuesSTR.removeEnd(';');
        account.Provider_Specialty__pc = !String.isEmpty(newProviderValuesSTR) ? (existingValues +';'+ newProviderValuesSTR) : existingValues;
        return account;
    }
         
    private Account buildDec(List<Request_Detail__c> requestDetails) {
        if (!hasDec(requestDetails)) return null;
        
        String decCode = findDecCode(requestDetails);
        
        Account decAccount = new Account();
        decAccount.RecordTypeId = SchemaUtil.getRecordTypeInfosByDeveloperName('Account', 'DEC').getRecordTypeId();
        decAccount.DEC__c = decCode;
        
        List<Account> existing = [select Id, Name from Account where DEC__c = :decCode and RecordTypeId = :decAccount.RecordTypeId];
        
        if (!existing.isEmpty()) {            
            decAccount.Id = existing[0].Id;
        } else {
            decAccount.Name = 'DEC from eForms: ' + decCode;
        }
        
        for (Request_Detail__c rd : requestDetails) {
            if (rd.Question_ID__c.equalsIgnoreCase('panelDECinfo.decAddress.providerFaxNumber1')) decAccount.Fax = rd.String_Value__c;
            if (rd.Question_ID__c.equalsIgnoreCase('panelDECinfo.decAddress.decStreetAddressLine1')) decAccount.ShippingStreet = rd.String_Value__c;
            if (rd.Question_ID__c.equalsIgnoreCase('panelDECinfo.decAddress.decAddressCity')) decAccount.ShippingCity = rd.String_Value__c;
            if (rd.Question_ID__c.equalsIgnoreCase('panelDECinfo.decAddress.decaddressProvince')) decAccount.ShippingState = rd.String_Value__c;
            if (rd.Question_ID__c.equalsIgnoreCase('panelDECinfo.decAddress.decAddressPostalCode')) decAccount.ShippingPostalCode = rd.String_Value__c;
        }
        
        return decAccount;
    }
    
    private String findDecCode(List<Request_Detail__c> requestDetails) {
        for (Request_Detail__c rd : requestDetails) {
            if (rd.Question_ID__c.equalsIgnoreCase('panelDECinfo.dec')) {
                return rd.String_Value__c;
            }
        }
        
        return null;
    }
    
    private Boolean hasDec(List<Request_Detail__c> requestDetails) {
        for (Request_Detail__c rd : requestDetails) {
            if (rd.Question_ID__c != null && rd.Question_ID__c.startsWithIgnoreCase('panelDECinfo')) {
                return true;
            }
        }
        return false;
    }
    
    private Boolean requiresTruncation(String providerType) {
        return providerType.equalsIgnoreCase('Physician') || 
            providerType.equalsIgnoreCase('Pharmacist') ||
            providerType.equalsIgnoreCase('Nurse Practitioner') ||
            providerType.equalsIgnoreCase('Registered Psychiatric Nurse'); 
    }
    
    private Account buildAccount(Eform.Resource resource) {
        Account account = new Account();
        Eform.Name name = getName(resource.name);
        account.FirstName = name == null || name.given == null || name.given.isEmpty() ? '' : String.join(name.given, ' ');
        account.LastName = name == null ? '(EMPTY)' : name.family;
        account.Person_Full_Name__c = account.FirstName + ' ' + account.LastName;
        if (account.FirstName.length() > 40) { account.FirstName = account.FirstName.substring(0, 40); }
        
        account.Phone = getTelecom(resource.telecom, 'phone')?.value;
        account.Fax = getTelecom(resource.telecom, 'fax')?.value;
        
        Eform.Address address = getAddress(resource.address);
        account.PersonMailingStreet = address == null || address.line == null ? null : String.join(address.line, ' ');
        account.PersonMailingCity = address?.city;
        account.PersonMailingState = address?.state;
        account.PersonMailingPostalCode = address?.postalCode;
        return account;
    }
    
    public List<Request_Detail__c> buildRequestDetails(Eform.Resource resource) {
        return buildRequestDetails(new List<String>(), resource.item);
    }
    
    private List<Request_Detail__c> buildRequestDetails(List<String> questionIds, List<Eform.Item> qrItems) {
        List<Request_Detail__c> requestDetails = new List<Request_Detail__c>();
        
        if (qrItems == null) return requestDetails;
        
        for (Eform.Item qri : qrItems) {
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
    
    private List<Request_Detail__c> buildRequestDetails(List<String> questionIds, Eform.Item qrItem) {
        List<Request_Detail__c> requestDetails = new List<Request_Detail__c>();
        
        String newQuestionId = String.join(questionIds, '.')?.right(255);
        
        for (Eform.Answer qra : qrItem.answer) {
            Request_Detail__c rd = buildRequestDetail(newQuestionId, qrItem.text, qra);
            requestDetails.add(rd);
        }
        
        return requestDetails;
    }
    
    private Request_Detail__c buildRequestDetail(String questionId, String questionText, Eform.Answer qra) {
        Boolean hasCoding = hasCoding(qra);
        
        Request_Detail__c rd = new Request_Detail__c();
        rd.Sort_Order__c = SORT_ORDER++;
        rd.Question_ID__c = questionId;
        rd.Question__c = questionText;
        rd.String_Value__c = hasCoding ? qra.valueCoding.code : qra.valueString;
        rd.String_Value_Label__c = hasCoding ? qra.valueCoding.display : null;
        rd.Decimal_Value__c = qra.valueDecimal;
        rd.Date_Value__c = qra.valueDate;
        rd.Datetime_Value__c = qra.valueDatetime;
        rd.Boolean_Value__c = qra.valueBoolean == true;
        rd.Question__c = hasCoding && String.isBlank(rd.Question__c) ? qra.valueCoding.display : rd.Question__c;
        return rd;
    }
    
    private Boolean hasCoding(Eform.Answer qra) {
        return qra.valueCoding != null && String.isNotBlank(qra.valueCoding.code);
    }
    private ContentVersion buildBundleJsonFile(String refNo, String bundleJsonStr) {
        String fileNameAndExt = String.format(
            'bundle{0}.json', new String[] {
                String.isBlank(refNo) ? '' : '-' + refNo
                    });
        
        return buildFile(fileNameAndExt, Blob.valueOf(bundleJsonStr));
    }
    private ContentVersion buildFile(Eform.Resource resource) {
        String fileNameAndExt = resource.id;
        
        if (resource.contentType == 'application/pdf') fileNameAndExt += '.pdf'; 
        
        return buildFile(fileNameAndExt, EncodingUtil.base64Decode(resource.data));
    }
    
    private ContentVersion buildFile(String fileNameAndExt, Blob data) {
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.ContentLocation = 'S';
        contentVersion.PathOnClient = fileNameAndExt;
        contentVersion.Title = fileNameAndExt;
        contentVersion.VersionData = data;
        return contentVersion;
    }
    
    private String findDrugCode(List<Request_Detail__c> requestDetails) {
        for (Request_Detail__c rd : requestDetails) {
            if (String.isNotBlank(rd.Question_ID__c) && rd.Question_ID__c.endsWithIgnoreCase('medication')) return rd.String_Value__c;
        }
        return 'No drug found.';
    } 
    
    private String findReferenceNumber(Eform.Bundle bundle) {
        List<Eform.Tag> tags = bundle?.meta?.tag;
        
        String defaultCode = 'No reference number found.';
        
        if (tags == null) return defaultCode;
        
        for (Eform.Tag tag : tags) {
            if (tag.system_Z.contains('correlationId')) {
                defaultCode = tag.code;
            }
        }
        return defaultCode;
    }
    
    private String findFormSubmitterUserName(Eform.Bundle bundle) {
        List<Eform.Tag> tags = bundle?.meta?.tag;
        
        String formSubmitterUserName = 'No eForm Submitter found.';
        
        if (tags == null) return formSubmitterUserName;
        
        for (Eform.Tag tag : tags) {
            if (tag.system_Z.contains('formSubmitterUserName')) {
                formSubmitterUserName = tag.code;
            }
        }
        return formSubmitterUserName;
    }
    
    private String toProviderRole(String eformRole) {
        String role = eformRole.normalizeSpace();
        if (String.isBlank(role)) return null;
        else if (role.equalsIgnoreCase('Physician')) return 'Physician';
        else if (role.equalsIgnoreCase('Dentist')) return 'Dentist';
        else if (role.equalsIgnoreCase('Optometrist')) return 'Optometrist';
        else if (role.equalsIgnoreCase('Podiatrist')) return 'Podiatrist';
        else if (role.equalsIgnoreCase('Pharmacist')) return 'Pharmacist';
        else if (role.equalsIgnoreCase('Midwife')) return 'Midwife';
        else if (role.equalsIgnoreCase('Registered Nurse')) return 'Nurse';
        else if (role.equalsIgnoreCase('Registered Nurse Practitioner')) return 'Nurse Practitioner';
        else if (role.equalsIgnoreCase('OOP Provider')) return 'Out of province provider';
        else return role;
    }
    
    private String findProviderRole(Eform.Resource resource) {
        return findQualification(resource.qualification, 'http://fhir.infoway-inforoute.ca/CodeSystem/scpqual')?.display;
    }
    
    private String findProviderSpecialty(Eform.Resource resource) {
        return findQualification(resource.qualification, 'http://hl7.org/fhir/practitioner-specialty')?.code;
    }
    
    private Eform.Tag findQualification(List<Eform.Qualification> qualifications, String systemValue) {
        if (qualifications == null) return null;
        
        for (Eform.Qualification qualification : qualifications) {
            List<Eform.Tag> codes = qualification?.code?.coding;
            if (codes.isEmpty()) return null;
            for (Eform.Tag code : codes) {
                if (systemValue.equalsIgnoreCase(code.system_Z)) {
                    return code;
                }
            }
        }
        return null;
    }
    
    private String getIdentifier(List<Eform.Identifier> identifiers) {
        String value = 'NULL_IDENTIFIER';
        if (identifiers == null) return value;
        for (Eform.Identifier identifier : identifiers) {
            value = identifier.value;
        }
        return value;
    }
    
    private String getProviderIdentifier(List<Eform.Identifier> identifiers) {
        String value = null;
        if (identifiers == null) return value;
        for (Eform.Identifier identifier : identifiers) {
            if (identifier.system_Z.startsWithIgnoreCase('https://fhir.infoway-inforoute.ca/NamingSystem/ca-bc-license')) {
                value = identifier.value;
                break;
            }
        }
        return value;
    }
    
    private Eform.Name getName(List<Eform.Name> names) {
        if (names == null) return null;
        for (Eform.Name name : names) {
            return name;
        }
        return null;
    }
    
    private Eform.Telecom getTelecom(List<Eform.Telecom> telecoms, String system_z) {
        if (telecoms == null) return null;
        for (Eform.Telecom telecom : telecoms) {
            if (telecom.system_Z.equalsIgnoreCase(system_z))
                return telecom;
        }
        return null;
    }
    
    private Eform.Address getAddress(List<Eform.Address> addresses) {
        if (addresses == null) return null;
        for (Eform.Address address : addresses) {
            return address;
        }
        return null;
    }
    
    private void addError(String subject, Exception e) {
        ERRORS.add(String.format('{0}: {1}', new String[] {
            subject,
                e.getMessage() + '\n' + e.getStackTraceString()
                }));
    }
    
    private String printErrors() {
        String result = '--- ERRORS START ---\n';
        result += String.join(ERRORS, '\n\n');
        result += '\n--- ERRORS END ---';
        return result;
    }
}