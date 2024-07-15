/**
 * @description Program Enrollment object trigger helper class
 * @see ProgramEnrollmentTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                      |
      |--------------------------------|-----------------------|------------------------|-----------------------------------------------------|
      | roy.nino.s.regala		       | November 03, 2023     | DEPP-7145              | Created file                                        |
      | mark.j.mahilum                 | May 31, 2024          | DEPP-8956              | Added new method to get the address of contact when |
      |                                |                       |                        | program enrollment status is updated to "Admitted"  |
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
                enrolment.Lead_Score_Reset__c = true;
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

    /**
     * @description get the contact address when the enrollment status become "Admitted"
     * @param newItems  List of new hed__Program_Enrollment__c  records
     * @param oldItems  Map of old hed__Program_Enrollment__c  records
     */
    public static void processAddressValidation(
        List<hed__Program_Enrollment__c > newItems,
        Map<Id, hed__Program_Enrollment__c > oldItems
    ) {
        Set<Id> contactIdSet = new Set<Id>();
        for (hed__Program_Enrollment__c enrollment : newItems) {

            Boolean isEnrollmentStatusAdmitted = enrollment.hed__Contact__c != null &&
                                                 enrollment.Enrollment_Status__c == ProgramEnrollmentsDAO.ENROLLMENT_STATUS_ADMITTED &&
                                                 (oldItems == null || enrollment.Enrollment_Status__c != oldItems.get(enrollment.Id).Enrollment_Status__c);
                
            //if a program enrolment with a contact has its enrollment status equal admitted
            if (isEnrollmentStatusAdmitted) {
                contactIdSet.add(enrollment.hed__Contact__c);
            }
        }
        
        Map<Id,hed__Address__c> mapOfContactAddress = new Map<Id,hed__Address__c>();
        for(hed__Address__c address: AddressesDAO.newInstance().getAddressesByContactIdsAndAddressType(contactIdSet,new Set<String>{AddressesDAO.OTHER_ADDRESS},'USER_MODE')){           
            if(!mapOfContactAddress.containsKey(address.Id)){
                mapOfContactAddress.put(address.Id,address);
            }
        }
        
        if(!mapOfContactAddress.values().isEmpty()){       
              Database.executeBatch(new ContactAddressValidationBatch(mapOfContactAddress.KeySet()));
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
