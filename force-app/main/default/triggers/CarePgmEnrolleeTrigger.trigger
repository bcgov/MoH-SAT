/**********************************************************************************************
* @Author:Accenture   
* @Date:30/01/2024       
* @Description: The purpose of this Trigger is to trigger on particular events for CareProgramEnrollee
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]  
               30-Jan24     EDRD-624           Accenture      update the name based on record count 
               11-Jul24     EDRD-764           Accenture      update the Account Ref. No based on CPE Name
***********************************************************************************************/
trigger CarePgmEnrolleeTrigger on CareProgramEnrollee (before insert, after insert) {
    if(trigger.isInsert && trigger.isBefore){
        CarePgmEnrolleeTriggerHandler.updateEnrolleeName(trigger.new);
    }
	if(trigger.isInsert && trigger.isAfter){
        CarePgmEnrolleeTriggerHandler.updateEnrolleeNameOnAcc(trigger.new);
    }
}