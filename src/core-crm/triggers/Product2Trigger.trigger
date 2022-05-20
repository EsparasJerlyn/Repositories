/**
 * @description Trigger for Product2 to validate if related Facilitators have ContactImage when Ready for Publishing value is 'Yes'
 * @see Product2Trigger
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | john.bo.a.pineda               | May 02, 2022          | DEPP-2403              | Created file                 |
      | john.bo.a.pineda               | May 13, 2022          | DEPP-2591              | Added AfterUpdate            |
      |                                |                       |                        |                              |
 */
trigger Product2Trigger on Product2(before update, after update) {
  TriggerDispatcher.dispatch(
    TriggerHandlerFactory.getHandlersForSObjectType('Product2'),
    Trigger.operationType
  );
}
