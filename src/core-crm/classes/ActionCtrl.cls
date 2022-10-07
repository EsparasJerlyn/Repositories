/**
 * @description Controller Class for Activity Section LWC
 * @see activitySection
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer                      | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.karl.munoz            | July 12, 2022         | DEPP-2035              | Created file                 | 
      |                                |                       |                        |                              | 
 */
public with sharing class ActionCtrl {

    private static final string RT_ACTION_ACT = System.Label.RT_Action_Activity;
    private static final Id RT_ACTION_ACT_ID =  Schema.SObjectType.Action__c.getRecordTypeInfosByDeveloperName().get(RT_ACTION_ACT).getRecordTypeId();

    private static final string RT_ACTION_INV = System.Label.RT_Action_Investigation;
    private static final Id RT_ACTION_INV_ID =  Schema.SObjectType.Action__c.getRecordTypeInfosByDeveloperName().get(RT_ACTION_INV).getRecordTypeId();

    /**
     * @description retrieve Action Details based on product request
     * @param recordId - recordId
     * @return List<Action__c> 
     */
    @AuraEnabled(cacheable=true)
    public static List<Action__c> getActionDetails(String recordId){
        List<Action__c> actions = [SELECT Consultancy__r.Id, Name, Activity_Name__c, Activity_Method__c, Start_Date__c, End_Date__c 
                                     FROM Action__c 
                                    WHERE Consultancy__r.Product_Request__r.Id =: recordId
                                      AND RecordTypeId =: RT_ACTION_ACT_ID];
        return actions;
    }

    /**
     * @description retrieve Action Details based on product request
     * @param recordId - recordId
     * @return List<Action__c> 
     */
    @AuraEnabled(cacheable=true)
    public static List<Action__c> getInvestigationActionDetails(String recordId){
        List<Action__c> actions = [SELECT Id, Consultancy__r.Id, Investigation_Name__c, Investigation_Method__c, Is_Complete__c, Start_Date__c, End_Date__c, Summary__c
                                    FROM Action__c 
                                    WHERE Consultancy__r.Product_Request__r.Id =: recordId
                                    AND RecordTypeId =: RT_ACTION_INV_ID];
        return actions;
    }

    /**
     * @description retrieve List of Consultancies based on product request
     * @param recordId - recordId
     * @return ActivitySectionDetails
     */
    @AuraEnabled(cacheable=true)
    public static ActivitySectionDetails getActivitySectionDetails(String recordId){
        ActivitySectionDetails response = new ActivitySectionDetails();
        List<Consultancy__c> consultancies = [SELECT Id, Mark_Activity_as_Complete__c, (SELECT Id FROM Actions__r), Investigation_Summary__c, Publish_to_the_Portal__c, Mark_Investigation_as_Complete__c, Product_Request__r.Product_Request_Status__c FROM Consultancy__c WHERE Product_Request__c =: recordId];
        for(Consultancy__c c : consultancies){
            response.id = c.Id;
            response.markActivityAsComplete = c.Mark_Activity_as_Complete__c;
            response.markInvestigationAsComplete = c.Mark_Investigation_as_Complete__c;
            response.investigationSummary = c.Investigation_Summary__c;
            response.publishToPortal = c.Publish_to_the_Portal__c;     
            response.prodReqStatus = c.Product_Request__r.Product_Request_Status__c;       
            if(c.Actions__r.size() > 0){
                response.hasActivity = true;
            }else {
                response.hasActivity = false;
            }
        }
        return response;
    }

    @AuraEnabled(cacheable=false)
    public static Map<ID, String> getRelatedFilesByRecordId(String recordId) {
        List<ContentDocumentLink> files = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId];
        List<ID> fileIDs = new List<ID>();
        for (ContentDocumentLink docLink : files) {
            fileIDs.add(docLink.ContentDocumentId);
        }
    
        List<ContentVersion> docs = [SELECT ContentDocumentId, FileExtension, Title FROM ContentVersion WHERE ContentDocumentId IN : fileIDs];
        Map<ID, String> mapIdTitle = new Map<ID, String>();
        for (ContentVersion docLink : docs) {
            mapIdTitle.put(docLink.ContentDocumentId, docLink.Title);
        }
        return mapIdTitle;
    }

    public class ActivitySectionDetails{
        @AuraEnabled
        public String id;
        @AuraEnabled
        public Boolean hasActivity;
        @AuraEnabled
        public Boolean markActivityAsComplete;
        @AuraEnabled
        public Boolean markInvestigationAsComplete;
        @AuraEnabled
        public String investigationSummary;
        @AuraEnabled
        public Boolean publishToPortal;
        @AuraEnabled
        public String prodReqStatus;
    }
}

