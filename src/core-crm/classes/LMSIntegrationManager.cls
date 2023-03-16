/**
 * @description Class used by batch job to call LMS API
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | john.bo.a.pineda          | May 07, 2022          | DEPP-2549    | Created file                                |
      | wli                       | May 08/09/10/11, 2022       | DEPP-2549,2565,2581,2588    | Update                                      |
 */
public without sharing class LMSIntegrationManager {

    private static final String ENDPOINT_ESB_LMS_COURSE = System.Label.ESBEndpointLMSCourse;
    private static final String ENDPOINT_ESB_LMS_COURSE_OFFERING = System.Label.ESBEndpointLMSCourseOffering;
    private static final String ENDPOINT_ESB_LMS_COURSE_ENROLLMENT = System.Label.ESBLMSCourseEnrolment;
    private static final String ENDPOINT_ESB_SAMS_REGISTER_LEARNER = System.Label.ESBSAMSRegisterLearner;

    public static void calloutLMSCourse(hed__Course__c course) {
        HttpResponse response = doCallout(ENDPOINT_ESB_LMS_COURSE, 'POST', JSON.serialize(new LMSCourseWrapper(course)));

        course.LMS_Integration_Status__c = 'Sent';
        update course;
    }

    public static void calloutLMSCourseOffering(hed__Course_Offering__c courseOffering) {
        HttpResponse response = doCallout(ENDPOINT_ESB_LMS_COURSE_OFFERING, 'POST', JSON.serialize(new LMSCourseOfferingWrapper(courseOffering)));

        courseOffering.LMS_Integration_Status__c = 'Sent';
        update courseOffering;
    }

    public static void calloutLMSCourseEnrollment(List<hed__Course_Enrollment__c> courseEnrollments) {
        List<CourseEnrollmentWrapper> courseEnrollmentList = new List<CourseEnrollmentWrapper>();

        for (hed__Course_Enrollment__c courseEnrollment : courseEnrollments) {
            courseEnrollmentList.add(new CourseEnrollmentWrapper(courseEnrollment));
            courseEnrollment.LMS_Integration_Status__c = 'Sent';
        }

        HttpResponse response = doCallout(ENDPOINT_ESB_LMS_COURSE_ENROLLMENT, 'POST', JSON.serialize(new LMSCourseEnrollmentWrapper(courseEnrollmentList)));

        update courseEnrollments;
    }

    public static void calloutSAMSRegisterLearner(Contact contact) {
        HttpResponse response = doCallout(ENDPOINT_ESB_SAMS_REGISTER_LEARNER, 'POST', JSON.serialize(new LearnerWrapper(contact)));

        contact.put('SAMS_Integration_Status__c', 'Sent');
        update contact;
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
  
    private class LMSCourseWrapper {
        private String courseSFId {get; set;}
        private String courseCode {get; set;}
        private String courseTitle {get; set;}
        private String courseType {get; set;}
        private String primaryDeliveryPlatform {get; set;}

        private LMSCourseWrapper(hed__Course__c course) {
            courseSFId = course.Id;
            courseCode = course.Course_Code__c;
            courseTitle = course.Name;
            courseType = course.Recordtype_Name__c;
            primaryDeliveryPlatform = course.Primary_Delivery_Platform__c;
        }
    }

    private class LMSCourseOfferingWrapper {
        private String courseOfferingSFId {get; set;}
        private String courseCode {get; set;}
        private String courseName {get; set;}
        private String courseOfferingName {get; set;}
        private String startDate {get; set;}
        private String endDate {get; set;}
        private String primaryDeliveryPlatform {get; set;}

        private LMSCourseOfferingWrapper(hed__Course_Offering__c courseOffering) {
            courseOfferingSFId = courseOffering.Id;
            courseOfferingName = courseOffering.Name;
            courseCode = courseOffering.Course_Code__c;
            courseName = courseOffering.hed__Course__r.Name;
            startDate = courseOffering.hed__Start_Date__c != null ? courseOffering.hed__Start_Date__c.year() + '-' + String.valueOf(courseOffering.hed__Start_Date__c.month()).leftPad(2,'0') + '-' + String.valueOf(courseOffering.hed__Start_Date__c.day()).leftPad(2,'0') : null;
            endDate = courseOffering.hed__End_Date__c!= null ? courseOffering.hed__End_Date__c.year() + '-' + String.valueOf(courseOffering.hed__End_Date__c.month()).leftPad(2,'0') + '-' + String.valueOf(courseOffering.hed__End_Date__c.day()).leftPad(2,'0') : null;
            primaryDeliveryPlatform = courseOffering.hed__Course__r.Primary_Delivery_Platform__c;
        }
    }
  
    private class LMSCourseEnrollmentWrapper {
        private List<CourseEnrollmentWrapper> courseEnrolments {get; set;}

        private LMSCourseEnrollmentWrapper(List<CourseEnrollmentWrapper> courseEnrolments) {
            this.courseEnrolments = courseEnrolments;
        }
    }

    private class CourseEnrollmentWrapper {
        private String courseEnrolmentSFId {get; set;}
        private String courseCode {get; set;}
        private String courseOfferingName {get; set;}
        private String courseOfferingSFId {get; set;}
        private String roleType {get; set;}
        private String startDate {get; set;}
        private String endDate {get; set;}
        private String QUTIdentityId {get; set;}
        private String QUTstudentId {get; set;}
        private String QUTemployeeId {get; set;}
        private String primaryDeliveryPlatform {get; set;}

        private CourseEnrollmentWrapper(hed__Course_Enrollment__c courseEnrollment) {
            courseEnrolmentSFId = courseEnrollment.Id;
            courseCode = courseEnrollment.Course_Code__c;
            courseOfferingName = courseEnrollment.Course_Offering_Name__c;
            courseOfferingSFId = courseEnrollment.hed__Course_Offering__r.Id;
            roleType = courseEnrollment.Recordtype_Name__c == 'Faculty' ? 'STAFF' : 'STUDENT';
            startDate =   courseEnrollment.Course_Offering_Start_Date__c != null ? courseEnrollment.Course_Offering_Start_Date__c.year() + '-' + String.valueOf(courseEnrollment.Course_Offering_Start_Date__c.month()).leftPad(2,'0') + '-' + String.valueOf(courseEnrollment.Course_Offering_Start_Date__c.day()).leftPad(2,'0') : null;
            endDate =  courseEnrollment.Course_Offering_End_Date__c != null ? courseEnrollment.Course_Offering_End_Date__c.year() + '-' + String.valueOf(courseEnrollment.Course_Offering_End_Date__c.month()).leftPad(2,'0') + '-' + String.valueOf(courseEnrollment.Course_Offering_End_Date__c.day()).leftPad(2,'0') : null;
            QUTIdentityId = courseEnrollment.hed__Contact__r.QUT_Identity_ID__c;
            QUTstudentId = courseEnrollment.hed__Contact__r.QUT_Student_ID__c;
            QUTemployeeId = courseEnrollment.hed__Contact__r.QUT_Employee_ID__c;
            primaryDeliveryPlatform = courseEnrollment.hed__Course_Offering__r.hed__Course__r.Primary_Delivery_Platform__c;
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