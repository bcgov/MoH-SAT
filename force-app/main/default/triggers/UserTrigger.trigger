/**********************************************************************************************
* @Author:      Accenture 
* @Date:        24 Sept 2024
* @Description: The purpose of this Trigger is to trigger on particular events on user
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]
                24 Sep -  EDRD-911          -  Accenture   -  Added activateACROnEDRDportalEnable method
                07Jan -   EDRD-1150         -  Accenture   -  Added handleEDRDPublicGroupMember method
                07Jan -   EDRD-1150         -  Accenture   -  Added handleGroupsForUsersAsync method
***********************************************************************************************/
trigger UserTrigger on User (after insert) { 
    
    if(trigger.isInsert && trigger.isAfter){
        UserTriggerHandler.activateACROnEDRDPortalEnable(trigger.new);
        UserTriggerHandler.handleEDRDPublicGroupMember(trigger.new);
    }    
}