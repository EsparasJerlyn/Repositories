/**
 * @description helper class for webcart
 * @see carttriggerhandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | carl.alvin.cabiles             | June 28, 2023         | DEPP-5388              | Created file                 |
      |                                |                       |                        |                              |
 */

public without sharing class ContentDocumentLinkTriggerHelper {
    /**
     * @description generates Memo PDF URL for Opportunity and changes the Memo Status to In Progress
     * @param newItems - Map of ContentDocumentLink.Trigger.new
     */
    public static void createMemoPDFURL(List<ContentDocumentLink> newItems) {
        List<ContentDocumentLink> newList = (List<ContentDocumentLink>) newItems;
        Set<Id> developmentOpportunities = new Set<Id>();
        Set<Id> setOppIds = new Set<Id>();
        String title = '%Memo%';
        String baseUrl =
            SYSTEM.URL.getSalesforceBaseUrl()
                .toExternalForm()
                .removeEndIgnoreCase('.my.salesforce.com') +
            '.lightning.force.com/lightning/r/ContentDocument/';
            if(Schema.sObjectType.Opportunity.isAccessible()){
                    developmentOpportunities = (new Map<Id, Opportunity>(OpportunitiesDAO.newInstance().getRecordsByStageName('Development'))).keySet();
            }
        Set<Id> setContentIds = (new Map<Id, ContentDocument>(
                ContentDocumentsDAO.newInstance().getContentDocumentsByTitle(title)
            ))
            .keySet();
        List<Opportunity> lstOppsToUpdate = new List<Opportunity>();
        if (!developmentOpportunities.isEmpty()) {
            for (ContentDocumentLink oppIterator : newList) {
                if (
                    developmentOpportunities.contains(oppIterator.LinkedEntityId) &&
                    !setOppIds.contains(oppIterator.LinkedEntityId) &&
                    setContentIds.contains(oppIterator.ContentDocumentId)
                ) {
                    lstOppsToUpdate.add(
                        new Opportunity(
                            Id = oppIterator.LinkedEntityId,
                            Memo_Status__c = 'Generated',
                            Memo_PDF_URL__c = baseUrl + oppIterator.ContentDocumentId + '/view'
                        )
                    );
                    setOppIds.add(oppIterator.LinkedEntityId);
                }
            }
        }
        if (!lstOppsToUpdate.isEmpty()) {
            OpportunitiesDAO.newInstance()
                .updateRecords(lstOppsToUpdate, false, AccessLevel.USER_MODE);
        }
    }
}
