public with sharing class Steps {
    private List<Step__c> steps;
    
    public Steps(List<Step__c> steps) {
        this.steps = steps;
    }

    public void setExternalIds() {
        Map<Id, Drug__c> drugs = queryDrugs(steps);

        for (Step__c step : steps) {
            if (String.isBlank(step.External_ID__c)) {
                step.External_ID__c = formatExternalId(
                    drugs.get(step.Drug__c).Drug_Code__c,
                    step.Order__c.intValue(),
                    step.Name
                );
            }
        }
    }

    public static String formatExternalId(String drugCode, Integer order, String name) {
        return String.format(
            '{0}_{1}_{2}', new String[] {
            drugCode,
            String.valueOf(order),
            name
        }).replaceAll('[^a-zA-Z\\d]+', '_');
    }

    private Map<Id, Drug__c> queryDrugs(List<Step__c> steps) {
        Set<Id> drugIds = new Set<Id>();

        for (Step__c step : steps) {
            if (String.isBlank(step.External_ID__c)) {
                drugIds.add(step.Drug__c);
            }
        }

        return queryDrugs(drugIds);
    }

    private Map<Id, Drug__c> queryDrugs(Set<Id> recordIds) {
        return new Map<Id, Drug__c>([select Id, Drug_Code__c from Drug__c where Id in :recordIds]);
    }
}
