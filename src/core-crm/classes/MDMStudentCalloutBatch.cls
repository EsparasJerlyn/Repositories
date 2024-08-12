/**
 * @description Batch class for MDM Student callout
 * @see MDMCalloutEvenHandler
 *
 * @author Accenture
 *
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.karl.munoz            | August 12, 2024       | DEPP-10490             | Created file                 |
 */
public with sharing class MDMStudentCalloutBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
    
    private static final String ENDPOINT_ESB_MDM_STUDENT = System.Label.ESBEndpointMDMStudent;
    private Set<Id> contactIds;

    public MDMStudentCalloutBatch(Set<Id> contactIds) {
        this.contactIds = contactIds;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return ContactsDAO.newInstance().queryLocatorGetMDMStudentsByIds(contactIds, AccessLevel.USER_MODE);
    }    

    public void execute(Database.BatchableContext bc, List<Contact> contactList) {
        if (!contactList.isEmpty()) {
            HTTPResponse httpResponse;
            try {
                String endpoint = 'callout:ESB' + ENDPOINT_ESB_MDM_STUDENT;
                httpResponse = IntegrationCallOutCtrl.doCallout(endpoint, 'POST', JSON.serialize(contactList));
                
                if (httpResponse.getStatusCode() != 200) {
                    Logger.error('Callout failed with status code ' + httpResponse.getStatusCode()).setHttpResponseDetails(httpResponse);
                }

            } catch (Exception e) {
                Logger.error('Callout exception occurred: ' + e.getMessage()).setExceptionDetails(e);
            } finally {
                if(Logger.getBufferSize() > 0) {
                    Logger.saveLog();
                }
            }
        }
    }  

    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext bc) {}

}