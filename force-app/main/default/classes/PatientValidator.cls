public class PatientValidator implements Action {
    
    @TestVisible
    private Patient mockResult { get; set; }

    public void execute(SpecialAuthorityRequest sar, StepAction actionParams) {
        if (sar.saCase.Patient_Validated_Date__c != null) return;

        Patient p = callService(sar);

        if (p != null) {
            sar.saCase.Patient_Validated__c = p.verified;
            sar.saCase.Patient_Validated_Date__c = DateTime.now();
        }
    }

    private Patient callService(SpecialAuthorityRequest sar) {
        return Test.isRunningTest() ? mockResult : ODRIntegration.verifyPatientInformation(sar);
    }
}