/**
 * @description Batch handler and schduler for the LMS Course Callouts.
 * To be ran in 5 mins interval.
 *
 * @author wli
 *
 * @date 08/05/2022
 */

public without sharing class LMSCourseBatchHandler implements Database.Batchable<SObject>, Database.AllowsCallouts, Schedulable {

    private static final String PRIMARY_DELIVERY_PLATFORM = 'Blackboard';

    public Database.QueryLocator start(Database.BatchableContext param1) {
        return Database.getQueryLocator(
                'SELECT Id, Course_Code__c, Name, Recordtype_Name__c, Primary_Delivery_Platform__c, Mark_Content_as_Complete__c, LMS_Integration_Status__c' +
                        ' FROM hed__Course__c' +
                        ' WHERE LMS_Integration_Status__c = NULL' +
                        ' AND Mark_Content_as_Complete__c = TRUE' +
                        ' AND Primary_Delivery_Platform__c = :PRIMARY_DELIVERY_PLATFORM'
        );
    }

    /**
     * @description Executes the process and calls the relevant classes.
     *
     * @param context The batch context.
     * @param batchObjects The objects to process.
     */
    public void execute(Database.BatchableContext context, List<hed__Course__c> courses) {
        if (courses.size() == 1) {
            LMSIntegrationManager.calloutLMSCourse(courses[0]);
        }
    }

    /**
     * @description Finalizer method for the batch process.
     *
     * @param param1 The batch context.
     */
    public void finish(Database.BatchableContext param1) {
        try {
            System.scheduleBatch(new LMSCourseBatchHandler(), 'LMS Course Batch Job', 5, 1);
        } catch(Exception e) {
            System.debug('Error rescheduling LMSCourseBatchHandler: ' + e.getMessage());
        }
    }

    /**
     * @description Executes the Batch Handler class.
     *
     * @param param1 The schedulable context.
     */
    public void execute(SchedulableContext param1) {
        Database.executeBatch(new LMSCourseBatchHandler(), 1);
    }

}