
trigger ApplicationPreferenceTrigger on Application_Preference__c (after insert, after update) {
    TriggerDispatcher.dispatch(
        TriggerHandlerFactory.getHandlersForSObjectType('Application_Preference__c'),
        Trigger.operationType
      );
}