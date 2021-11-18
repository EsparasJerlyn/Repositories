trigger ContentVersionTrigger on ContentVersion (before insert, before update) {


  TriggerDispatcher.dispatch(
    TriggerHandlerFactory.getHandlersForSObjectType('ContentVersion'), 
    Trigger.operationType
 );


}