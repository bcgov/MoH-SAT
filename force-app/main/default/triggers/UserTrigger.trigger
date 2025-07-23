/**********************************************************************************************
* @Author:      Accenture 
* @Date:        24 Sept 2024
* @Description: The purpose of this Trigger is to trigger on particular events on user
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]
                24 Sep -  EDRD-911          -  Accenture   -  Added activateACROnEDRDportalEnable method
                07Jan -   EDRD-1150         -  Accenture   -  Added handleEDRDPublicGroupMember method
                07Jan -   EDRD-1150         -  Accenture   -  Added handleGroupsForUsersAsync method
                02 Jul -  EDRD-1523		    -  Accenture   -  Method is to create Group MemberShip for Allied Staff Role User based on ACR.
***********************************************************************************************/
trigger UserTrigger on User (after insert) { 
    
    if(trigger.isInsert && trigger.isAfter){
        UserTriggerHandler.activateACROnEDRDPortalEnable(trigger.new);
        UserTriggerHandler.handleEDRDPublicGroupMember(trigger.new);
        UserTriggerHandler.createGMForAlliedStaffRoleACRUsers(trigger.new);        
    }    
}