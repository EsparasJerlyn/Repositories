/**
 * @description Trigger for ActionCadenceStepTrackerChangeEvent Object
 * @see AffiliationTrigger
 *
 * @author Accenture
 *
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | mark.majilum                   | September 4,2023      | DEPP-6138              | Created file                 |
      | eccarius.munoz                 | September 4,2023      | DEPP-6138              | Added to trigger handler     |
 */

trigger ActionCadenceStepTrackerTrigger on ActionCadenceStepTrackerChangeEvent (after insert) {
    TriggerDispatcher.dispatch(
        TriggerHandlerFactory.getHandlersForSObjectType('ActionCadenceStepTrackerChangeEvent'),
        Trigger.operationType
    );
}