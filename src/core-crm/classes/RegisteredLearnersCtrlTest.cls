/**
 * @description Test Class for RegisteredLearnersCtrl.cls
 * @see ../class/NameBadge
 * 
 * @author Accenture
 * 
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | adrian.c.habasa           | March 24, 2022        | DEPP-1481            | Created file                 | 
      |                           |                       |                      |                              | 
 */

@isTest
private with sharing class RegisteredLearnersCtrlTest {
    
    private static final string PR_SHORTCOURSE = System.Label.RT_ProductRequest_ShortCourse;
    private static final Id shortCourseProdReqId = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(PR_SHORTCOURSE).getRecordTypeId();
    
    private static string studentRT = System.Label.RT_CourseConnection_Student;
    private static Id studentRTId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName().get(studentRT).getRecordTypeId();

    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();
    
    @testSetup
    private static void setupMethod(){
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        List<Contact> contacts;
        contacts = TestDataFactory.createTestContactRecords(1);
        insert contacts;

        List<Account> accounts;
        accounts = TestDataFactory.createTestAccountRecords(1);
        for(Account account : accounts){
            account.RecordTypeId = ACCT_UNIV_DEP_ID;
            account.Organization_Unit_Level__c = '2';
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

        List<hed__Course__c> courses;
        courses = TestDataFactory.createTestCourseRecords(1,accounts[0].Id,prodRequest[0].Id);
        insert courses;

        List<hed__Course_Offering__c> courseOfferings;
        courseOfferings = TestDataFactory.createTestCourseOfferingRecord(1,courses,terms);
        insert courseOfferings;

        List<hed__Course_Enrollment__c> students;
        students = TestDataFactory.createTestCourseConnectionRecord(1,contacts[0].Id,courseOfferings);
        students[0].RecordTypeId =studentRTId;
        students[0].hed__Status__c = 'Active';
        insert students;
        
        List<Questionnaire_Response_Summary__c> qRs = TestDataFactory.createTestQuestionnaireResponseSummaryRecords(1,courseOfferings,contacts[0]);
        for(Integer i = 0 ; i < qRs.size() ; i++){
            qrs[i].Contact__c = contacts[0].Id;
            qRs[i].Registration_Status__c = 'Confirmed';
            qRs[i].Course_Offering__c = courseOfferings[0].Id;}
        insert qRs;
    }

    @isTest
    private static void getLearners()
    {
        Test.startTest();
         System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator)
        {
            List<RegisteredLearnersCtrl.RegisteredLearners> getRecords = new List<RegisteredLearnersCtrl.RegisteredLearners>();
            getRecords =RegisteredLearnersCtrl.getRegisteredLearners([SELECT Id FROM hed__Course_Offering__c LIMIT 1].Id);
            System.assert(!getRecords.isEmpty(), 'No records retrieved.'); 
        }
        Test.stopTest();
    }
}
