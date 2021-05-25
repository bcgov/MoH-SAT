public class PatientValidator implements Action {
    public void execute(SpecialAuthorityRequest sar, StepAction actionParams) {
        if (sar.saCase.Patient_Validated_Date__c != null) {
            return;
        }

        Patient p = ODRIntegration.verifyPatientInformation(sar);

        if (p != null) {
            sar.saCase.Patient_Validated__c = p.verified;
            sar.saCase.Patient_Validated_Date__c = DateTime.now();
        }
    }
}