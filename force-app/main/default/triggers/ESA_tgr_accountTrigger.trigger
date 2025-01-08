/**********************************************************************************************
* @Author:      Deepak 
* @Date:        09 Mar 2023
* @Description: The purpose of this Trigger is to trigger on particular events
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
                11 Nov -  EDRD-82           -  Accenture   -  Added Close Case method on Account Inactive
                20 Dec -  EDRD-1150         -  Accenture   -  Adding/Removing - Provider/Reviewer to public groups based on Committees. 
***********************************************************************************************/
trigger ESA_tgr_accountTrigger on account (after insert, after update) {
    
    if (trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
        
        if(trigger.isInsert){
            ESA_cls_accountTriggerHandler.populateSpecialty(trigger.new, NULL, NULL);
        }
        if(trigger.isUpdate){
            ESA_cls_accountTriggerHandler.populateSpecialty(trigger.new, trigger.newMap, trigger.oldMap);
            ESA_cls_accountTriggerHandler.closeCaseOnAccDeceased(trigger.new, trigger.oldMap, trigger.newMap);
            ESA_cls_accountTriggerHandler.handlePublicGroupMemberships(trigger.oldMap, trigger.newMap);
        }
    }
}