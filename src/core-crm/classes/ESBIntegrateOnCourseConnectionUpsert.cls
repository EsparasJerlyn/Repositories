/**
 * @description Do ESB Integration to MDM when a course connection is created or updated
 * @see CourseConnectionTriggerHandler.cls
 * @author Accenture
 * @history
 * | Dev               | JIRA      | Date       | Change Summary
 * | alexander.cadalin | DEPP-4988 | 2023-02-13 | Created file
 * |                   |           | 2023-02-16 | Documentation, revisions
 * |                   |           | 2023-02-17 | payload building and callout revisions
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
            HTTPResponse response;
            try{
                response = IntegrationCallOutCtrl.doCallout(
                    'callout:ESB' + CALLOUT_ENDPOINT, 
                    'POST', 
                    buildPayload(newItems.values()));      
                if(response.getStatusCode() != 200){
                    Logger.error('Status Not 200 on Course Connection insert/update').setHttpResponseDetails(response);
                }
            } catch(Exception e) {
                Logger.error('Callout Exception on Course Connection insert/update').setExceptionDetails(e).setHttpResponseDetails(response);
            } finally {
                Logger.saveLog();
            }
        }
        
    }
    
    /**
     * @description Create the MDM payload
     * @param contactIdToCourseEnrollmentMap Map of course enrollments to build the payload from
     * @return payload the payload in JSON string
     */
    private static String buildPayload(List<hed__Course_Enrollment__c> newItems) {
        Map<Id, Payload> contactIdToPayloadMap = new Map<Id, Payload>();
        for(hed__Course_Enrollment__c cenr : newItems) {
            Payload payload = new Payload();
            if(contactIdToPayloadMap.containsKey(cenr.hed__Contact__c)) {
                payload = contactIdToPayloadMap.get(cenr.hed__Contact__c);
                
            } else {
                payload.Contact = new PayloadContact();
                payload.Contact.Id = cenr.hed__Contact__c;
                payload.Contact.temphed_Course_Enrollment_tempC = new List<PayloadCourseEnrollment>();
            }
            PayloadCourseEnrollment payloadCenrItem = new PayloadCourseEnrollment();
            payloadCenrItem.Offering_End_Date_tempC = String.valueOf(cenr.Course_Offering_End_Date__c);
            payloadCenrItem.Offering_Start_Date_tempC = String.valueOf(cenr.Course_Offering_Start_Date__c);
            payload.Contact.temphed_Course_Enrollment_tempC.add(payloadCenrItem);
            contactIdToPayloadMap.put(cenr.hed__Contact__c, payload);
        }
        return JSON.serialize(contactIdToPayloadMap.values()).replace('tempC', '_c').replace('temphed', 'hed_');
    }

    private class Payload {
        public PayloadContact Contact {get; set;} //NOPMD
    }

    private class PayloadContact {
        public String Id {get; set;} //NOPMD
        public List<PayloadCourseEnrollment> temphed_Course_Enrollment_tempC {get; set;} //NOPMD
    }

    private class PayloadCourseEnrollment {
        public String Offering_Start_Date_tempC {get; set;} //NOPMD
        public String Offering_End_Date_tempC {get; set;} //NOPMD
    }
}