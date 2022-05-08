/**
 * @description Class used by batch job to call LMS API
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | john.bo.a.pineda          | May 07, 2022          | DEPP-2549    | Created file                                |
      | wli                       | May 08, 2022          | DEPP-2549    | Update                                      |
 */
public without sharing class LMSIntegrationManager {

    private static final String ENDPOINT_ESB_LMS_COURSE = System.Label.ESBEndpointLMSCourse;
    private static final String ENDPOINT_ESB_LMS_COURSE_OFFERING = System.Label.ESBEndpointLMSCourseOffering;

    public static void calloutLMSCourse(hed__Course__c course) {
        HttpResponse response = doCallout(ENDPOINT_ESB_LMS_COURSE, 'POST', JSON.serialize(new LMSCourseWrapper(course)));

        course.isLMSTriggered__c = true;
        update course;
    }

    public static void calloutLMSCourseOffering(hed__Course_Offering__c courseOffering) {
        HttpResponse response = doCallout(ENDPOINT_ESB_LMS_COURSE_OFFERING, 'POST', JSON.serialize(new LMSCourseOfferingWrapper(courseOffering)));

        courseOffering.isLMSTriggered__c = true;
        update courseOffering;
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

        System.debug('HTTP REQUEST: ' + payload);
        System.debug('HTTP RESPONSE: ' + response.getBody());

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
        private String courseOfferingName {get; set;}
        private String startDate {get; set;}
        private String endDate {get; set;}
        private String primaryDeliveryPlatform {get; set;}

        private LMSCourseOfferingWrapper(hed__Course_Offering__c courseOffering) {
            courseOfferingSFId = courseOffering.Id;
            courseOfferingName = courseOffering.Name;
            courseCode = courseOffering.Course_Code__c;
            startDate = courseOffering.hed__Start_Date__c != null ? courseOffering.hed__Start_Date__c.year() + '-' + courseOffering.hed__Start_Date__c.month() + '-' + courseOffering.hed__Start_Date__c.day() : null;
            endDate = courseOffering.hed__End_Date__c!= null ? courseOffering.hed__End_Date__c.year() + '-' + courseOffering.hed__End_Date__c.month() + '-' + courseOffering.hed__End_Date__c.day() : null;
            primaryDeliveryPlatform = courseOffering.hed__Course__r.Primary_Delivery_Platform__c;
        }
    }
  
}
