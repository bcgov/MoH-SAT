/**********************************************************************************************
* @Author:      Accenture 
* @Date:        21 Nov 2024
* @Description: The purpose of this Trigger is to trigger on particular events
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
                21 Nov -  EDRD-             -  Accenture   -  Processes the Status category logic for after-insert triggers on OmniScriptSavedSession.
                08 Nov -  EDRD-             -  Accenture   -  Processes the Status category logic for after-insert triggers on OmniScriptSavedSession based on omniProcessId.
***********************************************************************************************/
trigger OmniScriptSavedSessionTrigger on OmniScriptSavedSession (after insert, after update) {
    if (Trigger.isAfter && Trigger.isInsert) {
       // OmniScriptSavedSessionTriggerHandler.processAfterInsert(Trigger.newMap.KeySet());
    } else if (Trigger.isAfter && Trigger.isUpdate) {
        //OmniScriptSavedSessionTriggerHandler.processAfterInsert(Trigger.newMap, Trigger.oldMap);
        OmniScriptSavedSessionTriggerHandler.processAfterInsertByOmniScriptId(Trigger.newMap, Trigger.oldMap);
    }
}