public class PatientValidator implements Action {
    
    @TestVisible
    private Patient mockResult { get; set; }

    public ActionResult execute(SpecialAuthorityRequest sar, StepAction actionParams) {
        // if (sar.saCase.Patient_Validated_Date__c != null) {
        //     return;
        // }

        if (sar.saCase.Patient_Validated__c) {
            return new ActionResult().setValidationResult(true);
        }

        Patient p = callService(sar);

        if (p != null) {
            system.debug('P.verified' + p);
            sar.saCase.Patient_Validated__c = p.verified;
            sar.saCase.Patient_Validated_Date__c = DateTime.now();
            return new ActionResult().setValidationResult(p.verified);
        }

        return new ActionResult().setValidationResult(false);

    }

    private Patient callService(SpecialAuthorityRequest sar) {
        return Test.isRunningTest() ? mockResult : ODRIntegration.verifyPatientInformation(sar);
    }
}