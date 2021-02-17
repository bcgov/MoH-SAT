public with sharing class SpecialAuthorityRequest {
    public Drug__c drug { get; private set; }
    public Account patient { get; private set; }
    public Account provider { get; private set; }
    public Case saCase { get; private set; }
    public List<Request_Detail__c> requestDetails { get; private set; }
    public List<ContentVersion> contentVersions { get; private set; }
    
    private Boolean hasDrug;

    private SpecialAuthorityRequest(Drug__c drug, Account patient, Account provider, Case saCase, List<Request_Detail__c> requestDetails, List<ContentVersion> contentVersions) {
        this.drug = drug;
        this.patient = patient;
        this.provider = provider;
        this.saCase = saCase;
        this.requestDetails = requestDetails;
        this.contentVersions = contentVersions;
        
        this.hasDrug = this.drug != null;
    }

    public static SpecialAuthorityRequest build(Drug__c drug, Account patient, Account provider, Case saCase, List<Request_Detail__c> requestDetails) {
        return build(drug, patient, provider, saCase, requestDetails, new List<ContentVersion>());
    }

    public static SpecialAuthorityRequest build(Drug__c drug, Account patient, Account provider, Case saCase, List<Request_Detail__c> requestDetails, List<ContentVersion> contentVersions) {
        return new SpecialAuthorityRequest(drug, patient, provider, saCase, requestDetails, contentVersions);
    }

    public static SpecialAuthorityRequest build(Id caseId) {
        return build(new Id[] {caseId})[0];
    }

    public static SpecialAuthorityRequest build(Case saCase) {
        Account patient = saCase.ContactId == null ? null : queryAccount(saCase.ContactId);
        Account provider = saCase.Provider__c == null ? null : queryAccount(saCase.Provider__c);
        Drug__c drug = saCase.Drug__c == null ? null : queryDrug(saCase.Drug__c);

        List<Request_Detail__c> requestDetails = saCase.Id == null ? new List<Request_Detail__c>() : queryRequestDetails(saCase.Id);

        return build(drug, patient, provider, saCase, requestDetails);
    }

    private static List<SpecialAuthorityRequest> build(List<Id> caseIds) {
        List<SpecialAuthorityRequest> sars = new List<SpecialAuthorityRequest>();

        for (Case sacase : query(caseIds)) {
            sars.add(build(
                saCase.Drug__c == null ? null : queryDrug(saCase.Drug__c),
                String.isBlank(saCase.ContactId) ? null : saCase.Contact.Account, 
                String.isBlank(saCase.Provider__c) ? null : saCase.Provider__r.Account, 
                saCase, 
                saCase.Request_Details__r
            ));
        }

        return sars;
    }

    public Boolean hasDrug() {
        return this.hasDrug;
    }

    public String getAdjudicationStrategy() {
        return hasDrug() ? drug.Adjudication_Strategy__c : null;
    }

    public Id getDefaultOwnerId() {
        return hasDrug() ? drug.OwnerId : null;
    }

    private static List<Case> query(List<Id> caseIds) {
        return [
            select 
                Id, Origin, OwnerId, Priority, IsClosed, Status, Subject, Pushed_to_Pnet__c,
                Patient_Validated__c, Provider_Validated__c, Verbal_Order__c, Renewal__c,
                Patient_Validated_Date__c, Patient_Identifier__c, Patient_Date_of_Birth__c,
                Provider_Validated_Date__c, Termination_Date__c, Effective_Date__c, SA_Type__c,

                Drug__c, Drug_Name__c, Drug__r.Adjudication_Strategy__c, Drug__r.OwnerId, Drug__r.Pharmanet_Code__c,

                Contact.Account.FirstName, Contact.Account.LastName, Contact.Account.Patient_Identifier__pc, 
                Contact.Account.PersonBirthdate, Contact.Account.PersonMailingStreet, Contact.Account.PersonMailingCity,
                Contact.Account.PersonMailingState, Contact.Account.PersonMailingPostalCode, Contact.Account.PersonMailingCountry,
                
                Provider__r.Account.FirstName, Provider__r.Account.LastName, Provider__r.Provider_Identifier__c, 
                Provider__r.Account.Provider_Identifier__pc, Provider__r.Account.Provider_Type__pc, Provider__r.Provider_Type__c,
                Provider__r.Account.PersonBirthdate, Provider__r.Account.PersonMailingStreet, Provider__r.Account.PersonMailingCity,
                Provider__r.Account.PersonMailingState, Provider__r.Account.PersonMailingPostalCode, Provider__r.Account.PersonMailingCountry,
                
                (
                    select Id, Sort_Order__c, Question_ID__c, Question__c,
                        String_Value__c, Decimal_Value__c, Boolean_Value__c, Date_Value__c, Datetime_Value__c
                    from Request_Details__r
                    order by Sort_Order__c asc
                )
            from Case
            where Id = :caseIds
        ];
    }

    private static Account queryAccount(Id contactId) {
        return [
            select 
                FirstName, LastName, Patient_Identifier__pc, Provider_Type__pc, 
                PersonBirthdate, PersonMailingStreet, PersonMailingCity,
                PersonMailingState, PersonMailingPostalCode, PersonMailingCountry
            from Account 
            where Id in (select AccountId from Contact where Id = :contactId)
        ];
    }

    private static Drug__c queryDrug(Id drugId) {
        return [select Id, Adjudication_Strategy__c, OwnerId,
                    (select Id, Days_Supply__c, Excluded_Plans__c, Justification_Codes__c, Key_Type__c, Pharmanet_Code__c,
                    Price_Percent__c, SA_Type__c from Drug_Templates__r)
                from Drug__c where Id = :drugId];
    }

    private static List<Request_Detail__c> queryRequestDetails(Id caseId) {
        return [
            select 
                Id, Sort_Order__c, Question_ID__c, Question__c,
                String_Value__c, Decimal_Value__c, Boolean_Value__c, Date_Value__c, Datetime_Value__c
            from Request_Detail__c
            where Case__c = :caseId
            order by Sort_Order__c asc
        ];
    }

    public void save() {
        Boolean hasPatient = patient != null;
        Boolean hasProvider = provider != null;

        if (hasPatient && patient.Id == null) { insert patient; } else if (hasPatient) { update patient; }
        if (hasProvider && provider.Id == null) { insert provider; } else if (hasProvider) { update provider; }
        
        Contact patientContact = hasPatient ? [select Id from Contact where AccountId = :patient.Id] : new Contact();
        Contact providerContact = hasProvider ? [select Id from Contact where AccountId = :provider.Id] : new Contact();

        saCase.ContactId = patientContact.Id;
        saCase.Provider__c = providerContact.Id;
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
}