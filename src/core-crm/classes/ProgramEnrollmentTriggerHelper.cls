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
            //and set lead score reset to true
            if (enrolment.hed__Contact__c != null && isStudying) {
                contactIdSet.add(enrolment.hed__Contact__c);
                enrolment.Lead_Score_Reset__c = true;
            }
        }

        //enqueue lead score reset of contact's related records
        if (!contactIdSet.isEmpty()) {
            Boolean isAsyncProcess = System.isQueueable() || System.isFuture() || System.isBatch();
            if (isAsyncProcess) {
                updateLeadScoreRelatedRecords(contactIdSet);
            } else {
                QueueableCall executeQueueable = new QueueableCall(contactIdSet);
                System.enqueueJob(executeQueueable);
            }
        }
    }

    private static void updateLeadScoreRelatedRecords(Set<Id> contactIdSet){
        List<Lead_Score_Detail__c> leadScoreDetails = LeadScoreResetService.getLeadScoreDetailsToUpdate(contactIdSet);
        if(!leadScoreDetails.isEmpty()){
            LeadScoreDetailsDAO.newInstance().updateRecords(leadScoreDetails, false, AccessLevel.SYSTEM_MODE);
            LeadScoreResetService.updateLeadScoreResetForMktgInt(contactIdSet);
            LeadScoreResetService.updateLeadScoreResetForIndivEmail(contactIdSet);
            LeadScoreResetService.updateLeadScoreResetForCase(contactIdSet);
        }
    }

    private class QueueableCall implements Queueable {
        private Set<Id> contactIdSet;

        public QueueableCall(Set<Id> contactIdSet) {
            this.contactIdSet = contactIdSet;
        }
        public void execute(QueueableContext context) {
            updateLeadScoreRelatedRecords(contactIdSet);
        }
    }
}
