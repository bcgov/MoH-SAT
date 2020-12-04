public virtual class AdjudicationStrategy {

    public AdjudicationStrategy() {
    }

    public virtual void runEvaluate(SpecialAuthorityRequest sar) {
        if (sar.drug == null || sar.saCase.isClosed) return;
        
        evaluate(sar);
    }

    public virtual void evaluate(SpecialAuthorityRequest sar) {
        system.debug('default strategy');
        return;
    }
}
