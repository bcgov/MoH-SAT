// Trigger for catching Fax_Event__e events.
trigger FaxEventTrigger on Fax_Event__e (after insert) {
  // List to hold all cases to be created.
  List<Fax_Log__c> logs = new List<Fax_Log__c>();

  // Iterate through each notification.
  for (Fax_Event__e event : Trigger.New) {
      System.debug('Logging Event: ' + event.caseId__c);
      // Create Log to reflect uevent.
      Fax_Log__c faxLogObject = new Fax_Log__c (
        Case__c = event.caseId__c,
        Sent_By__c = event.sentBy__c,
        Template__c = event.template__c,
        Date_Sent__c = event.dateSent__c
      );
      logs.add(faxLogObject);
  }

  // Insert all logs in the list.
  if (logs.size() > 0) {
      insert logs;
  }
}