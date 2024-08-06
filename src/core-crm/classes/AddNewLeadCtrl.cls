/**
 * @description Controller Class for addNewLead LWC
 * @see ../lwc/addNewLead
 * 
 * @author Accenture
 * 
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | gabriel.p.ventayen        | Aug 06, 2024          | DEPP-10224           | Created file                 | 
 */
public with sharing class AddNewLeadCtrl {
    private static final String SUCCESS_RESPONSE = 'Success';
    
    /**
     * @description Updates Related Lead field of Voice Call Record
     * @param recordId - Record ID from record page
     * @param createdLeadId - Created Lead record Id
     * @return response
     */
    @AuraEnabled
    public static String updateVoiceCallRelatedLead (String recordId, String createdLeadId){
        String response;
        try{
            VoiceCall detailVoiceCall = [SELECT Id, Related_Lead__c FROM VoiceCall WHERE Id=:recordId WITH SECURITY_ENFORCED];
            detailVoiceCall.Related_Lead__c = createdLeadId;
            update detailVoiceCall;
            response = SUCCESS_RESPONSE;
        } catch(Exception e){
            response = e.getMessage();
        }
        return response;
    }

    /**
     * @description Updates Related Lead field of Messaging Record
     * @param recordId - Record ID from record page
     * @param createdLeadId - Created Lead record Id
     * @return response
     */
    @AuraEnabled
    public static String updateMessagingSessionRelatedLead (String recordId, String createdLeadId){
        String response;
        try{
            MessagingSession detailMessagingSession = [SELECT Id, Related_Lead__c FROM MessagingSession WHERE Id=:recordId WITH SECURITY_ENFORCED];
            detailMessagingSession.Related_Lead__c = createdLeadId;
            update detailMessagingSession;
            response = SUCCESS_RESPONSE;
        } catch(Exception e){
            response = e.getMessage();
        }
        return response;
    }
    
}