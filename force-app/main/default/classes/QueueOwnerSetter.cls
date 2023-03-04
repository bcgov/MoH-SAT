public inherited sharing class QueueOwnerSetter {
    public class QueueOwnerSetterException extends Exception {}

    @InvocableMethod(label='Set Owner to Queue' description='Sets the record owner to a queue.')
    public static void setOwner(List<CaseQueue> caseQueues) {
        Map<Id, Case> cases = queryCases(getcaseIds(caseQueues));
        Map<String, Group> groups = queryGroups(getQueueNames(caseQueues));
        
        for (CaseQueue cq : caseQueues) {
            cases.get(cq.caseId).OwnerId = 
                groups.containsKey(cq.queueName) ? 
                groups.get(cq.queueName).Id : 
                cases.get(cq.caseId).OwnerId;
        }

        update cases.values();
    }

    private static Set<Id> getCaseIds(List<CaseQueue> caseQueues) {
        Set<Id> caseIds = new Set<Id>();

        for (CaseQueue cq : caseQueues) {
            caseIds.add(cq.caseId);
        }

        return caseIds;
    }

    private static Set<String> getQueueNames(List<CaseQueue> caseQueues) {
        Set<String> queueNames = new Set<String>();

        for (CaseQueue cq : caseQueues) {
            queueNames.add(cq.queueName);
        }

        return queueNames;
    }

    private static Map<Id, Case> queryCases(Set<Id> caseIds) {
        return new Map<Id, Case>([select Id, OwnerId from Case where Id in :caseIds]);
    }

    private static Map<String, Group> queryGroups(Set<String> apiNames) {
        Map<String, Group> groupsMap = new Map<String, Group>();

        for (Group g : [select Id, DeveloperName from Group where Type='Queue' and DeveloperName in :apiNames]) {
            groupsMap.put(g.DeveloperName, g);
        }

        return groupsMap;
    }

    public class CaseQueue {
        @InvocableVariable(label='Case ID' required=true)
        public Id caseId;
        
        @InvocableVariable(label='Queue API Name' required=true description='API or Developer Name of the Queue')
        public String queueName;
    }
}