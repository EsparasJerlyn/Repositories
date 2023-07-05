/**
 * @description trigger handler for ContentDocumentLink
 * @see ContentDocumentLinkTrigger
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                                     |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------------------------------|
      | carl.alvin.cabiles             | June 19, 2023         | DEPP-5388              | Created file                                                       |
 */

public with sharing class ContentDocumentLinkTriggerHandler implements Disableable, BeforeInsert {
    /**
     * @description before update event for ContentDocumentLink
     * @param newItems - List of ContentDocumentLink.Trigger.new
     */
    public void beforeInsert(List<SObject> newItems) {
        ContentDocumentLinkTriggerHelper.createMemoPDFURL(newItems);
    }

    public Boolean isDisabled() {
        final TriggerBypassStrategy bypass = new TriggerBypassStrategy();
        return bypass.isDisabled();
    }
}
