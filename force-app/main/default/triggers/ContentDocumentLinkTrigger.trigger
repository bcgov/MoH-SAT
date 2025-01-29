trigger ContentDocumentLinkTrigger on ContentDocumentLink (before insert, after insert) {
    if(trigger.isbefore && trigger.isInsert){
        for(ContentDocumentLink l:Trigger.new) {
            l.Visibility = 'AllUsers';
        }
    }
    if(trigger.isafter && trigger.isInsert){
        ContentDocumentLinkTriggerHandler.getDocumentGenerated(trigger.new);
    }    
}