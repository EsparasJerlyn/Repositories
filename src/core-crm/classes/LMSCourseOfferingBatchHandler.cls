/**
 * @description Batch handler and schduler for the LMS Course Offering Callouts.
 * To be ran in 5 mins interval.
 *
 * @author wli
 *
 * @date 08/05/2022
 */

public without sharing class LMSCourseOfferingBatchHandler implements Database.Batchable<SObject>, Database.AllowsCallouts, Schedulable {

    private static final String PRIMARY_DELIVERY_PLATFORM = 'Blackboard';

    public Database.QueryLocator start(Database.BatchableContext param1) {
        return Database.getQueryLocator(
                'SELECT Id, Course_Code__c, Name, hed__Start_Date__c, hed__End_Date__c, isLMSTriggered__c,' +
                        ' hed__Course__r.LMS_Site_URL__c, hed__Course__r.Primary_Delivery_Platform__c, hed__Course__r.Mark_Content_as_Complete__c' +
                        ' FROM hed__Course_Offering__c' +
                        ' WHERE isLMSTriggered__c = FALSE' + 
                        ' AND hed__Course__r.LMS_Site_URL__c != NULL' + 
                        ' AND hed__Course__r.Primary_Delivery_Platform__c = :PRIMARY_DELIVERY_PLATFORM' +
                        ' AND hed__Course__r.Mark_Content_as_Complete__c = TRUE'
        );
    }

    /**
     * @description Executes the process and calls the relevant classes.
     *
     * @param context The batch context.
     * @param batchObjects The objects to process.
     */
    public void execute(Database.BatchableContext context, List<hed__Course_Offering__c> courseOfferings) {
        if (courseOfferings.size() == 1) {
            LMSIntegrationManager.calloutLMSCourseOffering(courseOfferings[0]);
        }
    }

    /**
     * @description Finalizer method for the batch process.
     *
     * @param param1 The batch context.
     */
    public void finish(Database.BatchableContext param1) {
        try {
            System.scheduleBatch(new LMSCourseOfferingBatchHandler(), 'LMS Course Offering Batch Job', 5, 1);
        } catch(Exception e) {
            System.debug('Error rescheduling LMSCourseOfferingBatchHandler: ' + e.getMessage());
        }
    }

    /**
     * @description Executes the Batch Handler class.
     *
     * @param param1 The schedulable context.
     */
    public void execute(SchedulableContext param1) {
        Database.executeBatch(new LMSCourseOfferingBatchHandler(), 1);
    }

}