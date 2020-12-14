public with sharing class ApexBasedAdjudication extends AdjudicationStrategy {

    public ApexBasedAdjudication(SpecialAuthorityRequest sar) {
        super(sar);
    }

    public override void evaluate() {
        system.debug('apex based adjudication');
    }
}
