public with sharing class FaxToCase {
    @InvocableMethod(label='Convert Fax to Case' description='Marks a fax file record as converted and moves its related file to the case record.')
    public static void convert(List<FaxAndCaseId> params) {
        attachFilesToCases(params);
        markFaxesAsConverted(params);
    }

    private static void attachFilesToCases(List<FaxAndCaseId> params) {
        Set<Id> faxIds = new Set<Id>();
        for (FaxAndCaseId param : params) {
            faxIds.add(param.faxId);
        }

        Map<Id, ContentDocumentLink> faxDocLinks = new Map<Id, ContentDocumentLink>();
        for (ContentDocumentLink cdl : queryContentDocumentLinks(faxIds)) {
            faxDocLinks.put(cdl.LinkedEntityId, cdl);    
        }

        List<ContentDocumentLink> caseDocLinks = new List<ContentDocumentLink>();
        for (FaxAndCaseId param : params) {
            if (!faxDocLinks.containsKey(param.faxId)) continue;
            
            ContentDocumentLink faxDocLink = faxDocLinks.get(param.faxId);

            ContentDocumentLink caseDocLink = new ContentDocumentLink();
            caseDocLink.LinkedEntityId = param.caseId;
            caseDocLink.ContentDocumentId = faxDocLink.ContentDocumentId;
            caseDocLink.ShareType = faxDocLink.ShareType;
            caseDocLink.Visibility = faxDocLink.Visibility;
            caseDocLinks.add(caseDocLink);
        }

        insert caseDocLinks;
    }

    private static List<ContentDocumentLink> queryContentDocumentLinks(Set<Id> faxIds) {
        return [
            select Id, LinkedEntityId, ContentDocumentId, ShareType, Visibility 
            from ContentDocumentLink
            where LinkedEntityId in :faxIds
        ];
    }

    private static void markFaxesAsConverted(List<FaxAndCaseId> params) {
        List<Fax_File__c> faxRecords = new List<Fax_File__c>();
        
        for (FaxAndCaseId param : params) {
            faxRecords.add(new Fax_File__c(Id=param.faxId, Status__c='Converted'));
        }

        update faxRecords;
    }

    public class FaxAndCaseId {
        @InvocableVariable(label='Fax record ID' description='Fax record ID.' required=true)
        public Id faxId;

        @InvocableVariable(label='Case record ID' description='Case record ID.' required=true)
        public Id caseId;
    }
}