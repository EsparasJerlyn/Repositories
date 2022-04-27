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

@IsTest(SeeAllData = false)
private with sharing class RegisteredLearnersCtrlTest {
    
    private static User  currentUser = TestDataFactory.createUserRecords(1,'QUTeX').iterator().next();
    private static Map <String,Schema.RecordTypeInfo> courseConnectionRecordTypes = hed__Course_Enrollment__c.sObjectType.getDescribe().getRecordTypeInfosByName();
    private static Id shortCourseProdReqId = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get('Short_Course').getRecordTypeId();
    private static Id studentRTId = courseConnectionRecordTypes.get('Student').getRecordTypeId();
    
    @TestSetup
    private static void setupMethod(){
        List<Contact> contacts;
        contacts = TestDataFactory.createTestContactRecords(1);
        insert contacts;

        List<Account> accounts;
        accounts = TestDataFactory.createTestAccountRecords(1);
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
         System.runAs(currentUser)
        {
            List<RegisteredLearnersCtrl.RegisteredLearners> getRecords = new List<RegisteredLearnersCtrl.RegisteredLearners>();
            getRecords =RegisteredLearnersCtrl.getRegisteredLearners([SELECT Id FROM hed__Course_Offering__c LIMIT 1].Id);
            System.assert(!getRecords.isEmpty(), 'No records retrieved.'); 
        }
        Test.stopTest();
    }
}
