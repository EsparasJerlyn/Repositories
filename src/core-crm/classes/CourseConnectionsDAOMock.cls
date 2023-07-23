/**
 * @description Mock DAO Class for Course Connection Object
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                             |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------|
      | mark.j.mahilum                 | July 21, 2023         | DEPP-5799              | Created File                               |
 */
@isTest
public inherited sharing class CourseConnectionsDAOMock extends DmlBaseMock implements ICourseConnectionsDAO { 
    public Map<Id, hed__Course_Enrollment__c> courseConnectionMap;

    public CourseConnectionsDAOMock() {
        super(new Map<Id, hed__Course_Enrollment__c>(), Schema.hed__Course_Enrollment__c.SObjectType);
        this.courseConnectionMap = (Map<Id, hed__Course_Enrollment__c>) super.records;
    }

    public Schema.SObjectType getSObjectType() {
        return hed__Course_Enrollment__c.SObjectType;
    }

    public List<hed__Course_Enrollment__c> getCourseConnectionByPEContactIds(
        Set<Id> contactIds,
        String accessLevel
    ) {
        List<hed__Course_Enrollment__c> courseConnectionList = new List<hed__Course_Enrollment__c>();

        for (hed__Course_Enrollment__c record : courseConnectionMap.values()) {
            if (contactIds.contains(record.hed__Program_Enrollment__r.hed__Contact__c)) {
                courseConnectionList.add(record);
            }
        }

        return courseConnectionList;
    }

}