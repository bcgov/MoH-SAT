public inherited sharing class SobjectSarBuilder implements SarBuilder {
    
    private Drug__c drug;
    private Account patient;
    private Account provider;
    private Account dec;
    private Case saCase;
    private List<Request_Detail__c> requestDetails;
    private List<ContentVersion> contentVersions;
    private List<SAApprovalRequest> saApprovalRequests;

    public SobjectSarBuilder(
        Drug__c drug, 
        Account patient, 
        Account provider,  
        Account dec, 
        Case saCase, 
        List<Request_Detail__c> requestDetails, 
        List<ContentVersion> contentVersions) {
        this.drug = drug;
        this.patient = patient;
        this.provider = provider;
        this.dec = dec;
        this.saCase = saCase;
        this.requestDetails = requestDetails;
        this.contentVersions = contentVersions;
    }

    public SobjectSarBuilder(Id caseId) {
        this(query(caseId));
    }

    private SobjectSarBuilder(Case saCase) {
        this(
            saCase.Drug__c == null ? null : queryDrug(saCase.Drug__c),
            String.isBlank(saCase.ContactId) ? null : saCase.Contact.Account, 
            String.isBlank(saCase.Provider__c) ? null : saCase.Provider__r.Account, 
            String.isBlank(saCase.DEC__c) ? null : saCase.DEC__r, 
            saCase,
            saCase.Request_Details__r,
            new List<ContentVersion>()
        );
    }

    public SpecialAuthorityRequest build() {
        return new SpecialAuthorityRequest(drug, patient, provider, dec, saCase, requestDetails, contentVersions);
    }

    private static Case query(Id caseId) {
        return [
            select 
                Id, Origin, OwnerId, Priority, IsClosed, Status, Subject, Pushed_to_Pnet__c, Pushed_to_Pnet_Date__c, Request_Type__c, 
                Hold_Reason__c, Patient_Validated__c, Provider_Validated__c, Verbal_Order__c, Renewal__c,
                Approved_date_time__c, Auto_Adjudicated_Date__c, Fax_Sent_Date__c, Fax_Notification_Date__c, Max_Days_Supply__c,
                Patient_Validated_Date__c, Patient_Identifier__c, Patient_Date_of_Birth__c,
                Provider_Validated_Date__c, Termination_Date__c, Effective_Date__c, DEC_Name__c,

                Drug__c, Drug_Name__c, Drug__r.Adjudication_Strategy__c, Drug__r.OwnerId,

                Contact.Account.FirstName, Contact.Account.LastName, Contact.Account.Patient_Identifier__pc, 
                Contact.Account.PersonBirthdate, Contact.Account.PersonMailingStreet, Contact.Account.PersonMailingCity,
                Contact.Account.PersonMailingState, Contact.Account.PersonMailingPostalCode, Contact.Account.PersonMailingCountry,
                
                Provider__r.Account.FirstName, Provider__r.Account.LastName, Provider__r.Provider_Identifier__c, Provider__r.Fax, Provider_Fax__c,
                Provider__r.Account.Provider_Identifier__pc, Provider__r.Account.Provider_Type__pc, Provider__r.Provider_Type__c,
                Provider__r.Account.PersonBirthdate, Provider__r.Account.PersonMailingStreet, Provider__r.Account.PersonMailingCity,
                Provider__r.Account.PersonMailingState, Provider__r.Account.PersonMailingPostalCode, Provider__r.Account.PersonMailingCountry,
                
                DEC__c, DEC__r.DEC__c, DEC__r.Fax, DEC__r.ShippingStreet, 
                DEC__r.ShippingCity,DEC__r.ShippingState, DEC__r.ShippingPostalCode,

                (
                    select Id, Sort_Order__c, Question_ID__c, Question__c,
                        String_Value__c, String_Value_Label__c, Decimal_Value__c, Boolean_Value__c, Date_Value__c, Datetime_Value__c
                    from Request_Details__r
                    order by Sort_Order__c asc
                )
            from Case
            where Id = :caseId
        ];
    }

    private static Drug__c queryDrug(Id drugId) {
        return [select Id, Auto_Validate_Patient__c, Auto_Validate_Provider__c, Auto_Push_to_Pharmanet__c, OwnerId,
                    (select 
                        Id, Days_Supply__c, Excluded_Plans__c, Justification_Codes__c, 
                        Key_Type__c, Pharmanet_Code__c, Price_Percent__c, SA_Type__c,
                        Duration__c, Duration_Unit__c 
                    from Drug_Templates__r)
                from Drug__c where Id = :drugId];
    }
}
