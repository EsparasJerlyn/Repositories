/**
 * @description Batch handler and schduler for the LMS Course Enrollment Callouts.
 * To be run in 1 hr interval.
 *
 * @author wli
 *
 * @date 10/05/2022
 */
public without sharing class LMSCourseEnrollmentBatchHandler implements Database.Batchable<SObject>, Database.AllowsCallouts, Schedulable {

    private static final String PRIMARY_DELIVERY_PLATFORM = 'Blackboard';
    private static final String SUCCESS = 'Success';
    private static final String FACULTY = 'Faculty';
    private static final String STUDENT = 'Student';
    private static final Date TODAY_PLUS_7 = System.today().addDays(7);

    public Database.QueryLocator start(Database.BatchableContext param1) {
        return Database.getQueryLocator(
                'SELECT Id, Course_Code__c, Recordtype_Name__c, LMS_Integration_Status__c, hed__Contact__r.QUT_Identity_ID__c, hed__Course_Offering__r.LMS_Integration_Status__c,' +
                        ' Course_Offering_Name__c, hed__Course_Offering__r.Id,' + 
                        ' hed__Course_Offering__r.hed__Course__r.Primary_Delivery_Platform__c, Course_Offering_Start_Date__c, Course_Offering_End_Date__c,' + 
                        ' hed__Contact__r.QUT_Employee_ID__c, hed__Contact__r.QUT_Student_ID__c' + 
                        ' FROM hed__Course_Enrollment__c' +
                        ' WHERE LMS_Integration_Status__c = NULL' +
                        ' AND hed__Contact__r.QUT_Identity_ID__c != NULL' +
                        ' AND hed__Course_Offering__r.LMS_Integration_Status__c = :SUCCESS' +
                        ' AND hed__Course_Offering__r.hed__Course__r.Primary_Delivery_Platform__c = :PRIMARY_DELIVERY_PLATFORM' +
                        ' AND ( (Recordtype_Name__c = :FACULTY AND hed__Contact__r.QUT_Employee_ID__c != NULL) OR (Recordtype_Name__c = :STUDENT AND hed__Contact__r.QUT_Student_ID__c != NULL) )' + 
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
        System.debug('Execute LMSCourseEnrollmentBatchHandler start');

        LMSIntegrationManager.calloutLMSCourseEnrollment(batchObjects);
        
        System.debug('Execute LMSCourseEnrollmentBatchHandler finish');
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
            System.debug('Error rescheduling LMSCourseEnrollmentBatchHandler: ' + e.getMessage());
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