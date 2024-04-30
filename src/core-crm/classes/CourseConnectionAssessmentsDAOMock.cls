/**
 * @description Mock DAO Class for Course Connection Assessments Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                 |
 *    |--------------------------------|-----------------------|------------------------|------------------------------------------------|
 *    | julie.jane.alegre              | April 29, 2024        | DEPP-8041              | Created file                                   |
 *    |                                |                       |                        |                                                |
 */
@isTest
public inherited sharing class CourseConnectionAssessmentsDAOMock extends DmlBaseMock implements ICourseConnectionAssessmentsDAO{
    public Map<Id, Course_Connection_Assessment__c> courseConnectionAssessmentMap;

    public Schema.SObjectType getSObjectType() {
        return Course_Connection_Assessment__c.SObjectType;
    }

    public CourseConnectionAssessmentsDAOMock() {
        super(new Map<Id, Course_Connection_Assessment__c>(), Schema.Course_Connection_Assessment__c.SObjectType);
        this.courseConnectionAssessmentMap = (Map<Id, Course_Connection_Assessment__c>) super.records;
    }

}
