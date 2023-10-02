/**
 * @description Batch handler and schduler for the LMS Course Offering Callouts.
 * To be ran in 15 mins interval.
 *
 * @author wli
 *
 * @date 08/05/2022
 * 
 *  * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                            |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------|
  	  | kenneth.f.alsay                | September 25, 2023    | DEPP-6629 - AC1        | Updated Schedule to 15 mins               |
      |                                |                       |                        | Updated WHERE clause to match criteria    |
 */



public without sharing class LMSCourseOfferingBatchHandler implements Database.Batchable<SObject>, Database.AllowsCallouts, Schedulable {

    private static final String PRIMARY_DELIVERY_PLATFORM = 'QUT Canvas';
    private static final String SUCCESS = 'Success';
    private static final String IS_CHANGED = 'isChanged';
    private static final Date TODAY = System.today();

    public Database.QueryLocator start(Database.BatchableContext param1) {
        return Database.getQueryLocator(
            'SELECT Id, Course_Code__c, Name, hed__Start_Date__c, hed__End_Date__c, LMS_Integration_Status__c, hed__Course__r.Name,' +
            ' hed__Course__r.LMS_Integration_Status__c, hed__Course__r.Primary_Delivery_Platform__c, hed__Course__r.Mark_Content_as_Complete__c' +
            ' FROM hed__Course_Offering__c' +
            ' WHERE (LMS_Integration_Status__c = NULL OR LMS_Integration_Status__c = :IS_CHANGED)' +
            ' AND LMS_Creation_Date__c <= :TODAY' +
            ' AND hed__Course__r.Primary_Delivery_Platform__c = :PRIMARY_DELIVERY_PLATFORM' +
            ' AND IsActive__c = TRUE'
        );
    }

    /**
     * @description Executes the process and calls the relevant classes.
     *
     * @param context The batch context.
     * @param batchObjects The objects to process.
     */
    public void execute(Database.BatchableContext context, List<hed__Course_Offering__c> courseOfferings) {
        LMSIntegrationManager.calloutLMSCourseOffering(courseOfferings);
    }

    /**
     * @description Finalizer method for the batch process.
     *
     * @param param1 The batch context.
     */
    public void finish(Database.BatchableContext param1) {
        try {
            System.scheduleBatch(new LMSCourseOfferingBatchHandler(), 'LMS Course Offering Batch Job', 15, 200);
        } catch(Exception e) {
            Logger.error('Exception caught in method finish in class LMSCourseOfferingBatchHandler.')
                .setExceptionDetails(e);
        } finally {
            if(Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }
    }

    /**
     * @description Executes the Batch Handler class.
     *
     * @param param1 The schedulable context.
     */
    public void execute(SchedulableContext param1) {
        Database.executeBatch(new LMSCourseOfferingBatchHandler(), 200);
    }

}