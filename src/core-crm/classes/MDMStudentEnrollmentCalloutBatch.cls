/**
 * @description Batch class for MDM Student Enrollment callout
 * @see MDMCalloutEvenHandler
 *
 * @author Accenture
 *
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.karl.munoz            | August 12, 2024       | DEPP-10490             | Created file                 |
 */
public with sharing class MDMStudentEnrollmentCalloutBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{

    private static final String ENDPOINT_ESB_MDM_STUDENT_ENROLLMENT = System.Label.ESBEndpointMDMStudentEnrolment;
    private Set<Id> courseConnectionIds;

    public MDMStudentEnrollmentCalloutBatch(Set<Id> courseConnectionIds) {
        this.courseConnectionIds = courseConnectionIds;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return CourseConnectionsDAO.newInstance().queryLocatorGetMDMStudentEnrollmentByIds(courseConnectionIds, AccessLevel.SYSTEM_MODE);
    }    

    public void execute(Database.BatchableContext bc, List<hed__Course_Enrollment__c> courseConnectionList) {
        if (!courseConnectionList.isEmpty()) {
            HTTPResponse httpResponse;
            try {
                String endpoint = 'callout:ESB' + ENDPOINT_ESB_MDM_STUDENT_ENROLLMENT;
                httpResponse = IntegrationCallOutCtrl.doCallout(endpoint, 'POST', buildPayload(courseConnectionList));
                
                if (httpResponse.getStatusCode() != 200) {
                    Logger.error('Callout failed with status code ' + httpResponse.getStatusCode()).setHttpResponseDetails(httpResponse);
                }

            } catch (Exception e) {
                Logger.error('Callout exception occurred: ' + e.getMessage()).setExceptionDetails(e);
            } finally {
                if(Logger.getBufferSize() > 0) {
                    Logger.saveLog();
                }
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
        public PayloadContact Contact {get; set;} 
    }

    private class PayloadContact {
        public String Id {get; set;} 
        public List<PayloadCourseEnrollment> temphed_Course_Enrollment_tempC {get; set;} 
    }

    private class PayloadCourseEnrollment {
        public String Offering_Start_Date_tempC {get; set;} 
        public String Offering_End_Date_tempC {get; set;} 
    }

    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext bc) {}
}