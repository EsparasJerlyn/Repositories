trigger ContentDocumentLinkTrigger on ContentDocumentLink(before insert) {
    TriggerDispatcher.dispatch(
        TriggerHandlerFactory.getHandlersForSObjectType('ContentDocumentLink'),
        Trigger.operationType
    );
}