/**
 * @description Test class for ESBIntegrateOnCourseConnectionUpsert.cls
 * @see ESBIntegrateOnCourseConnectionUpsert
 * @author Accenture
 * @history
 * | Dev               | JIRA      | Date       | Change Summary
 * | alexander.cadalin | DEPP-4988 | 2023-02-13 | Created file
 * | eccarius.munoz    | DEPP-10490| 2024-08-13 | Updated methods for the platform event
 * |                   |           |            |               
 */
@isTest 
private class ESBIntegrateOnCourseConnectionUpsertTest {
    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();
    private static final Id PS_RT_OPE_ID = Schema.SObjectType.Product_Specification__c.getRecordTypeInfosByDeveloperName().get('OPE').getRecordTypeId();
    /**
     * @description Setup
     */

    @testSetup 
    static void setup() {
        // Generate test users.
        Test.startTest();

        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        TestDataFactoryUser.generateUserSystemAdministrator();

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
    private static void calloutToMDMAsNonESBUserTest(){        
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Test.startTest();
            
            hed__Course_Enrollment__c cenr = [SELECT Id, Enrollment_Status__c FROM hed__Course_Enrollment__c LIMIT 1];
            cenr.Enrollment_Status__c = 'Admitted';
            update cenr;

            List<EventBusSubscriber> eventBusSubscriberList = [SELECT Position, Status FROM EventBusSubscriber WHERE Topic = 'MDM_Callout_Event__e' AND Type = 'ApexTrigger'];
            for(EventBusSubscriber eventBusSubscriber : eventBusSubscriberList){
                System.Assert.isTrue(eventBusSubscriber.Position > 0 && eventBusSubscriber.Status == 'Running', 'Student enrollments should be processed and handled by the event.');
            }

            Test.stopTest();
            
        }
    }

    @isTest
    private static void calloutToMDMAsESBUserTest(){       
        User esbIntegrationUser;
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator){
            Profile profile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
            esbIntegrationUser = new User(
                Username = 'testesbuser@test.com', 
                Email = 'testesbuser@test.com', 
                Alias = 'esbus', 
                ProfileId = profile.Id,
                TimeZoneSidKey = 'America/Los_Angeles', 
                LocaleSidKey = 'en_US', 
                EmailEncodingKey = 'UTF-8', 
                LanguageLocaleKey = 'en_US',
                FirstName = 'ESB',
                LastName = 'Integration User'
            );
            insert esbIntegrationUser;
        }

        System.runAs(esbIntegrationUser){
            Test.startTest();

            hed__Course_Enrollment__c cenr = [SELECT Id, Enrollment_Status__c FROM hed__Course_Enrollment__c LIMIT 1];
            cenr.Enrollment_Status__c = 'Admitted';
            update cenr;

            List<EventBusSubscriber> eventBusSubscriberList = [SELECT Position, Status FROM EventBusSubscriber WHERE Topic = 'MDM_Callout_Event__e' AND Type = 'ApexTrigger'];
            for(EventBusSubscriber eventBusSubscriber : eventBusSubscriberList){
                System.Assert.isTrue(eventBusSubscriber.Position == 0 && eventBusSubscriber.Status == 'Running', 'Student enrollments should not be processed and handled by the event.');
            }
            
            Test.stopTest();
        }
    }
    
}