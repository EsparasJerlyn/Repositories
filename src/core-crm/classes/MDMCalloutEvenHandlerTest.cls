/**
 * @description Test Class for MDMCalloutEvenHandler
 * @see MDMCalloutEvenHandler
 * @author Accenture
 *
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | August 13, 2024       | DEPP-10490             | Created file                 |
 */
@isTest
public with sharing class MDMCalloutEvenHandlerTest {

    @testSetup
    static void testSetup() {
        Test.startTest();
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        Test.stopTest();
    }

    @isTest
    static void testHandleForContact() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {

            List<Contact> contacts = TestDataFactory.createTestContactRecords(1);
            insert contacts;

            List<MDM_Callout_Event__e> mdmCalloutEventList = new List<MDM_Callout_Event__e>();
            MDM_Callout_Event__e event = new MDM_Callout_Event__e(
                Contact_Id__c = contacts[0].Id,
                Triggering_Record__c = 'Contact'
            );
            mdmCalloutEventList.add(event);
    
            Test.startTest();
            MDMCalloutEvenHandler eventHandler = new MDMCalloutEvenHandler(mdmCalloutEventList);
            eventHandler.handle();
            Test.stopTest();
    
            String batchName = 'MDMStudentCalloutBatch';
            AsyncApexJob job = AsyncApexJobsDAO.newInstance().findAsyncApexJobByApexName(batchName, AccessLevel.SYSTEM_MODE);
            System.Assert.areEqual(batchName, job.ApexClass.Name, 'MDMStudentCalloutBatch should be executed.');
        }
        
    }

    @isTest
    static void testHandleForCourseConnetion() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            
            String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
            Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();
            Id PS_RT_OPE_ID = Schema.SObjectType.Product_Specification__c.getRecordTypeInfosByDeveloperName().get('OPE').getRecordTypeId();

            // Create an account.
            Account acco = new Account(
                Name = 'Account',
                RecordTypeId = ACCT_UNIV_DEP_ID,
                Organization_Unit_Level__c = '2'
            );
            insert acco;
            // Create contact.
            List<Contact> contacts = TestDataFactory.createTestContactRecords(1);
            insert contacts;

            // Create a product specification.
            Product_Specification__c pros = TestDataFactory.createTestProductSpecsRecords(1, contacts[0].Id)[0];
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
                hed__Contact__c = contacts[0].Id,
                hed__Course_Offering__c = coff.Id
            );
            insert cenr;
    
            Test.startTest();

            List<MDM_Callout_Event__e> mdmCalloutEventList = new List<MDM_Callout_Event__e>();
            MDM_Callout_Event__e event = new MDM_Callout_Event__e(
                Course_Connection_Id__c = cenr.Id,
                Triggering_Record__c = 'hed__Course_Enrollment__c'
            );
            mdmCalloutEventList.add(event);

            MDMCalloutEvenHandler eventHandler = new MDMCalloutEvenHandler(mdmCalloutEventList);
            eventHandler.handle();

            Test.stopTest();
    
            String batchName = 'MDMStudentEnrollmentCalloutBatch';
            AsyncApexJob job = AsyncApexJobsDAO.newInstance().findAsyncApexJobByApexName(batchName, AccessLevel.SYSTEM_MODE);
            System.Assert.areEqual(batchName, job.ApexClass.Name, 'MDMStudentEnrollmentCalloutBatch should be executed.');
        }
        
    }
}