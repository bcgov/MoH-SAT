delete [select id from ContentDistribution];

Set<Id> docIds = new Set<Id>();
for (ContentDocumentLink cdl : [
    select ContentDocumentId 
    from ContentDocumentLink 
    where LinkedEntityId in (select Id from Case where RecordType.DeveloperName = 'Special_Authority_Request')
	and ContentDocumentId in (select Id from ContentDocument where ContentAssetId = null)
]) {
    docIds.add(cdl.ContentDocumentId);
}

List<ContentVersion> cvs = [
    select Id, Title
    from ContentVersion 
    where ContentDocumentId in :docIds
    and Id not in (select ContentVersionId from ContentDistribution)
];

List<ContentDistribution> cds = new List<ContentDistribution>();
for (ContentVersion cv : cvs) {
    cds.add(ContentTriggerHandler.createContentDistribution(cv.Id, cv.Title));
}

insert cds;
