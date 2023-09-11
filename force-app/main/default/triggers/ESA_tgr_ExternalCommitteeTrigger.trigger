trigger ESA_tgr_ExternalCommitteeTrigger on External_Committee__c (before insert,after insert) {
    if (Trigger.isBefore && Trigger.isInsert){
        ESA_cls_ExternalCommitteeTriggerHandler.validateBeforeClone(Trigger.new);
    }
    if (Trigger.isAfter && Trigger.isInsert){ 
        if(ESA_cls_ExternalCommitteeTriggerHandler.cloneOpenCases_runsOne){
            ESA_cls_ExternalCommitteeTriggerHandler.cloneOpenCases(Trigger.new);   
        }
    }  
    
}