public class PatientValidator implements AdjudicationAction {
    public void execute(SpecialAuthorityRequest sar) {
        if (sar.saCase.Patient_Validated_Date__c != null) {
            // Skip
            return;
        }

        Patient p = ODRIntegration.verifyPatientInformation(sar);

        // TODO: Enable timestamping when EMPI is available.
        if (false && p != null) {
            sar.saCase.Patient_Validated__c = p.verified;
            sar.saCase.Patient_Validated_Date__c = DateTime.now();
        }
    }
}