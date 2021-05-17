public with sharing class Adjudication implements AdjudicationAction {
    public void execute(SpecialAuthorityRequest sar, StepAction actionParams) {
        system.debug('EXEC: Adjudication');
    }
}
