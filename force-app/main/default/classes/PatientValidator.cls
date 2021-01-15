public abstract class PatientValidator implements AdjudicationAction {
    public void execute(SpecialAuthorityRequest sar) {
        if (sar.saCase.Patient_Validated_Date__c != null) {
            // Skip
            return;
        }

        PatientInformation p = ODRIntegration.verifyPatientInformation(sar.patient.Id, false);

        sar.saCase.Patient_Validated__c = p.verified;
        sar.saCase.Patient_Validated_Date__c = DateTime.now();
    }
}