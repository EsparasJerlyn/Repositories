/**
 * @description Setup Communication Controller
 * @see .. lwc/setupCommuniction
 * @author Accenture
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | eugene.andrew.abuan       | April 12, 2022        | DEPP-2247            | Created file                 |
      |                           |                       |                      |                              | 
 */
public with sharing class EmailTemplateCtrl {
    private static string PR_PROGRAM = System.Label.RT_ProductRequest_Program;

    /**
     * @description gets Email Template when searching 
     * @param filterString - String that the user encodes
     * @return emailMap - queried Id and Name of EmailTemplate using the filtered string
     */    
    @AuraEnabled(cacheable=true)
    public static List<Map<String,String>> getEmailTemplate(String filterString){
        filterString = '%' + filterString + '%';
        List<Map<String,String>> emailMap = new List<Map<String,String>>();
        
        for(EmailTemplate e : [ SELECT Id, Name FROM EmailTemplate WHERE (
                Name LIKE :filterString OR
                Name = :filterString ) 
            LIMIT 15])
        {
            emailMap.add(new Map<String,String>{
                'id' => e.Id,
                'label' => e.Name
            });
        }
        return emailMap;
    }  

    /**
     * @description gets the Setup Communication Data on Load
     * @param emailNames - List of Email Templates to be loaded
     * @param prodReqId - Product Request Id Record
     * @param isProgram - Program RecordType
     * @return comSchedData - wrapped response
     */    
    @AuraEnabled(cacheable=true)
    public static CommunicationSchedData getCommunicationData(List<String> emailNames , String prodReqId, String isProgram ){
        CommunicationSchedData comSchedData = new CommunicationSchedData();

        if(isProgram == PR_PROGRAM ){
            comSchedData.communicationRecord = [SELECT Id,On_Registration_Template__c,
            Notification_Before_Session_Template__c,
            On_Completion_Template__c,
            On_Final_Confirmation_Template__c 
            FROM Communication_Schedule__c 
            WHERE Program_Plan__r.Product_Request__c =:prodReqId].iterator().next();

        comSchedData.deliveryType = [SELECT Delivery_Type__c FROM hed__Program_Plan__c WHERE Product_Request__c =: prodReqId].iterator().next()?.Delivery_Type__c;
        }else{
        comSchedData.communicationRecord = [SELECT Id,On_Registration_Template__c,
                                            Notification_Before_Session_Template__c,
                                            On_Completion_Template__c,
                                            On_Final_Confirmation_Template__c 
                                            FROM Communication_Schedule__c 
                                            WHERE Course__r.ProductRequestID__c =:prodReqId].iterator().next();

        comSchedData.deliveryType = [SELECT Delivery_Type__c FROM hed__Course__c WHERE ProductRequestID__c =: prodReqId].iterator().next()?.Delivery_Type__c;
        }

        Map<String,Id> newMap = new Map<String,Id>();
        for(EmailTemplate e : [SELECT Id, Name FROM EmailTemplate WHERE Name =:emailNames] ){
            if(!newMap.containsKey(e.Name)){
                newMap.put(e.Name, e.Id);
            }
        }
        Set<String> templateId = new Set<String>();

        comSchedData.defaultEmail = newMap;
        
        
        if(comSchedData.communicationRecord != null && comSchedData.communicationRecord.On_Registration_Template__c !=null){
            templateId.add(comSchedData.communicationRecord.On_Registration_Template__c);
        }
        if(comSchedData.communicationRecord != null && comSchedData.communicationRecord.Notification_Before_Session_Template__c  !=null){
            templateId.add(comSchedData.communicationRecord.Notification_Before_Session_Template__c);
        }
        if(comSchedData.communicationRecord != null && comSchedData.communicationRecord.On_Completion_Template__c  !=null){
            templateId.add(comSchedData.communicationRecord.On_Completion_Template__c);
        }
        if(comSchedData.communicationRecord != null && comSchedData.communicationRecord.On_Final_Confirmation_Template__c  !=null){
            templateId.add(comSchedData.communicationRecord.On_Final_Confirmation_Template__c);
        }

        List<Map<String,String>> emailMap = new List<Map<String,String>>();
        for(EmailTemplate e : [ SELECT Id, Name FROM EmailTemplate WHERE Id IN:templateId])
        {
            emailMap.add(new Map<String,String>{
                'id' => e.Id,
                'label' => e.Name
            });
        }

        comSchedData.templateMap = emailMap;
        return comSchedData;
    }

    public class CommunicationSchedData{
        @AuraEnabled 
        public Map<String,Id> defaultEmail;
        @AuraEnabled 
        public Communication_Schedule__c communicationRecord;
        @AuraEnabled
        public String deliveryType;
        @AuraEnabled
        public List<Map<String,String>> templateMap;
        
    }
 

}