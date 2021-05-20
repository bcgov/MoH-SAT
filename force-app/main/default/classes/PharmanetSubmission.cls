public with sharing class PharmanetSubmission implements Action {
    public void execute(SpecialAuthorityRequest sar, StepAction actionParams) {
        system.debug('EXEC: Pharmanet Submission.');
        
        sar.addSaApprovalRequest(
            actionParams.pharmanetCode, 
            actionParams.keyType, 
            actionParams.saType, 
            actionParams.pricePercent, 
            actionParams.daysSupply, 
            actionParams.duration, 
            actionParams.durationUnit, 
            actionParams.excludedPlans, 
            actionParams.justificationCodes
        );
    }
}
