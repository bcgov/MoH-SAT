/**********************************************************************************************
* @Author:      Accenture 
* @Date:        21 Aug 2024
* @Description: The purpose of this Trigger is to trigger on particular events
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]
                21 Aug -  EDRD-911          -  Accenture   -  Added Patient Share/delete With Provider User
                13 Dec -  EDRD-1150         -  Accenture   -  The purpose of this method is to update Committee based on ACR insert of EDRD_Committee & Provider OR Committee_Reviewer.
                20 Dec -  EDRD-1150         -  Accenture   -  The purpose of this method is to Remove Committee based on ACR delete of EDRD_Committee & Provider OR Committee_Reviewer.
***********************************************************************************************/
trigger AccountContactRelationTrigger on AccountContactRelation (after insert, after update, after delete) {
    
    if(trigger.isInsert && trigger.isAfter){
        AccountContactRelationTriggerHandler.createPatientShare(trigger.new);
        AccountContactRelationTriggerHandler.updateCommitteeFieldOnACRInsert(trigger.new);
    }
    
    if(trigger.isUpdate && trigger.isAfter){
        AccountContactRelationTriggerHandler.updatePatientShare(trigger.oldMap, trigger.newMap);
    }
    
    if(trigger.isDelete && trigger.isAfter){
        AccountContactRelationTriggerHandler.removeCommitteeFieldOnACRDelete(trigger.old);
        AccountContactRelationTriggerHandler.removePatientShare(trigger.old);        
    }
    
}