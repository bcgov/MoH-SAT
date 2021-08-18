public with sharing class IdirRegistrationHandler implements Auth.RegistrationHandler {
    
    private Organization org;
    private Boolean isLocal = false;
    private Boolean isDbaacPortal = false;
    private Boolean isSshibcPortal = false;
    private Account serviceBc;
    private Account hibc;

    public IdirRegistrationHandler() {
        this.org = [select Id, IsSandbox from Organization limit 1];

        Network network = Network.getNetworkId() == null ? null : [select Id, Name from Network where Id =: Network.getNetworkId()];
        this.isLocal = network == null;
        this.isDbaacPortal = network?.Name.equalsIgnoreCase('DBAAC Portal');
        this.isSshibcPortal = network?.Name.equalsIgnoreCase('SSHIBC - Service Support HIBC');
    
        this.serviceBc = [select Id, Name from Account where Name in ('Service BC (SBC) Call Centre', 'Service BC') limit 1];
        this.hibc = [select Id, Name from Account where Name in ('HIBC HelpDesk', 'HIBC') limit 1];
    }

    public User createUser(Id portalId, Auth.UserData data){
        User user = buildUser(data);
        user.IsActive = true;
        user.TimeZoneSidKey = 'America/Los_Angeles';
        user.EmailEncodingKey = 'UTF-8';
        user.LanguageLocaleKey = 'en_US';
        user.LocaleSidKey = 'en_CA';
        user.ProfileId = getDefaultProfileId(data);
        user.Username = createUsername(data.email);
        
        if (isLocal) {
            user.UserPermissionsSupportUser = true;
        } else {
            Contact contact = buildContact(data);
            insert contact;
            user.ContactId = contact.Id;
        }

        return user;
    }
    
    public void updateUser(Id userId, Id portalId, Auth.UserData data){
        User user = buildUser(data);
        user.Id = userId;
        update user;
    }

    private String createUsername(String email) {
        return email + (org.IsSandbox ? '.' + org.Id : '');
    }

    private User queryUser(Id userId) {
        return [
            select 
                Id, FirstName, LastName, Email, Username, Alias, IsActive, 
                TimeZoneSidKey, EmailEncodingKey, LanguageLocaleKey, LocaleSidKey
            from User 
            where Id = :userId
        ];
    }

    private Id getDefaultProfileId(Auth.UserData data) {
        String profileName = null;

        if (isLocal) profileName = 'MoH Standard User';
        else if (isDbaacPortal) profileName = 'External Committee Community Users';
        else if (isSshibcPortal && isHibcStaff(data)) profileName = 'HIBC CCPlus Community Users';
        else if (isSshibcPortal && isServiceBcStaff(data)) profileName = 'Service BC CCPlus Community Users';
        
        try {
            return [select Id from Profile where Name = :profileName limit 1].Id;
        } catch (Exception e) {
            return null;
        }
    }

    private Boolean isHibcStaff(Auth.UserData data) {
        return rolesContain(data, 'HIBC_USER');
    }

    private Boolean isServiceBcStaff(Auth.UserData data) {
        return rolesContain(data, 'SERVICE_BC_USER');
    }

    private Set<String> getDataRoles(Auth.UserData data) {
        return KeycloakRolesTranslator.parseRoles(data.attributeMap.get('roles'));
    }

    private Boolean rolesContain(Auth.UserData data, String role) {
        return getDataRoles(data).contains(role);
    }

    private User buildUser(Auth.UserData data) {
        User user = new User();
        user.FederationIdentifier = data.username.substringBefore('@idir').toUpperCase();
        user.Email = data.email;
        user.FirstName = data.firstName;
        user.LastName = data.lastName;
        user.Alias = user.FirstName.left(1).toUpperCase()+user.LastName.capitalize();
        user.Keycloak_Roles__c = data.attributeMap.get('roles');
        return user;
    }

    private Contact buildContact(Auth.UserData data) {
        Contact record = new Contact();
        record.AccountId = isHibcStaff(data) ? hibc.Id : serviceBc.Id;
        record.FirstName = data.firstName;
        record.LastName = data.lastName;
        record.Email = data.email;
        return record;
    }
}
