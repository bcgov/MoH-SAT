public with sharing class AutofaxController {

    private static Map<String, EmailTemplate> EMAIL_TEMPLATES {
        get {
            if (EMAIL_TEMPLATES == null) {
                EMAIL_TEMPLATES = new Map<String, EmailTemplate>();
                for (EmailTemplate ET : FolderUtility.getTemplates()) {
                    EMAIL_TEMPLATES.put(ET.DeveloperName, ET);
                }
            }
            return EMAIL_TEMPLATES;
        }
        set;
    }

    @AuraEnabled
    public static List<FaxableCase> loadFaxableCases(List<Id> ids){   
        List<FaxableCase> faxableCases = new List<FaxableCase>();
        for (Case record : queryCases(ids)) {
            EmailTemplate et = getTemplate(record);
            if (et == null) continue;
            faxableCases.add(new FaxableCase(record, et));            
        }
        return faxableCases;
    }

    private static EmailTemplate getTemplate(Case record) {
        String status = record.Status;
        String drugCode = record.Drug__r?.Drug_Code__c?.toLowerCase();

        if (status == 'Approved' && drugCode == 'omnipod') return EMAIL_TEMPLATES.get('Insulin_Pump_Approval_Letter_Omnipod');
        else if (status == 'Approved' && drugCode == 'ypsopump') return EMAIL_TEMPLATES.get('Insulin_Pump_Approval_Letter_YpsoPump');
        else if (status == 'Approved' && drugCode == 'minimed') return EMAIL_TEMPLATES.get('Insulin_Pump_Approval_Letter_Medtronic');
        else if (status == 'Approved') return EMAIL_TEMPLATES.get('Approved_Fax_Template');
        else if (status == 'Not Approved') return EMAIL_TEMPLATES.get('Not_Approved_Fax_Template');
        else if (status == 'Currently Approved') return EMAIL_TEMPLATES.get('Currently_Approved_Fax_Template');
        else if (status == 'On Hold - MIR') return EMAIL_TEMPLATES.get('MIR_Fax_Template');
        else return null;
    }

    private static List<Case> queryCases(List<Id> ids) {
        return [
            select
                Id, CaseNumber, Provider_Fax__c, Status, Drug__r.Drug_Code__c
            from Case
            where Id in :ids
            order by ClosedDate asc];
    }

    public class FaxableCase {
        @AuraEnabled public Id caseId;
        @AuraEnabled public Id templateId;
        @AuraEnabled public String templateName;
        @AuraEnabled public String caseNumber;
        @AuraEnabled public String status;
        @AuraEnabled public String providerFax;

        public FaxableCase(Case record, EmailTemplate emailTemplate) {
            this.caseId = record.Id;
            this.caseNumber = record.CaseNumber;
            this.status = record.Status;
            this.providerFax = record.Provider_Fax__c;
            this.templateId = emailTemplate.Id;
            this.templateName = emailTemplate.DeveloperName;
        }
    }
}
