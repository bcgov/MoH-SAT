public with sharing class SpecialAuthorityRequest {
    public Drug__c drug { get; private set; }
    public Account patient { get; private set; }
    public Account provider { get; private set; }
    public Case saCase { get; private set; }
    public List<Request_Detail__c> requestDetails { get; private set; }
    public List<ContentVersion> contentVersions { get; private set; }
    
    private Boolean hasDrug;

    public SpecialAuthorityRequest(Drug__c drug, Account patient, Account provider, Case saCase, List<Request_Detail__c> requestDetails, List<ContentVersion> contentVersions) {
        this.drug = drug;
        this.patient = patient;
        this.provider = provider;
        this.saCase = saCase;
        this.requestDetails = requestDetails;
        this.contentVersions = contentVersions;
        
        this.hasDrug = this.drug != null;
    }

    public Boolean hasDrug() {
        return this.hasDrug;
    }

    public Id getDefaultOwnerId() {
        return hasDrug() ? drug.OwnerId : null;
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
        saCase.Provider_Fax__c = provider?.Fax;
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