public with sharing class CriteriaBasedAdjudication extends AdjudicationStrategy {

    public override void evaluate(SpecialAuthorityRequest sar) {
        Drug__c drug = queryDrug(sar.drug.Id);

        Map<Integer, AdjudicationCriteria> criteriaMap = buildAdjudicationCriteria(drug, sar);

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

    private Map<Integer, AdjudicationCriteria> buildAdjudicationCriteria(Drug__c drug, SpecialAuthorityRequest sar) {
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

    private Drug__c queryDrug(Id drugId) {
        return [
            select Id, Criteria_Logic__c, (
                select 
                    Order__c, Object_Name__c, Field_Name__c, Question_ID__c, Operator__c,
                    String_Value__c, Boolean_Value__c, Decimal_Value__c, Date_Value__c, Datetime_Value__c
                    from Adjudication_Criteria__r
                    order by Order__c asc 
            )            
            from Drug__c 
            where Id = :drugId
        ];
    }

}
