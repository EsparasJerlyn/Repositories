/**
 * @description Program Enrollment object trigger helper class
 * @see ProgramEnrollmentTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala		       | November 03, 2023     | DEPP-7145              | Created file                 |
 */

public with sharing class ProgramEnrollmentTriggerHelper {
    /**
     * @description reset the lead score of the linked contact
     * @param newItems  List of new hed__Program_Enrollment__c  records
     * @param oldItems  Map of old hed__Program_Enrollment__c  records
     */
    public static void resetLeadScore(
        List<hed__Program_Enrollment__c > newItems,
        Map<Id, hed__Program_Enrollment__c > oldItems
    ) {
        Set<Id> contactIdSet = new Set<Id>();
        for (hed__Program_Enrollment__c  enrolment : newItems) {

            Boolean isStudying =
                enrolment.Enrollment_Status__c ==
                ProgramEnrollmentsDAO.ENROLLMENT_STATUS_ADMITTED &&
                enrolment.Enrollment_Status__c != oldItems.get(enrolment.Id).Enrollment_Status__c;

            //if a program enrolment with a contact has its status updated to admitted
            //collect contact ids 
            if (enrolment.hed__Contact__c != null && isStudying) {
                contactIdSet.add(enrolment.hed__Contact__c);
            }
        }

        //enqueue lead score reset of contact's related records
        if (!contactIdSet.isEmpty()) {
            Boolean isAsyncProcess = System.isQueueable() || System.isFuture() || System.isBatch();
            if (isAsyncProcess) {
                LeadScoreService.updateLeadScoreRelatedRecords(contactIdSet);
            } else {
                QueueableCall executeQueueable = new QueueableCall(contactIdSet);
                System.enqueueJob(executeQueueable);
            }
        }
    }

    private class QueueableCall implements Queueable {
        private Set<Id> contactIdSet;

        public QueueableCall(Set<Id> contactIdSet) {
            this.contactIdSet = contactIdSet;
        }
        public void execute(QueueableContext context) {
            LeadScoreService.updateLeadScoreRelatedRecords(contactIdSet);
        }
    }
}
