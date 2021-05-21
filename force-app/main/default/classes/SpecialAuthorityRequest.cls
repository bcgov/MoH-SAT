public with sharing class SpecialAuthorityRequest {
    public Drug__c drug { get; private set; }
    public Account patient { get; private set; }
    public Account provider { get; private set; }
    public Case saCase { get; private set; }
    public List<Request_Detail__c> requestDetails { get; private set; }
    public List<ContentVersion> contentVersions { get; private set; }
    public List<SAApprovalRequest> saApprovalRequests { get; private set; }
    
    private Boolean hasDrug;

    public SpecialAuthorityRequest(Drug__c drug, Account patient, Account provider, Case saCase, List<Request_Detail__c> requestDetails, List<ContentVersion> contentVersions) {
        this.drug = drug;
        this.patient = patient;
        this.provider = provider;
        this.saCase = saCase;
        this.requestDetails = requestDetails;
        this.contentVersions = contentVersions;
        this.saApprovalRequests = new List<SAApprovalRequest>();
        
        this.hasDrug = this.drug != null;
    }

    public Boolean hasDrug() {
        return this.hasDrug;
    }

    public Id getDefaultOwnerId() {
        return hasDrug() ? drug.OwnerId : null;
    }

    public void setEffectiveDate() {
        this.saCase.Effective_Date__c = Date.today();
    }

    public void setPushedToPharmanet() {
        this.saCase.Pushed_to_Pnet__c = true;
        this.saCase.Pushed_to_Pnet_Date__c = DateTime.now();
    }

    public void setTerminationDate() {
        for (SAApprovalRequest saaRequest : saApprovalRequests) {
            this.saCase.Termination_Date__c = DateUtil.parseOdrDate(saaRequest?.saRecord?.terminationDate);
        }
    }

    public void addSaApprovalRequest(StepAction actionParams) {
        this.addSaApprovalRequest(
            actionParams.pharmanetCode, 
            actionParams.keyType, 
            actionParams.saType, 
            actionParams.pricePercent, 
            actionParams.daysSupply, 
            actionParams.duration, 
            actionParams.durationUnit, 
            actionParams.excludedPlans, 
            actionParams.justificationCodes
        );
    }

    public void addSaApprovalRequest(String pharmanetCode,
                                    String keyType,
                                    String saType,
                                    Double pricePercent,
                                    Integer daysSupply,
                                    Integer duration,
                                    String durationUnit,
                                    List<String> excludedPlans,
                                    List<String> justificationCodes) {
        
        SAApprovalRequest sarBody = new SAApprovalRequest();
        sarBody.saRecord.phn = this.patient.Patient_Identifier__pc;
        sarBody.saRecord.specAuthType = saType;
        sarBody.saRecord.saRequester.practId = this.provider.Provider_Identifier__pc;
        sarBody.saRecord.saRequester.practIdRef = OdrIntegration.getPractitionerCode(this.provider.Provider_Type__pc);
        sarBody.saRecord.maxDaysSupply = Integer.valueOf(daysSupply);
        sarBody.saRecord.maxPricePct = pricePercent;
        sarBody.saRecord.excludedPlans = excludedPlans;
        sarBody.saRecord.justificationCodes = justificationCodes;
        
        String dinOrRdp = pharmanetCode?.replaceAll('[^0-9]+', '');
        sarBody.saRecord.specialItem.rdp = keyType == 'RDP' ? dinOrRdp : null;
        sarBody.saRecord.specialItem.din = keyType == 'DIN' ? dinOrRdp : null;

        if (this.saCase.Effective_Date__c != null) {
            sarBody.saRecord.effectiveDate = DateUtil.formatToOdrDate(this.saCase.Effective_Date__c);
        }
        
        Date terminationDate = this.saCase.Termination_Date__c != null ? 
            this.saCase.Termination_Date__c :
            DateUtil.calculateTerminationDate(
                this.saCase.Effective_Date__c, 
                Integer.valueOf(duration), 
                durationUnit
            );

        sarBody.saRecord.terminationDate = DateUtil.formatToOdrDate(terminationDate);

        saApprovalRequests.add(sarBody);
    }

    public List<SAApprovalRequest> getSaApprovalRequests() {
        return this.saApprovalRequests;
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