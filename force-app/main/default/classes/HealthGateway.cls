global with sharing class HealthGateway {
    global class SaList {
        public List<SaItem> items { get; set; }
    }

    global class SaItem {
        public String patientIdentifier { get; set; }
        public String patientFirstName { get; set; }
        public String patientLastName { get; set; }
        public String prescriberFirstName { get; set; }
        public String prescriberLastName { get; set; }
        public String drugName { get; set; }
        public String referenceNumber { get; set; }
        public String requestStatus { get; set; }
        public Date requestedDate { get; set; }
        public Date effectiveDate { get; set; }
        public Date expiryDate { get; set; }

        global SaItem(Case c) {
            this.patientIdentifier = c.Contact.Patient_Identifier__c;
            this.patientFirstName = c.Contact.FirstName;
            this.patientLastName = c.Contact.LastName;
            this.prescriberFirstName = c.Provider__r.FirstName;
            this.prescriberLastName = c.Provider__r.LastName;
            this.drugName = c.Drug_Name__c;
            this.requestStatus = c.Status;
            this.referenceNumber = c.CaseNumber;
            this.requestedDate = c.CreatedDate.date();

            Boolean approved = this.requestStatus == 'Approved'; 
            this.effectiveDate = approved ? c.Effective_Date__c : null;
            this.expiryDate = approved ? c.Termination_Date__c : null;
        }
    }
}