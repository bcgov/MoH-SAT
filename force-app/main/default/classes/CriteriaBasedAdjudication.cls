public with sharing class CriteriaBasedAdjudication extends AdjudicationStrategy {

    public CriteriaBasedAdjudication(SpecialAuthorityRequest sar) {
        super(sar);
    }

    public override void evaluate() {
        Map<Integer, AdjudicationCriteria> criteriaMap = buildAdjudicationCriteria();

        Expression expr = Parser.parse(drug.Criteria_Logic__c);

        for (Integer orderInt : criteriaMap.keySet()) {
            String orderStr = String.valueOf(orderInt);
            Boolean result = criteriaMap.get(orderInt).evaluate();

            expr.set(String.valueOf(orderInt), criteriaMap.get(orderInt).evaluate());
        }

        if (expr.evaluate()) {
            sar.saCase.Status = 'Approved';
        }
    }

    private Map<Integer, AdjudicationCriteria> buildAdjudicationCriteria() {
        Map<Integer, AdjudicationCriteria> criteriaMap = new Map<Integer, AdjudicationCriteria>();

        for (Adjudication_Criteria__c acObj : drug.Adjudication_Criteria__r) {
            criteriaMap.put(Integer.valueOf(acObj.Order__c), new AdjudicationCriteria(acObj));
        }

        for (AdjudicationCriteria ac : criteriaMap.values()) {
            ac.set(sar.saCase);

            for (Request_Detail__c rd : sar.requestDetails) {
                ac.set(rd);
            }
        }

        return criteriaMap;
    }

}
