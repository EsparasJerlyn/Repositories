/**
 * @description Class used by batch job to call LMS API
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                        | JIRA                          | Change Summary                                |
      |---------------------------|-----------------------------|-------------------------------|-----------------------------------------------|
      | john.bo.a.pineda          | May 07, 2022                | DEPP-2549                     | Created file                                  |
      | wli                       | May 08/09/10/11, 2022       | DEPP-2549,2565,2581,2588      | Update                                        |
      | kenneth.f.alsay           | September 26, 2023          | DEPP-6629                     | Deleted LMSCourseWrapper and calloutLMSCourse |
      | kenneth.f.alsay           | October 3, 2023             | DEPP-6629                     | Added Logger on doCallout lines               |
 */
public without sharing class LMSIntegrationManager {

    private static final String ENDPOINT_ESB_LMS_COURSE_OFFERING = System.Label.ESBEndpointLMSCourseOffering;
    private static final String ENDPOINT_ESB_LMS_COURSE_ENROLLMENT = System.Label.ESBLMSCourseEnrolment;
    private static final String ENDPOINT_ESB_SAMS_REGISTER_LEARNER = System.Label.ESBSAMSRegisterLearner;

    public static void calloutLMSCourseOffering(List<hed__Course_Offering__c> courseOfferings) {
        List<CourseOfferingWrapper> courseOfferingList = new List<CourseOfferingWrapper>();

        for (hed__Course_Offering__c courseOffering : courseOfferings) {
            courseOfferingList.add(new CourseOfferingWrapper(courseOffering));
            courseOffering.LMS_Integration_Status__c = 'Sent';
        }

        try {
            doCallout(ENDPOINT_ESB_LMS_COURSE_OFFERING, 'POST', JSON.serialize(courseOfferingList));
            update courseOfferings;
        } catch(Exception e) {
            Logger.error('Exception caught in finish in class LMSIntegrationManager, method calloutLMSCourseOffering.')
                .setExceptionDetails(e);
        } finally {
            if(Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }
    }

    public static void calloutLMSCourseEnrollment(List<hed__Course_Enrollment__c> courseEnrollments) {
        List<CourseEnrollmentWrapper> courseEnrollmentList = new List<CourseEnrollmentWrapper>();

        for (hed__Course_Enrollment__c courseEnrollment : courseEnrollments) {
            courseEnrollmentList.add(new CourseEnrollmentWrapper(courseEnrollment));
            courseEnrollment.LMS_Integration_Status__c = 'Sent';
        }

        try {
            doCallout(ENDPOINT_ESB_LMS_COURSE_ENROLLMENT, 'POST', JSON.serialize(courseEnrollmentList));
            update courseEnrollments;
        } catch(Exception e) {
            Logger.error('Exception caught in finish in class LMSIntegrationManager, method calloutLMSCourseEnrollment.')
                .setExceptionDetails(e);
        } finally {
            if(Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }
    }

    public static void calloutSAMSRegisterLearner(Contact contact) {
        try {
            doCallout(ENDPOINT_ESB_SAMS_REGISTER_LEARNER, 'POST', JSON.serialize(new LearnerWrapper(contact)));
            contact.put('SAMS_Integration_Status__c', 'Sent');
            update contact;
        } catch(Exception e) {
            Logger.error('Exception caught in finish in class LMSIntegrationManager, method calloutSAMSRegisterLearner.')
                .setExceptionDetails(e);
        } finally {
            if(Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }
    }

    /**
   * @description Performs necessary callout
   * @param endpointPath - path of the endpoint
   * @param type - type of request
   * @param payload - payload request
   * @return callout response
   */
    private static HttpResponse doCallout(String endpointPath, String type, String payload) {
        String endpoint = 'callout:ESB' + endpointPath;
        HttpRequest request = new HttpRequest();
        Http http = new Http();
        HTTPResponse response = new HTTPResponse();

        request.setEndpoint(endpoint);
        request.setMethod(type);
        request.setbody(payload);
        request.setTimeout(120000);
        request.setHeader('Content-Type', 'application/json');

        if (!Test.isRunningTest()) {
            response = http.send(request);
        }
        
        return response;
    }

    private class CourseOfferingWrapper {
        private String courseOfferingSFId {get; set;}

        private CourseOfferingWrapper(hed__Course_Offering__c courseOffering) {
            courseOfferingSFId = courseOffering.Id;
        }
    }

    private class CourseEnrollmentWrapper {
        private String Id {get; set;}

        private CourseEnrollmentWrapper(hed__Course_Enrollment__c courseEnrollment) {
            Id = courseEnrollment.Id;
        }
    }

    private class LearnerWrapper {
        private String sfid {get; set;}
        private String nominatedStudentId {get; set;}
        private String title {get; set;}
        private String firstName {get; set;}
        private String lastName {get; set;}
        private String birthDate {get; set;}
        private String gender {get; set;}
        private String mobile {get; set;}
        private String email {get; set;}

        private LearnerWrapper(Contact contact) {
            sfid = contact.Id;
            nominatedStudentId = contact.Nominated_Student_ID__c;
            title = contact.Salutation;
            firstName = contact.FirstName;
            lastName = contact.LastName;
            birthDate =  contact.Birthdate != null ? contact.Birthdate.year() + '-' + String.valueOf(contact.Birthdate.month()).leftPad(2,'0') + '-' + String.valueOf(contact.Birthdate.day()).leftPad(2,'0') : null;
            if (contact.hed__Gender__c == 'Male') {
                gender = 'M';
            } else if (contact.hed__Gender__c == 'Female') {
                gender = 'F';
            } else if (contact.hed__Gender__c == 'Other') {
                gender = 'X';
            } else {
                gender = null;
            }
            mobile = contact.MobilePhone;
            email = contact.Registered_Email__c;
        }
    }
}