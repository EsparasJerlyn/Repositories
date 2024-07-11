/**
 * @description This class implements the Database.Batchable interface to process Engagement List Criteria (ELC)
 * and generate preview results in batch mode. It handles the creation of query locators, processes the contacts,
 * and handles the batch job completion.
 *
 *
 * @history
 *    | Developer                 | Date         | JIRA        | Change Summary                                  |
 *    |---------------------------|--------------|-------------|------------------------------------------------|
 *    | roy.nino.s.regala         | May 21, 2024 | DEPP-8744   | Created File                                   |
 */
public with sharing class ELCPreviewBatch implements Database.Batchable<sObject>, Database.Stateful {
    private ELCParser eLCParser;
    private Set<String> errorMessagesSet = new Set<String>();
    /**
     * @description Constructor to initialize ELCPreviewBatch with criteria and execution date.
     * @param criteria The Engagement List Criteria record.
     * @param executionDate The date of execution for evaluation.
     */
    public ELCPreviewBatch(Engagement_List_Criteria__c criteria, Date executionDate) {
        eLCParser = new ELCParser(criteria, executionDate);
    }

    /**
     * @description Constructor to initialize ELCPreviewBatch with criteria, execution date and error messages, 
     * Overload Contstructor to simulate error scenarios. 
     * This helps manual testing for Preview Email with error messages.
     * @param criteria The Engagement List Criteria record.
     * @param executionDate The date of execution for evaluation.
     * @param errorMessagesSet The error messages
     */
    public ELCPreviewBatch(Engagement_List_Criteria__c criteria, Date executionDate, Set<String> errorMessagesSet) {
        eLCParser = new ELCParser(criteria, executionDate);
        this.errorMessagesSet = errorMessagesSet;
    }

    /**
     * @description Initializes the batch job by setting the preview job ID and creating the query locator for contacts.
     * @param bc The batch context provided by the Database.BatchableContext.
     * @return A Database.QueryLocator object to iterate over the contacts to be processed.
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        try{

            Engagement_List_Criteria__c criteria  = new Engagement_List_Criteria__c(
                Id = eLCParser.getEngagementListCriteria().Id,
                Preview_Job_Id__c = bc.getJobId()
            );
    
            EngagementListCriteriasDAO.newInstance()
                .updateRecords(
                    new List<Engagement_List_Criteria__c>{ criteria },
                    true,
                    AccessLevel.USER_MODE
                );
    
            String contactQuery = OutreachCampaignService.getQueryLocatorBySubQueryString(eLCParser);
    
            // Check if contactQuery is initialized
            if (contactQuery != null) {
                return ContactsDAO.newInstance().getQueryLocatorBySubquery(contactQuery);
            }
            return ContactsDAO.newInstance()
                .getQueryLocatorByCriteria(eLCParser.getELCContactParser().getContactCriteria());

        }catch(Exception e){
            ELCPreviewResultHandler resultHandler = new ELCPreviewResultHandler(eLCParser.getEngagementListCriteria(),eLCParser.getExecutionDate());
            //log exception error aginst the ELC
            resultHandler.logErrors(bc.getJobId(),e);
            //collect the error message
            errorMessagesSet.add(e.getMessage());
            //return an empty query locator, else 'First error: Start did not return a valid iterable object.' occurs
            return Database.getQueryLocator('SELECT Id FROM Contact WHERE Id = null'); 
        }
        
    }

    /**
     * @description Executes the batch job logic for each batch of contacts. It evaluates the contacts and handles the results.
     * @param bc The batch context provided by the Database.BatchableContext.
     * @param contacts The list of contacts to be processed in the current batch.
     */
    public void execute(Database.BatchableContext bc, List<Contact> contacts) {

        ELCPreviewResultHandler resultHandler = new ELCPreviewResultHandler(
            eLCParser.getEngagementListCriteria(),
            eLCParser.getExecutionDate()
        );
        try {
            ELCEvaluator eLCEvaluator = new ELCEvaluator(eLCParser);
            Map<Id, ELECandidateIngredient> eLECandidateIngredientByContact = eLCEvaluator.evaluate(
                contacts
            );
            resultHandler.handle(eLECandidateIngredientByContact.values());
        } catch (Exception e) {
            resultHandler.logErrors(bc.getJobId(),e);
            errorMessagesSet.add(e.getMessage());
        } finally {
            if (Logger.getBufferSize() > 0) { Logger.saveLog(); }
        }
    }

    /**
     * @description Handles the completion of the batch job. It processes the final result and updates the status.
     * @param bc The batch context provided by the Database.BatchableContext.
     */
    public void finish(Database.BatchableContext bc) {
        ELCPreviewResultHandler resultHandler = new ELCPreviewResultHandler(
            eLCParser.getEngagementListCriteria(),
            eLCParser.getExecutionDate()
        );
        try {
            resultHandler.handle(bc.getJobId(), errorMessagesSet);
        } catch (Exception e) {
            resultHandler.logErrors(bc.getJobId(),e);
        } finally {
            if (Logger.getBufferSize() > 0) { Logger.saveLog(); }
        }
    }
}