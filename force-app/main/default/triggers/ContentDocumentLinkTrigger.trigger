trigger ContentDocumentLinkTrigger on ContentDocumentLink (before insert) {
  for(ContentDocumentLink l:Trigger.new) {
    l.Visibility = 'AllUsers';
  }
}