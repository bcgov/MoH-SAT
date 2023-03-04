@IsTest
public with sharing class IdirRegistrationHandlerTest {

    @testSetup
    static void test_setup() {
        List<Account> accounts = new List<Account>();
        accounts.add(TestFactory.newAccount('Service BC (SBC) Call Centre'));
        accounts.add(TestFactory.newAccount('HIBC HelpDesk'));
        insert accounts;
    }

    @isTest
    static void test_local_user_create() {
        Auth.UserData data = newUserData('test-keycloak-guid', 'test', new String[] {'MOH_USER', 'TEST_ROLE_1'});
        IdirRegistrationHandler handler = new IdirRegistrationHandler();

        Test.startTest();
        User newuser = handler.createUser(null, data);
        Test.stopTest();

        assertUser(data, newuser);
        system.assertEquals(true, newuser.UserPermissionsSupportUser);
        system.assertEquals([select Id from Profile where Name = 'MoH Standard User' limit 1].Id, newuser.ProfileId);
        system.assertEquals(null, newuser.ContactId);
    }

    @isTest
    static void test_sbc_user_create() {
        Auth.UserData data = newUserData('test-keycloak-guid', 'test', new String[] {'SERVICE_BC_USER', 'TEST_ROLE_1'});
        
        IdirRegistrationHandler handler = new IdirRegistrationHandler();
        handler.isLocal = false;
        handler.isSshibcPortal = true;
        handler.isDbaacPortal = false;

        Test.startTest();
        User newuser = handler.createUser(null, data);
        Test.stopTest();

        assertUser(data, newuser);
        system.assertEquals(false, newuser.UserPermissionsSupportUser);
        system.assertEquals([select Id from Profile where Name = 'Service BC CCPlus Community Users' limit 1].Id, newuser.ProfileId);
        system.assertNotEquals(null, newuser.ContactId);
        system.assertEquals(
            [select Id, Name from Account where Name in ('Service BC (SBC) Call Centre', 'Service BC') limit 1].Id, 
            [select Id from Account where Id in (select AccountId from Contact where Id = :newuser.ContactId)].Id
        );
    }

    @isTest
    static void test_hibc_user_create() {
        Auth.UserData data = newUserData('test-keycloak-guid', 'test', new String[] {'HIBC_USER', 'TEST_ROLE_1'});

        IdirRegistrationHandler handler = new IdirRegistrationHandler();
        handler.isLocal = false;
        handler.isSshibcPortal = true;
        handler.isDbaacPortal = false;

        Test.startTest();
        User newuser = handler.createUser(null, data);
        Test.stopTest();

        assertUser(data, newuser);
        system.assertEquals(false, newuser.UserPermissionsSupportUser);
        system.assertEquals([select Id from Profile where Name = 'HIBC CCPlus Community Users' limit 1].Id, newuser.ProfileId);
        system.assertEquals(
            [select Id, Name from Account where Name in ('HIBC HelpDesk', 'HIBC') limit 1].Id, 
            [select Id from Account where Id in (select AccountId from Contact where Id = :newuser.ContactId)].Id
        );
    }

    @isTest
    static void test_create_user_error_no_default_profile() {
        Auth.UserData data = newUserData('test-keycloak-guid', 'test', new String[] {'MOH_USER', 'TEST_ROLE_1'});

        IdirRegistrationHandler handler = new IdirRegistrationHandler();
        handler.isLocal = false;
        handler.isSshibcPortal = false;
        handler.isDbaacPortal = false;

        Test.startTest();
        try {
            handler.createUser(null, data);
            system.assert(false, 'An expected exception was not thrown.');
        } catch (IdirRegistrationHandler.IdirRegistrationHandlerException error) {
            system.assert(error.getMessage().contains('Unable to find a default profile for this user.'));
        }            
        Test.stopTest();
    }

    @isTest
    static void test_create_user_error_missing_base_roles_from_keycloak() {
        Auth.UserData data = newUserData('test-keycloak-guid', 'test', new String[] {'TEST_ROLE_1'});

        IdirRegistrationHandler handler = new IdirRegistrationHandler();
        handler.isLocal = true;
        handler.isSshibcPortal = false;
        handler.isDbaacPortal = false;

        Test.startTest();
        try {
            handler.createUser(null, data);
            system.assert(false, 'An expected exception was not thrown.');
        } catch (IdirRegistrationHandler.IdirRegistrationHandlerException error) {
            system.assert(error.getMessage().contains('User does not have any Keycloak roles for this application.'));
        }            
        Test.stopTest();
    }

    @isTest
    static void test_local_user_update() {
        Auth.UserData data = newUserData('test-keycloak-guid', 'test', new String[] {'MOH_USER', 'TEST_ROLE_1'});
        
        IdirRegistrationHandler handler = new IdirRegistrationHandler();

        User newuser = handler.createUser(null, data);
        insert newuser;

        Test.startTest();
        data = newUserData('test-keycloak-guid', 'test', new String[] {'MOH_USER', 'TEST_ROLE_1', 'TEST_ROLE_2'});
        handler.updateUser(newuser.Id, null, data);
        Test.stopTest();
        
        system.assertEquals(
            '[MOH_USER, TEST_ROLE_1, TEST_ROLE_2]', 
            [select Keycloak_Roles__c from User where Id = :newuser.Id].Keycloak_Roles__c
        );
    }

    @isTest
    static void test_community_user_update() {
        Auth.UserData data = newUserData('test-keycloak-guid', 'test', new String[] {'SERVICE_BC_USER', 'TEST_ROLE_1'});
        
        IdirRegistrationHandler handler = new IdirRegistrationHandler();
        handler.isLocal = false;
        handler.isSshibcPortal = true;
        handler.isDbaacPortal = false;

        User newuser = handler.createUser(null, data);
        insert newuser;
        
        Test.startTest();
        
        data = newUserData('test-keycloak-guid', 'test', new String[] {'SERVICE_BC_USER', 'TEST_ROLE_1', 'TEST_ROLE_2'});
        
        system.runAs(new User(Id=UserInfo.getUserId())) {
            handler.updateUser(newuser.Id, null, data);
        }
        
        Test.stopTest();
        
        system.assertEquals(
            '[SERVICE_BC_USER, TEST_ROLE_1, TEST_ROLE_2]', 
            [select Keycloak_Roles__c from User where Id = :newuser.Id].Keycloak_Roles__c
        );
    }

    private static Auth.UserData newUserData(String identifier, String firstname, List<String> roles) {
        Map<String, String> attributeMap = new Map<String, String>();
        attributeMap.put('email', firstname+'.LastName@example.com');
        attributeMap.put('family_name', 'LastName');
        attributeMap.put('given_name', firstname);
        attributeMap.put('preferred_username', firstname+'@idir');
        attributeMap.put('name', firstName + ' LastName');
        attributeMap.put('roles', '[' + String.join(roles, ', ') + ']');
        attributeMap.put('email_verified', 'false');
        attributeMap.put('sub', identifier);

        return new Auth.UserData(
            attributeMap.get(identifier),
            attributeMap.get('given_name'),
            attributeMap.get('family_name'),
            attributeMap.get('name'),
            attributeMap.get('email'),
            null,
            attributeMap.get('preferred_username'),
            null,
            'Open ID Connect',
            null,
            attributeMap
        );
    }

    private static Organization getOrg() {
        return [select Id, IsSandbox from Organization limit 1];
    }
    
    private static void assertUser(Auth.UserData data, User newuser) {
        Organization org = getOrg();
        
        system.assertEquals(true, newuser.IsActive);
        system.assertEquals('America/Los_Angeles', newuser.TimeZoneSidKey);
        system.assertEquals('UTF-8', newuser.EmailEncodingKey);
        system.assertEquals('en_US', newuser.LanguageLocaleKey);
        system.assertEquals('en_CA', newuser.LocaleSidKey);
        system.assertEquals(data.email + (org.IsSandbox ? '.' + org.Id : ''), newuser.Username);
        system.assertEquals(data.username.substringBefore('@idir').toUpperCase(), newuser.FederationIdentifier);
        system.assertEquals(data.email, newuser.Email);
        system.assertEquals(data.firstName, newuser.FirstName);
        system.assertEquals(data.lastName, newuser.LastName);
        system.assertEquals(data.attributeMap.get('roles'), newuser.Keycloak_Roles__c);
        system.assert(String.isNotBlank(newuser.Alias));
    }
}