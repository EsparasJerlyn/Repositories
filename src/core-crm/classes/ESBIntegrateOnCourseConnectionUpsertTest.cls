/**
 * @description Test class for ESBIntegrateOnCourseConnectionUpsert.cls
 * @see ESBIntegrateOnCourseConnectionUpsert
 * @author Accenture
 * @history
 * | Dev               | JIRA      | Date       | Change Summary
 * | alexander.cadalin | DEPP-4988 | 2023-02-13 | Created file
 * |                   |           |            |               
 */
@isTest private class ESBIntegrateOnCourseConnectionUpsertTest {
    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();
    private static final Id PS_RT_OPE_ID = Schema.SObjectType.Product_Specification__c.getRecordTypeInfosByDeveloperName().get('OPE').getRecordTypeId();
    /**
     * @description Setup
     */
    @testSetup static void setup() {
        // Generate test users.
        Test.startTest();
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        Test.stopTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            Integration_Settings__c integrationSettings = new Integration_Settings__c(
                Allow_ESB_Integration__c = false
            );
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
        }
    }
    
    /**
     * @description Test the creation of a new course enrollment while the integration
     * is disabled. The test should cover very little code while still being able to
     * create a course enrollment record.
     */
    @isTest private static void integOffNewCourseEnr() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            Test.startTest();
            System.assert([SELECT Id FROM hed__Course_Enrollment__c LIMIT 1].size() > 0, 'The course enrollment record was not created.');
            Test.stopTest();
        }
    }
    
    /**
     * @description Test the integration when the ESB Integration Flag custom setting
     * is set to false. The test coverage should cover only very little code, as it
     * should never run any in the first place.
     */
    @isTest private static void integOffUpdateCourseEnr() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            hed__Course_Enrollment__c cenr = [SELECT Id, hed__Contact__c FROM hed__Course_Enrollment__c LIMIT 1];
            Contact cont = new Contact( LastName = 'Updater' );
            Test.startTest();
            insert cont;
            cenr.hed__Contact__c = cont.Id;
            Database.SaveResult sr = Database.update(cenr);
            Test.stopTest();
            System.assert(sr.isSuccess(), 'The course enrollment record was not updated.');
        }
    }
    
    /**
     * @description Test the creation of a new course enrollment while the integration
     * is disabled. The test should cover very little code while still being able to
     * create a course enrollment record.
     */
    @isTest private static void integOnNewCourseEnr() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            Integration_Settings__c integrationSettings = Integration_Settings__c.getOrgDefaults();
            integrationSettings.Allow_ESB_Integration__c = true;
            update integrationSettings;
            Test.startTest();
            Id contId = [SELECT Id FROM Contact LIMIT 1].Id;
            Id coffId = [SELECT Id FROM hed__Course_Offering__c LIMIT 1].Id;
            hed__Course_Enrollment__c cenr = new hed__Course_Enrollment__c(
                hed__Contact__c = contId,
                hed__Course_Offering__c = coffId
            );
            Database.SaveResult sr = Database.insert(cenr);
            Test.stopTest();
            System.assert(sr.isSuccess(), 'The course enrollment record was not created.');
        }
    }
    
    /**
     * @description Test the integration when the ESB Integration Flag custom setting
     * is set to false. The test coverage should cover only very little code, as it
     * should never run any in the first place.
     */
    @isTest private static void integOnUpdateCourseEnr() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            Integration_Settings__c integrationSettings = Integration_Settings__c.getOrgDefaults();
            integrationSettings.Allow_ESB_Integration__c = true;
            update integrationSettings;
            hed__Course_Enrollment__c cenr = [SELECT Id, hed__Contact__c FROM hed__Course_Enrollment__c LIMIT 1];
            Contact cont = new Contact( LastName = 'Updater' );
            Test.startTest();
            insert cont;
            cenr.hed__Contact__c = cont.Id;
            Database.SaveResult sr = Database.update(cenr);
            Test.stopTest();
            System.assert(sr.isSuccess(), 'The course enrollment record was not updated.');
        }
    }
    
    /**
     * @description Used during generation of Leads. Creates a random
     * 8-character number string to represent the Leads' phone numbers
     */
    private static String randomPhoneNumStringGenerator() {
        String s = String.valueOf(Integer.valueOf(Math.random() * Math.pow(10, 8))).leftPad(8, '0');
        return s;
    }
}