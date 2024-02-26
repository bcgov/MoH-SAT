/**********************************************************************************************
* @Author:Accenture   
* @Date:30/01/2024       
* @Description: The purpose of this Trigger is to trigger on particular events for CareProgramEnrollee
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]  
***********************************************************************************************/
trigger CarePgmEnrolleeTrigger on CareProgramEnrollee (before insert) {
	CarePgmEnrolleeTriggerHandler.updateEnrolleeName(trigger.new);
}