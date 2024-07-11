/**
 * @description Test for trackAttendanceAndEvaluation Controller
 *
 * @see TrackAttendanceAndEvaluationCtrl
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA      | Change Summary                  |
      |---------------------------|-----------------------|-----------|---------------------------------|
      | adrian.c.habasa           | Febuary 14, 2022      | DEPP-1247 | Created file                    |
      |                           |                       |           |                                 |
*/
@isTest
public with sharing class TrackAttendanceAndEvaluationCtrlTest {
   private static Map <String,Schema.RecordTypeInfo> courseConnectionRecordTypes = hed__Course_Enrollment__c.sObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getRecordTypeInfosByName();
   private static Id shortCourseProdReqId = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get('Short_Course').getRecordTypeId();
   private static Id studentRTId = courseConnectionRecordTypes.get('Student').getRecordTypeId();
   private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
   private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();

    @testSetup
    static void setupMethod(){
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        List<Contact> contacts;
        contacts = TestDataFactory.createTestContactRecords(1);
        insert contacts;

        List<Account> accounts;
        accounts = TestDataFactory.createTestAccountRecords(1);
        for(Account acc : accounts){
            acc.RecordTypeId = ACCT_UNIV_DEP_ID;
            acc.Organization_Unit_Level__c = '2';
        }
        insert accounts;

        List<hed__Term__c> terms;
        terms = TestDataFactory.createTestTermRecords(100,accounts[0].Id);
        insert terms;

        List<Product_Request__c> prodRequest;
        prodRequest = TestDataFactory.createTestProductRequestRecords(1);
        prodRequest[0].Product_Request_Name__c = 'Activity';
        prodRequest[0].RecordTypeId = shortCourseProdReqId;
        insert prodRequest;

        List<hed__Program_Plan__c> programPlans;
        programPlans = TestDataFactory.createTestProgramPlanRecords(25);
        insert programPlans;

        List<Program_Offering__c> programOfferings;
        programOfferings = TestDataFactory.createTestProgramOfferingRecords(25, programPlans);
        insert programOfferings;

        List<hed__Course__c> courses;
        courses = TestDataFactory.createTestCourseRecords(1,accounts[0].Id,prodRequest[0].Id);
        insert courses;

        List<hed__Course_Offering__c> courseOfferings;
        courseOfferings = TestDataFactory.createTestCourseOfferingRecord(1,courses,terms);
        insert courseOfferings;

        List<Session__c> sessions;
        sessions = TestDataFactory.createTestSessionRecords(1);
        sessions[0].Course_Offering__c = courseOfferings[0].Id;
        sessions[0].Date__c =  Date.newInstance(2022, 01, 06);
        sessions[0].Start_Time_v2__c =Time.newInstance(15, 12, 30, 0);
        sessions[0].End_Time_v2__c =Time.newInstance(15, 12, 30, 0);
        sessions[0].Facilitator__c = contacts[0].Id;

        hed__Facility__c fac = new hed__Facility__c();
        fac.Name = 'test';
        insert fac;

        sessions[0].Location__c = fac.Id;
        insert sessions;

        List<hed__Course_Enrollment__c> students;
        students = TestDataFactory.createTestCourseConnectionRecord(1,contacts[0].Id,courseOfferings);
        students[0].RecordTypeId =studentRTId;

        insert students;

        List<hed__Attendance_Event__c> attendance;
        attendance = TestDataFactory.createTestAttendanceRecords(1,students[0].hed__Contact__r.Id,students[0].Id,sessions[0].Id);
        insert attendance;
    }

    @isTest
    private static void getStudents()
    {

        Test.startTest();
         System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator)
        {

            List<TrackAttendanceAndEvaluationCtrl.CourseRelatedRecords> getRecords = new List<TrackAttendanceAndEvaluationCtrl.CourseRelatedRecords>();
            getRecords = TrackAttendanceAndEvaluationCtrl.getRelatedCourseOfferingsAndSessions(string.valueOf([SELECT Id FROM Product_Request__c WHERE RecordTypeId =:shortCourseProdReqId LIMIT 1].Id));

            System.assert(!getRecords.isEmpty(), 'No records retrieved.');
        }
        Test.stopTest();
    }

    @isTest
    private static void upsertAttendanceRecord()
    {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator)
        {
            List<hed__Attendance_Event__c> attedanceToUpdate = new List<hed__Attendance_Event__c>([SELECT Id FROM hed__Attendance_Event__c LIMIT 1]);
            attedanceToUpdate[0].Present__c = true;

            TrackAttendanceAndEvaluationCtrl.upsertAttendance(attedanceToUpdate);
            System.assert(![SELECT Id FROM hed__Attendance_Event__c WHERE Present__c = true].isEmpty(),'Error updating attendance');

        }
        Test.stopTest();
    }

}