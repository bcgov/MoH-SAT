public virtual class AdjudicationStrategy {

    public AdjudicationStrategy() {
    }

    public virtual void runEvaluate(SpecialAuthorityRequest sar) {
        evaluate(sar);
    }

    public virtual void evaluate(SpecialAuthorityRequest sar) {
        system.debug('default strategy');
        return;
    }
}
