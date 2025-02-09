/**
 * @description Batch handler and schduler for the LMS Course Enrollment Callouts.
 * To be run in 1 hr interval.
 *
 * @author wli
 *
 * @date 10/05/2022
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                            |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------|
      | kenneth.f.alsay                | November 29, 2023     | DEPP-7318              | Removed unused fields from SOQL           |
 */
public without sharing class LMSCourseEnrollmentBatchHandler implements Database.Batchable<SObject>, Database.AllowsCallouts, Schedulable {

    private static final String PRIMARY_DELIVERY_PLATFORM = 'QUT Canvas';
    private static final String SUCCESS = 'Success';
    private static final String FACULTY = 'Faculty';
    private static final String STUDENT = 'Student';
    private static final Date TODAY_PLUS_7 = System.today().addDays(7);

    public Database.QueryLocator start(Database.BatchableContext param1) {
        return Database.getQueryLocator(
                'SELECT Id' +
                        ' FROM hed__Course_Enrollment__c' +
                        ' WHERE LMS_Integration_Status__c = NULL' +
                        ' AND hed__Contact__r.QUT_Identity_ID__c != NULL' +
                        ' AND hed__Contact__r.QUT_Student_ID__c != NULL' +
                        ' AND hed__Course_Offering__r.LMS_Integration_Status__c = :SUCCESS' +
                        ' AND hed__Course_Offering__r.hed__Course__r.Primary_Delivery_Platform__c = :PRIMARY_DELIVERY_PLATFORM' +
                        ' AND Recordtype_Name__c = :STUDENT' + 
                        ' AND Course_Offering_Start_Date__c <= :TODAY_PLUS_7'
        );
    }

    /**
     * @description Executes the process and calls the relevant classes.
     *
     * @param context The batch context.
     * @param batchObjects The objects to process.
     */
    public void execute(Database.BatchableContext context, List<hed__Course_Enrollment__c> batchObjects) {
        LMSIntegrationManager.calloutLMSCourseEnrollment(batchObjects);
    }

    /**
     * @description Finalizer method for the batch process.
     *
     * @param param1 The batcha context.
     */
    public void finish(Database.BatchableContext param1) {
        try {
            System.scheduleBatch(new LMSCourseEnrollmentBatchHandler(), 'LMS Course Enrollment Batch Job', 60, 200);
        } catch(Exception e) {
            Logger.error('Exception caught in finish in class LMSCourseEnrollmentBatchHandler.')
                .setExceptionDetails(e);
        } finally {
            if(Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }
    }

    /**
     * @description Executes the Site STatus Batch Handler class.
     *
     * @param param1 The schedulable context.
     */
    public void execute(SchedulableContext param1) {
        Database.executeBatch(new LMSCourseEnrollmentBatchHandler(), 200);
    }

}