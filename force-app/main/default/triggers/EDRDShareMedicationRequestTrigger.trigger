trigger EDRDShareMedicationRequestTrigger on MedicationRequest (after insert) {
    if (Trigger.isAfter && Trigger.isInsert) {
        EDRDMedicationReqwithACRHandler.shareMedicationRequestsWithPatientAccount(Trigger.new);
    }
}