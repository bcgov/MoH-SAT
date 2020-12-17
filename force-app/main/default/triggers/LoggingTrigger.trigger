// Trigger for catching Logging_Event events.
trigger LoggingTrigger on Logging_Event__e (after insert) {
  // List to hold all cases to be created.
  List<Integration_Log__c> logs = new List<Integration_Log__c>();

  // Iterate through each notification.
  for (Logging_Event__e event : Trigger.New) {
      System.debug('Logging Event: ' + event.caseId__c);
      // Create Log to reflect uevent.
      Integration_Log__c integrationLogObject = new Integration_Log__c (
          Code__c = event.code__c,
          Message__c = event.message__c,
          SA_Request__c = event.caseId__c,
          Type__c = event.type__c,
          Timestamp__c  = Datetime.now()
      );
      logs.add(integrationLogObject);
  }

  // Insert all logs in the list.
  if (logs.size() > 0) {
      insert logs;
  }
}