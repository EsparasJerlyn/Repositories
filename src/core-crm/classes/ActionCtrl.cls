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
      | roy.nino.s.regala              | April 25, 2023        | DEPP-5567              | applied dao framework        | 
 */
public with sharing class ActionCtrl {
    /**
     * @description retrieve Action Details based on product request
     * @param recordId - recordId
     * @return List<Action__c>
     */
    @AuraEnabled(cacheable=true)
    public static List<Action__c> getActionDetails(String recordId) {
        try {
            return ActionsDAO.newInstance()
                .getActionsByProductRequestAndRecordType(
                    new Set<Id>{ recordId },
                    ActionsDAO.ACTIVITY_RECORDTYPE_ID
                );
        } catch (Exception e) {
            NebulaLoggerService.logExceptionDetails(
                'Exception caught in method getActionDetails in class ActionCtrl.',
                e
            );
            throw e;
        }
    }

    /**
     * @description retrieve Action Details based on product request
     * @param recordId - recordId
     * @return List<Action__c>
     */
    @AuraEnabled(cacheable=true)
    public static List<Action__c> getInvestigationActionDetails(String recordId) {
        try {
            return ActionsDAO.newInstance()
                .getActionsByProductRequestAndRecordType(
                    new Set<Id>{ recordId },
                    ActionsDAO.INVESTIGATION_RECORDTYPE_ID
                );
        } catch (Exception e) {
            NebulaLoggerService.logExceptionDetails(
                'Exception caught in method getInvestigationActionDetails in class ActionCtrl.',
                e
            );
            throw e;
        }
    }

    /**
     * @description retrieve List of Consultancies based on product request
     * @param recordId - recordId
     * @return ActivitySectionDetails
     */
    @AuraEnabled(cacheable=true)
    public static ActivitySectionDetails getActivitySectionDetails(String recordId) {
        try {
            ActivitySectionDetails response = new ActivitySectionDetails();
            List<Consultancy__c> consultancies = ConsultanciesDAO.newInstance()
                .getConsultanciesWithActionsBySetProductRequestIds(new Set<Id>{ recordId });
            for (Consultancy__c c : consultancies) {
                response.id = c.Id;
                response.markActivityAsComplete = c.Mark_Activity_as_Complete__c;
                response.markInvestigationAsComplete = c.Mark_Investigation_as_Complete__c;
                response.investigationSummary = c.Investigation_Summary__c;
                response.prodReqStatus = c.Product_Request__r.Product_Request_Status__c;
                if (c.Actions__r.size() > 0) {
                    response.hasActivity = true;
                } else {
                    response.hasActivity = false;
                }
            }
            return response;
        } catch (Exception e) {
            NebulaLoggerService.logExceptionDetails(
                'Exception caught in method getActivitySectionDetails in class ActionCtrl.',
                e
            );
            throw (e);
        }
    }

    /**
     * @description retrieve map of related file records
     * @param recordId - recordId
     * @return Map<Id, String> mapIdTitle
     */
    @AuraEnabled(cacheable=false)
    public static Map<Id, String> getRelatedFilesByRecordId(String recordId) {
        try {
            List<ContentDocumentLink> files = ContentDocumentLinksDAO.newInstance()
                .getContentDocLinksBySetLinkedEntityIds(recordId);
            Set<Id> fileIDs = new Set<Id>();
            for (ContentDocumentLink docLink : files) {
                fileIDs.add(docLink.ContentDocumentId);
            }
            List<ContentVersion> docs = ContentVersionsDAO.newInstance()
                .getContentVersionBySetContentDocumentIds(fileIds);
            Map<Id, String> mapIdTitle = new Map<Id, String>();
            for (ContentVersion docLink : docs) {
                mapIdTitle.put(docLink.ContentDocumentId, docLink.Title);
            }
            return mapIdTitle;
        } catch (Exception e) {
            NebulaLoggerService.logExceptionDetails(
                'Exception caught in method getRelatedFilesByRecordId in class ActionCtrl.',
                e
            );
            throw (e);
        }
    }

    public class ActivitySectionDetails {
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
        public String prodReqStatus;
    }
}
