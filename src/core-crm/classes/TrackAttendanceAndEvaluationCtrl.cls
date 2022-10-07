/**
 * @description Controller class for trackAttendanceAndEvaluation LWC
 *
 * @see ../lwc/trackAttendanceAndEvaluation
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA      | Change Summary                  |
      |---------------------------|-----------------------|-----------|---------------------------------|
      | adrian.c.habasa           | Febuary 11, 2022      | DEPP-1247 | Created file                    |
      | kathy.cornejo             | July 27, 2022         | DEPP-1771     | Only show Registrations having Active Status    |
      | arsenio.jr.dayrit         | Auguts 04, 2022       | DEPP-3684 | Add Active Status on Course Enrollment |
      |                           |                       |           |                                 | 
*/

public with sharing class TrackAttendanceAndEvaluationCtrl {

    private static Map <String,Schema.RecordTypeInfo> courseConnectionRecordTypes = hed__Course_Enrollment__c.sObjectType.getDescribe().getRecordTypeInfosByName();
    private static Id studentRTId = courseConnectionRecordTypes.get('Student').getRecordTypeId();
    
     //for Course Offering
    @AuraEnabled(cacheable=true)
     public static List<CourseRelatedRecords> getRelatedCourseOfferingsAndSessions(Id productRequestId)
     {
        List<CourseRelatedRecords> courseData = new List<CourseRelatedRecords>(); 

        Id courseId = [SELECT Id FROM hed__Course__c WHERE ProductRequestID__c =: productRequestId LIMIT 1]?.Id;    

        Map<Id,hed__Course_Offering__c> courseOfferingMap = new Map<Id,hed__Course_Offering__c>(
            [
                Select Id, Name, hed__Start_Date__c, hed__End_Date__c,
                       Delivery_Type__c, Evaluation_Type__c
                FROM hed__Course_Offering__c 
                WHERE hed__Course__c =: courseId
                ORDER BY hed__Start_Date__c ASC
            ]
        );

        List<Session__c> sessionlist = 
            [
                Select Id, Name, Date__c, Start_Time_v2__c, End_Time_v2__c, Course_Offering__c,
                (
                    Select Id, Name,Present__c,hed__Course_Connection__r.hed__Contact__r.Name
                    FROM Attendance_Events__r
                    WHERE hed__Course_Connection__r.RecordTypeId=:studentRTId
                ) 
                FROM Session__c 
                WHERE Course_Offering__c in:courseOfferingMap.keySet()
            ];

        List<hed__Course_Enrollment__c> courseConnectionList = 
            [
                Select Id,Name,hed__Course_Offering__c,hed__Contact__r.Name 
                FROM hed__Course_Enrollment__c 
                WHERE hed__Status__c = 'Active' AND RecordTypeId=:studentRTId AND hed__Course_Offering__c in:courseOfferingMap.keySet()
            ];

        Map<Id,List<Session__c>> sessionOfferingMap = new Map<Id, List<Session__c>>();
        Map<Id,List<hed__Course_Enrollment__c>> courseConnectionMap = new Map<Id, List<hed__Course_Enrollment__c>>();
        
        CourseRelatedRecords relatedCourseData;
        //create course to session map
        for(Session__c ses : sessionlist){
            if(!sessionOfferingMap.containsKey(ses.Course_Offering__c)){
                sessionOfferingMap.put(ses.Course_Offering__c, new List<Session__c>());    
            }
            sessionOfferingMap.get(ses.Course_Offering__c).add(ses);
        } 
        
        for(hed__Course_Enrollment__c courCon : courseConnectionList)
        {
            if(!courseConnectionMap.containsKey(courCon.hed__Course_Offering__c))
            {
                courseConnectionMap.put(courCon.hed__Course_Offering__c, new List<hed__Course_Enrollment__c>());
            }
            courseConnectionMap.get(courCon.hed__Course_Offering__c).add(courCon);
        }

        for(Id id: courseOfferingMap.keySet())
        {
            relatedCourseData = new CourseRelatedRecords();
            relatedCourseData.id = courseOfferingMap.get(id).id;
            relatedCourseData.name = courseOfferingMap.get(id).name;
            relatedCourseData.startDate = courseOfferingMap.get(id).hed__Start_Date__c;
            relatedCourseData.endDate = courseOfferingMap.get(id).hed__End_Date__c;
            relatedCourseData.deliveryType = courseOfferingMap.get(id).Delivery_Type__c;
            relatedCourseData.evaluationType = courseOfferingMap.get(id).Evaluation_Type__c;
            if(courseConnectionMap.containsKey(id))
            {
                relatedCourseData.courseConnections = courseConnectionMap.get(id);
            }
            else
            {
                relatedCourseData.courseConnections = new List<hed__Course_Enrollment__c>();
            }
            if(sessionOfferingMap.containsKey(id))
            {
                relatedCourseData.sessions = sessionOfferingMap.get(id);
            }else{
                relatedCourseData.sessions = new List<Session__c>();
            }
            courseData.add(relatedCourseData);

        }
        
        return courseData;
    }
    

	public class CourseRelatedRecords{
		@AuraEnabled
		public String id;
		@AuraEnabled
		public String name;
		@AuraEnabled
		public Date startDate;
		@AuraEnabled
		public Date endDate;
        @AuraEnabled
		public String deliveryType;
        @AuraEnabled
		public String evaluationType;               
		@AuraEnabled
		public List<Session__c> sessions;
        @AuraEnabled
		public List<hed__Course_Enrollment__c> courseConnections;
	}
	

    /**
     * @description insert Plan Requirement records
     * @param planRequirementToUpdate - plan requirement list to update
     */
    @AuraEnabled
    public static void upsertAttendance(List<hed__Attendance_Event__c> recordsToUpsert){
        if(!recordsToUpsert.isEmpty()){
            upsert(recordsToUpsert);
        }
    }
}
