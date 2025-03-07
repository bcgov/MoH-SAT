/**********************************************************************************************
* @Author:    Accenture
* @Date:       19-12-2024
* @Description: The purpose of this Trigger is to trigger on particular events
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
                19 Dec -  EDRD- 309         -  Accenture   -  Populate Name on Service Appointment
                08 Feb -   EDRD-338		    -  Accenture   -  method is to Prevent users from selecting the Account records other than committee for EDRD Meetings.
***********************************************************************************************/
trigger ServiceAppointmentTrigger on ServiceAppointment (before insert, before update) {
    
    if(trigger.isBefore && trigger.isInsert){
        ServiceAppointmentTriggerHandler.insertSAName(trigger.new);
        ServiceAppointmentTriggerHandler.validateEDRDCommitteeMeeting(Trigger.new);
    }
    if(trigger.isBefore && trigger.isupdate){
        ServiceAppointmentTriggerHandler.updateSAName(trigger.new, trigger.oldMap);
    }
}