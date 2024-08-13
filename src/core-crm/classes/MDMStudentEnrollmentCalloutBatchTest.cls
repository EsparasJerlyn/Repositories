/**
 * @description Test class for MDMStudentEnrollmentCalloutBatch
 * 
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | August 13, 2024       | DEPP-10490             | Created file                 |
 */
@isTest
public with sharing class MDMStudentEnrollmentCalloutBatchTest {

    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();
    private static final Id PS_RT_OPE_ID = Schema.SObjectType.Product_Specification__c.getRecordTypeInfosByDeveloperName().get('OPE').getRecordTypeId();

    @testSetup
    static void testSetup() {
        Test.startTest();
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        TestDataFactoryUser.generateUserQUTESB();
        TestDataFactoryUser.generateUserSystemAdministrator();

        BypassTriggers__c bypass = new BypassTriggers__c(Bypass__c = true, SetupOwnerId = UserInfo.getOrganizationId());
        insert bypass;

        Integration_Settings__c integrationSettings = new Integration_Settings__c(Allow_ESB_Integration__c = true);
        insert integrationSettings;

        // Create an account.
        Account acco = new Account(
            Name = 'Account',
            RecordTypeId = ACCT_UNIV_DEP_ID,
            Organization_Unit_Level__c = '2'
        );
        insert acco;
        // Create contact.
        Contact cont = new Contact(
            LastName = 'Test'
        );
        insert cont;
        // Create a product specification.
        Product_Specification__c pros = TestDataFactory.createTestProductSpecsRecords(1, cont.Id)[0];
        pros.RecordTypeId = PS_RT_OPE_ID;
        insert pros;
        // Create a product request.
        Product_Request__c pror = new Product_Request__c(
            Product_Request_Name__c = 'Product Request',
            Product_Specification__c = pros.Id
        );
        insert pror;
        // Create a course.
        hed__Course__c cour = TestDataFactory.createTestCourseRecords(1, acco.Id, pror.Id)[0];
        insert cour;
        // Create a term.
        hed__Term__c term = new hed__Term__c(
            Name = 'Term',
            hed__Account__c = acco.Id
        );
        insert term;
        // Create a course offering.
        hed__Course_Offering__c coff = new hed__Course_Offering__c(
            Name = 'CourseOffering',
            hed__Course__c = cour.Id,
            hed__Term__c = term.Id,
            hed__Start_Date__c = System.today() + 2,
            hed__Capacity__c = 10
        );
        insert coff;
        // Create a course enrollment.
        hed__Course_Enrollment__c cenr = new hed__Course_Enrollment__c(
            hed__Contact__c = cont.Id,
            hed__Course_Offering__c = coff.Id
        );
        insert cenr;

        Test.stopTest();
    }

    @isTest
    private static void processStudentEnrollmentCalloutTest(){        
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){

            Test.setMock(HTTPCalloutMock.class, new GenericHttpCalloutMock(200, 'Ok', ''));

            hed__Course_Enrollment__c cenr = [SELECT Id, Enrollment_Status__c FROM hed__Course_Enrollment__c LIMIT 1];

            Test.startTest();
            MDMStudentEnrollmentCalloutBatch batch = new MDMStudentEnrollmentCalloutBatch(new Set<Id>{cenr.Id});
            Database.executeBatch(batch);
            Test.stopTest();

            List<LogEntry__c> logEntriesMessage = [SELECT Id FROM LogEntry__c WHERE LoggingLevel__c = 'ERROR' AND ApexClassName__c = 'MDMStudentEnrollmentCalloutBatch'];
            System.assert(logEntriesMessage.isEmpty(), 'MDM Student Enrollment Callout Batch failed.');
            
        }
    }

    @isTest
    private static void processStudentEnrollmentCalloutErrorTest(){        
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){

            Test.setMock(HTTPCalloutMock.class, new GenericHttpCalloutMock(500, 'Internal Server Error', ''));

            hed__Course_Enrollment__c cenr = [SELECT Id, Enrollment_Status__c FROM hed__Course_Enrollment__c LIMIT 1];

            Test.startTest();
            MDMStudentEnrollmentCalloutBatch batch = new MDMStudentEnrollmentCalloutBatch(new Set<Id>{cenr.Id});
            Database.executeBatch(batch);
            Test.stopTest();

            List<LogEntry__c> logEntriesMessage = [SELECT Id FROM LogEntry__c WHERE LoggingLevel__c = 'ERROR' AND ApexClassName__c = 'MDMStudentEnrollmentCalloutBatch'];
            System.assert(!logEntriesMessage.isEmpty(), 'MDM Student Enrollment Callout Batch is expected to fail.');
            
        }
    }
}