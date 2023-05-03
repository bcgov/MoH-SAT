public with sharing class KeycloakRolesTranslator {
    
    @InvocableMethod(label='Apply Permission Sets' description='Applies permission sets on user.')
    public static void translateUserRoles() {

        try {

            User user = [select Id, Keycloak_Roles__c, ProfileId, Profile.Name from User where Id = :UserInfo.getUserId()];

            List<PermissionSet> permissionSets = new List<PermissionSet>();
            permissionSets.addAll(getDefaultPermissionSets(user.Profile.Name));
            permissionSets.addAll(getPermissionSets(user.Keycloak_Roles__c));

            List<PermissionSetAssignment> psas = new List<PermissionSetAssignment>();
            
            if(!permissionSets.isEmpty()){
                for (PermissionSet ps : permissionSets) {
                    psas.add(new PermissionSetAssignment(
                        PermissionSetId = ps.Id,
                        AssigneeId=UserInfo.getUserId()
                    ));
                }
            }

            removeExistingPermsets();
            if(!psas.isEmpty()){
                insert psas;
            }
        } catch (Exception e) {
            System.debug('Exception has occured'+e.getMessage());
        }
    }

    public static Set<String> parseRoles(String keycloakRoles) {
        List<String> listResult = keycloakRoles?.substringBetween('[', ']')?.split(',\\s*');
        Set<String> result = listResult == null ? new Set<String>() : new Set<String>(listResult);
        
        result.remove(null);
        result.remove('');
        
        return result; 
    }

    private static List<PermissionSet> getDefaultPermissionSets(String profileName) {
        Set<String> permissionSetNames = new Set<String>();
        permissionSetNames.add('Multi_Factor_Authentication');
        permissionSetNames.addAll(PROFILE_PERMSETS.get(profileName));
        permissionSetNames.remove(null);

        return [select Id from PermissionSet where IsOwnedByProfile=false and IsCustom=true and Name = :permissionSetNames];
    }

    private static List<PermissionSet> getPermissionSets(String keycloakRoles) {
        Set<String> permsetNames = new Set<String>();
        for (String role : parseRoles(keycloakRoles)) {
            permsetNames.add(KC_ROLES_PERMSETS.get(role.toLowerCase()));
        }

        permsetNames.remove(null);

        return permsetNames == null ? 
            new PermissionSet[]{} : 
            [select Id from PermissionSet where IsOwnedByProfile=false and IsCustom=true and Name = :permsetNames];
    }

    private static List<String> getExternallyManagedPermissionSets() {
        return new String[]{
            'sa_drug_manager', 
            'sa_administrator', 
            'sa_reports_dashboards',
            'MoH_Standard_User',
            'External_Committee_User_Permission',
            'HIBC_CCplus_Community_User_Permission',
            'Multi_Factor_Authentication'
        };
    }

    private static void removeExistingPermsets() {
        List<PermissionSetAssignment> permissionSetLst = [select Id from PermissionSetAssignment where AssigneeId = :UserInfo.getUserId() and PermissionSet.Name in :getExternallyManagedPermissionSets()];
        
        if(!permissionSetLst.isEmpty()){
            delete permissionSetLst;
        } 
    }

    private static final Map<String, List<String>> PROFILE_PERMSETS = new Map<String, List<String>>{
        'System Administrator' => new String[] {
            'MoH_Standard_User'
        },
        'MoH Standard User' => new String[] {
            'MoH_Standard_User'
        },
        'External Committee Community Users' => new String[] {
            'External_Committee_User_Permission'
        }, 
        'HIBC CCPlus Community Users' => new String[] {
            'HIBC_CCplus_Community_User_Permission'
        },
        'Service BC CCPlus Community Users' => new String[] {
            'HIBC_CCplus_Community_User_Permission'
        }
    };

    private static final Map<String, String> KC_ROLES_PERMSETS = new Map<String, String> {
        'sa_drug_manager' => 'sa_drug_manager',
        'sa_administrator' => 'sa_administrator',
        'sa_reports_dashboard' => 'sa_reports_dashboards'
    };

}
