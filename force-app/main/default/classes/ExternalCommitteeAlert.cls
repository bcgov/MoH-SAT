public with sharing class ExternalCommitteeAlert {

    @TestVisible
    private static OrgWideEmailAddress mockOWEA = mockOrgWideEmailAddress();
    
    @AuraEnabled
    public static void sendAlert(Id externalCommitteeId){
        List<Case> relatedCases = getRelatedCases(externalCommitteeId);
        External_Committee__c ec = getExternalCommittee(externalCommitteeId);
        String agenda = createAgenda(relatedCases);
        ec.Agenda__c = agenda;
        update ec;

        // Scratch org must have this setup with the name below in Setup > Organization-Wide Email Addresses 
        OrgWideEmailAddress owea = getOrgWideEmailAddress();

        // Implement getEmailTemplate() based on Anshul's reqs
        String emailTemplateName = getEmailTemplate(ec);
        EmailTemplate emailTemplate = [SELECT Id, Name FROM EmailTemplate WHERE Name = :emailTemplateName];

        // Query contacts under the EC's parent account.
        List<Contact> contacts = getRelatedContacts(ec.EC_To_Account__c);

        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
        for (Contact c : contacts) {
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setTargetObjectId(c.id); 
            message.setTemplateID(emailTemplate.Id); 
            message.setWhatId(externalCommitteeId); 
            message.setOrgWideEmailAddressId(owea.Id); 
            message.setSaveAsActivity(true); 
            messages.add(message);
        }

        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

        ec.Email_Sent__c = Datetime.now();
        update ec;

    }

    public static List<Case> getRelatedCases(Id externalCommitteeId){
        return [
            SELECT Id, CaseNumber, External_Committee__c
            FROM Case
            WHERE External_Committee__c = : externalCommitteeId
        ];
    }

    public static External_Committee__c getExternalCommittee(Id externalCommitteeId){
        return [
            SELECT Id, Name, Agenda__c, External_Committee_Type__c, EC_To_Account__c
            FROM External_Committee__c
            WHERE Id = : externalCommitteeId
        ];
    }

    public static String createAgenda(List<Case> relatedCases){
        List<String> caseNumbers = new List<String>();
        for (Case c : relatedCases){
            caseNumbers.add(c.CaseNumber);
        }

        return '<p>' + String.join(caseNumbers, '<br/>') + '</p>';
    }

    public static OrgWideEmailAddress getOrgWideEmailAddress(){
        return Test.isRunningTest() ? mockOWEA : [
            SELECT Id, Address, DisplayName, IsAllowAllProfiles, Purpose 
            FROM OrgWideEmailAddress 
            WHERE DisplayName = 'BC PharmaCare'
        ];
    }

    public static String getEmailTemplate(External_Committee__c ec){
        String emailTemplateName = ec.External_Committee_Type__c + ' Template';
        return emailTemplateName;
    }

    public static List<Contact> getRelatedContacts(Id accountId){
        return [SELECT Id, Email FROM Contact WHERE AccountId = :accountId AND Email != NULL];
    }

    public static OrgWideEmailAddress mockOrgWideEmailAddress(){
        OrgWideEmailAddress owea = new OrgWideEmailAddress();
        return owea;
    }
}
