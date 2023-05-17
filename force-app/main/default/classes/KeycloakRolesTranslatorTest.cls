@isTest
public with sharing class KeycloakRolesTranslatorTest {

    @isTest
    static void test_parse_roles_negative_input() {
        Set<String> roles = new Set<String>();

        roles = KeycloakRolesTranslator.parseRoles(null);
        system.assertEquals(0, roles.size());

        roles = KeycloakRolesTranslator.parseRoles('');
        system.assertEquals(0, roles.size());

        roles = KeycloakRolesTranslator.parseRoles('[]');
        system.assertEquals(0, roles.size());

        roles = KeycloakRolesTranslator.parseRoles('ROLE]');
        system.assertEquals(0, roles.size());

        roles = KeycloakRolesTranslator.parseRoles('[ROLE');
        system.assertEquals(0, roles.size());
    }

    @isTest
    static void test_parse_roles() {
        Set<String> roles = new Set<String>();

        roles = KeycloakRolesTranslator.parseRoles('[ROLE1]');
        system.assertEquals(1, roles.size());
        system.assert(roles.contains('ROLE1'));
    
        roles = KeycloakRolesTranslator.parseRoles('[ROLE1, ROLE2,ROLE3,    ROLE_4]');
        system.assertEquals(4, roles.size());
        system.assert(roles.contains('ROLE1'));
        system.assert(roles.contains('ROLE2'));
        system.assert(roles.contains('ROLE3'));
        system.assert(roles.contains('ROLE_4'));
    }

    @isTest
    static void test_assign_permsets() {
        User me = new User();
        me.Id = UserInfo.getUserId();
        me.Keycloak_Roles__c = '[SA_DRUG_MANAGER, SA_ADMINISTRATOR]';
        update me;
        
        removePermissionSets(me.Id);

        Test.startTest();
        KeycloakRolesTranslator.translateUserRoles();
        Test.stopTest();

        Set<String> psas = getPermissionSets(me.Id);

        system.assert(psas.contains('multi_factor_authentication'));
        system.assert(psas.contains('moh_standard_user'));
        system.assert(psas.contains('sa_drug_manager'));
        system.assert(psas.contains('sa_administrator'));
    }

    private static void removePermissionSets(Id userId) {
        delete [
            select Id 
            from PermissionSetAssignment 
            where AssigneeId = :UserInfo.getUserId()
            and PermissionSet.IsOwnedByProfile=false 
            and PermissionSet.IsCustom=true
        ];
    }

    private static Set<String> getPermissionSets(Id userId) {
        Set<String> result = new Set<String>();

        List<PermissionSetAssignment> psas = [
            select Id, PermissionSet.Name 
            from PermissionSetAssignment 
            where AssigneeId = :userId
            and PermissionSet.IsOwnedByProfile=false 
            and PermissionSet.IsCustom=true
        ];

        for (PermissionSetAssignment psa : psas) {
            result.add(psa.PermissionSet.Name.toLowerCase());
        }

        return result;
    }
}
