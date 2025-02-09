/**
 * @description Batch handler and schduler for the SAMS Register Learner Callouts.
 * To be run in 30 mins interval.
 *
 * @author wli
 *
 * @date 11/05/2022
 */
public without sharing class SAMSRegisterLearnerBatchHandler implements Database.Batchable<SObject>, Database.AllowsCallouts, Schedulable {

    private static final String STUDENT = 'Student';
    private static final String COMPLETED = 'Completed';

    public Database.QueryLocator start(Database.BatchableContext param1) {

		Set<Id> contactIds = new Set<Id>();

        for(hed__Course_Enrollment__c courseEnrollment : Database.query('SELECT Id, Recordtype_Name__c, hed__Status__c, hed__Contact__c, hed__Contact__r.SAMS_Integration_Status__c, hed__Contact__r.QUT_Student_ID__c,' +
                        ' hed__Contact__r.Id, hed__Contact__r.Nominated_Student_ID__c, hed__Contact__r.Salutation, hed__Contact__r.FirstName, hed__Contact__r.LastName,' +
                        ' hed__Contact__r.Birthdate, hed__Contact__r.hed__Gender__c, hed__Contact__r.MobilePhone, hed__Contact__r.Registered_Email__c' +
                        ' FROM hed__Course_Enrollment__c' +
                        ' WHERE hed__Contact__r.SAMS_Integration_Status__c = NULL' +
                        ' AND hed__Status__c != :COMPLETED' +
                        ' AND Recordtype_Name__c = :STUDENT' +
                        ' AND hed__Contact__c != NULL' +
                        ' AND hed__Contact__r.QUT_Student_ID__c = NULL')
           )
        {
            contactIds.add(courseEnrollment.hed__Contact__r.Id);
        }

        return Database.getQueryLocator('SELECT Id, Nominated_Student_ID__c, Salutation, FirstName, LastName, Birthdate, hed__Gender__c, MobilePhone, Registered_Email__c' +
                                       ' FROM Contact' +
                                       ' WHERE Id IN :contactIds');
    }

    /**
     * @description Executes the process and calls the relevant classes.
     *
     * @param context The batch context.
     * @param batchObjects The objects to process.
     */
    public void execute(Database.BatchableContext context, List<Contact> batchObjects) {
        if (batchObjects.size() == 1) {
            LMSIntegrationManager.calloutSAMSRegisterLearner(batchObjects[0]);
        }
    }

    /**
     * @description Finalizer method for the batch process.
     *
     * @param param1 The batcha context.
     */
    public void finish(Database.BatchableContext param1) {
        try {
            System.scheduleBatch(new SAMSRegisterLearnerBatchHandler(), 'SAMS Learner Registration Batch Job', 30, 1);
        } catch(Exception e) {
            Logger.error('Exception caught in method finish in class SAMSRegisterLearnerBatchHandler')
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
        Database.executeBatch(new SAMSRegisterLearnerBatchHandler(), 1);
    }

}