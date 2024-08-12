/**
 * @description Do ESB Integration to MDM when a course connection is created or updated
 * @see CourseConnectionTriggerHandler.cls
 * @author Accenture
 * @history
 * | Dev               | JIRA      | Date       | Change Summary
 * | alexander.cadalin | DEPP-4988 | 2023-02-13 | Created file
 * |                   |           | 2023-02-16 | Documentation, revisions
 * |                   |           | 2023-02-17 | payload building and callout revisions
 * | eccarius.munoz    | DEPP-10490| 2024-08-12 | transferred logic to MDMStudentEnrollmentCalloutBatch and used platform event
 */
public with sharing class ESBIntegrateOnCourseConnectionUpsert {
    private static final String CALLOUT_ENDPOINT = System.Label.ESBEndpointMDMStudentEnrolment;
    
    /**
     * @description Do a callout to MDM
     * @param newItems An map between the new/updated course enrllments to their ids
     */
    public static void calloutToMDM(Map<Id, hed__Course_Enrollment__c> newItems) {
        Integration_Settings__c integrationSettings = Integration_Settings__c.getOrgDefaults();
        if(integrationSettings.Allow_ESB_Integration__c && UserInfo.getUserName() != 'ESB Integration User') {

            List<MDM_Callout_Event__e> mdmCalloutEventList = new List<MDM_Callout_Event__e>();

            String objectName = hed__Course_Enrollment__c.getSObjectType().toString();

            for(hed__Course_Enrollment__c courseConnection : newItems.values()){
                mdmCalloutEventList.add(
                    new MDM_Callout_Event__e(
                        Course_Connection_Id__c = courseConnection.Id,
                        Triggering_Record__c = objectName
                    )
                );
            }

            if(!mdmCalloutEventList.isEmpty()){ 
                try {
                    EventBus.publish(mdmCalloutEventList);
                } catch (Exception e) {
                    // prettier-ignore
                    NebulaLoggerService.logExceptionDetails('Exception caught in validateAddress method.', e);
                }
            } 
        }
        
    }
    
}