/**
 * @description Outreach Communication Processed Platform Event Handler Class
 * @see OutreachCommunicationProcessedHandler
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                                                        |
      |---------------------------|-----------------------|--------------|-----------------------------------------------------------------------|
      | mark.j.mahilum            | May 21, 2024          | DEPP-8823    | Created file                                                          |
*/
public with sharing class OutreachCommunicationProcessedHandler  {
    
    private List<Communication_Processed__e> communicationProcessedEventList;
    
    public OutreachCommunicationProcessedHandler(List<Communication_Processed__e> communicationProcessedEventList) {
        this.communicationProcessedEventList = communicationProcessedEventList;
    }

   /**
    * @description main method to handle the communication processed event of outreach communication queue records
    */
    public void handle() {
        
        Set<Id> caseIds = new Set<Id>();
        
        for(Communication_Processed__e outreachEvent: communicationProcessedEventList){
            
            Boolean isOutreachCommunicationQueueSuccess = (outreachEvent.Business_Process__c == CommunicationQueuesDAO.BUSINESS_PROCESS_OUTREACH &&
                                                           outreachEvent.Type__c == CommunicationQueuesDAO.TYPE_EMAIL &&
                                                           outreachEvent.Success__c);
            
            if(isOutreachCommunicationQueueSuccess){
                caseIds.add(outreachEvent.What_Id__c);
            }
        }
        
        //update Case Initial Status
        updateCaseInitialStatus(caseIds);
    }
    
    /**
     * @description update the case Initial status to = Sent
     * @param Set<Id> caseIds the case Ids to be updated
     */
    private void updateCaseInitialStatus(Set<Id> caseIds) {
        
        if(caseIds.isEmpty()){
            return;
        }
        
        List<Case> updateCaseInitialStatus = new List<Case>();
        
        for(Id caseId: caseIds){
            updateCaseInitialStatus.add(
                new Case(
                    Id = caseId,
                    Initial_Communication_Status__c = CasesDAO.INITIAL_COMMUNICATION_STATUS_SENT
                )
            );
        }
        CasesDAO.newInstance().updateRecords(updateCaseInitialStatus, false, AccessLevel.SYSTEM_MODE);             
    }
}