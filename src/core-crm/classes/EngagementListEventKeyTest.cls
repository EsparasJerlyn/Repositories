/**
 * @description Test Class for EngagementListEventKey
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 |  May 15, 2024         | DEPP-8484              | Created file                 |
 */
@isTest
public with sharing class EngagementListEventKeyTest {
    
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserQUTESB();
    }

    @isTest
    static void equalsTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {

            Id contactId = new MockIdGenerator(Contact.SObjectType).getMockId();
            Id criteriaId = new MockIdGenerator(Engagement_List_Criteria__c.SObjectType).getMockId();
            Id programEnrollmentId = new MockIdGenerator(hed__Program_Enrollment__c.SObjectType).getMockId();
            Id completedCadenceId = new MockIdGenerator(Completed_Cadence__c.SObjectType).getMockId();
            Id courseConnectionId = new MockIdGenerator(hed__Course_Enrollment__c.SObjectType).getMockId();
            Id courseConnectionAssessmentId = new MockIdGenerator(Course_Connection_Assessment__c.SObjectType).getMockId();
            Id programEnrollmentBreachId = new MockIdGenerator(Program_Enrollment_Breach__c.SObjectType).getMockId();
            Id leaveOfAbsenceId = new MockIdGenerator(Leave_of_Absence__c.SObjectType).getMockId();
            Date keyDate = Date.today();
            
            Engagement_List_Event__c eventCandidate = new Engagement_List_Event__c();
            eventCandidate.Program_Enrollment__c = programEnrollmentId;
            eventCandidate.Completed_Cadence__c = completedCadenceId;
            eventCandidate.Course_Connection__c = courseConnectionId;
            eventCandidate.Course_Connection_Assessment__c = courseConnectionAssessmentId;
            eventCandidate.Program_Enrollment_Breach__c = programEnrollmentBreachId;
            eventCandidate.Leave_of_Absence__c = leaveOfAbsenceId;
            eventCandidate.Academic_Status__c = 'Showcause';
            eventCandidate.Previous_Academic_Status__c = 'Showcause';
            eventCandidate.Course_Enrollment_Status__c = 'Enrolled';
            eventCandidate.Key_Date__c = keyDate;
            eventCandidate.Program_Enrollment_Status__c = 'Active';
            eventCandidate.Has_Domestic_Phone__c = true;
            EngagementListEventKey eventCandidateKey = new EngagementListEventKey(eventCandidate, contactId, criteriaId);
            
            Engagement_List_Event__c existingEvent = new Engagement_List_Event__c();
            existingEvent.Program_Enrollment__c = programEnrollmentId;
            existingEvent.Completed_Cadence__c = completedCadenceId;
            existingEvent.Course_Connection__c = courseConnectionId;
            existingEvent.Course_Connection_Assessment__c = courseConnectionAssessmentId;
            existingEvent.Program_Enrollment_Breach__c = programEnrollmentBreachId;
            existingEvent.Leave_of_Absence__c = leaveOfAbsenceId;
            existingEvent.Academic_Status__c = 'Showcause';
            existingEvent.Previous_Academic_Status__c = 'Showcause';
            existingEvent.Course_Enrollment_Status__c = 'Enrolled';
            existingEvent.Key_Date__c = keyDate;
            existingEvent.Program_Enrollment_Status__c = 'Active';
            existingEvent.Has_Domestic_Phone__c = true;
            EngagementListEventKey existingEventKey = new EngagementListEventKey(existingEvent, contactId, criteriaId);

            System.assert(eventCandidateKey.equals(existingEventKey), 'Event Candidate Key must be equal to Existing Event Key.');
        }    

        Test.stopTest();
    }

    @isTest
    static void notEqualsTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {

            Id contactId = new MockIdGenerator(Contact.SObjectType).getMockId();
            Id criteriaId = new MockIdGenerator(Engagement_List_Criteria__c.SObjectType).getMockId();
            Id programEnrollmentId = new MockIdGenerator(hed__Program_Enrollment__c.SObjectType).getMockId();
            Date keyDate = Date.today();
            
            Engagement_List_Event__c eventCandidate = new Engagement_List_Event__c();
            eventCandidate.Program_Enrollment__c = programEnrollmentId;
            eventCandidate.Course_Enrollment_Status__c = 'Enrolled';
            eventCandidate.Key_Date__c = keyDate;
            eventCandidate.Program_Enrollment_Status__c = 'Active';
            EngagementListEventKey eventCandidateKey = new EngagementListEventKey(eventCandidate, contactId, criteriaId);
            
            Engagement_List_Event__c existingEvent = new Engagement_List_Event__c();
            existingEvent.Program_Enrollment__c = new MockIdGenerator(hed__Program_Enrollment__c.SObjectType).getMockId();
            existingEvent.Course_Enrollment_Status__c = 'Enrolled';
            existingEvent.Key_Date__c = keyDate;
            existingEvent.Program_Enrollment_Status__c = 'Test';
            existingEvent.Has_Domestic_Phone__c = true;
            EngagementListEventKey existingEventKey = new EngagementListEventKey(existingEvent, contactId, criteriaId);

            System.assert(!eventCandidateKey.equals(existingEventKey), 'Event Candidate Key must not be equal to Existing Event Key.');
        }    
         
        Test.stopTest();
    }

    @isTest
    static void testHashCode() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {

            Id contactId = new MockIdGenerator(Contact.SObjectType).getMockId();
            Id criteriaId = new MockIdGenerator(Engagement_List_Criteria__c.SObjectType).getMockId();

            Engagement_List_Event__c eventCandidate = new Engagement_List_Event__c();
            eventCandidate.Program_Enrollment_Status__c = 'Active';
            eventCandidate.Has_Domestic_Phone__c = true;

            EngagementListEventKey eventKey = new EngagementListEventKey(eventCandidate, contactId, criteriaId);
            Integer hashCode = eventKey.hashCode();       
            
            System.assert(hashCode!=null, 'Hash code should not be null.');
        }
    }
}