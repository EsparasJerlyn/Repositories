/**
 * @description Test Class for Update_Affiliations_to_former Flow, as this is to test a flow this is integration test instead of unit test.
 * 
 * @see ../flows/Update_Affiliations_to_former
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
 *    |---------------------------|-----------------------|--------------|---------------------------------------------|
 *    | william.a.cheng           | September 14, 2022    | DEPP-1977    | Created file                                | 
 *    |                           |                       |              |                                             | 
*/
@isTest
public with sharing class Update_Affiliations_to_former_FlowTest {

    private static final String AFFILIATION_ROLE_FACULTY = 'Faculty';
    private static final String AFFILIATION_ROLE_EMPLOYEE = 'Employee';

    private static final String AFFILIATION_STATUS_CURRENT = 'Current';
    private static final String AFFILIATION_STATUS_FORMER = 'Former';

    /**
     * @description to setup test data
     */
    @testSetup
    private static void setup() {
        /*
            We use SeeAllData = false in the test class, in the test execution context, there are no affiliation mapping configured.
            We have to insert recors to hed__Affl_Mappings__c and hed__Trigger_Handler__c according to the actual production config in order to do integration test for affiliation related features
        */
        TestDataFactory.configureAffiliationMapping();
        TestDataFactory.configureTDTMForCONPrimaryAfflsTDTM();
        TestDataFactory.generateTestUsers(new List<String>{ 'System_Administrator' });
    }

    /**
     * @description Should update duplicate affiliation to former when creating new affiliation cause duplication
     */
    @isTest
    private static void shouldUpdateStatuswhenCreateAffiliation() {
        System.runAs(TestDataFactory.getSystemAdminUser()){
        // prepare test data
        hed__affiliation__c existingAffiliation = new hed__affiliation__c(hed__status__c = AFFILIATION_STATUS_CURRENT);
        insert existingAffiliation;

        hed__affiliation__c newAffiliation = new hed__affiliation__c();

        // test
        Test.startTest();
        insert newAffiliation;
        Test.stopTest();
        
        // verify
        hed__affiliation__c actualAffiliation = [select id, hed__role__c, hed__status__c, hed__endDate__c from hed__affiliation__c where id = :existingAffiliation.id];
        System.assertEquals(AFFILIATION_STATUS_FORMER, actualAffiliation.hed__status__c, 'Status should be former');
        System.assertEquals(Date.today(), actualAffiliation.hed__endDate__c, 'End date should be today');
        }
    }

    /**
     * @description Should update duplicate affiliation to former when updating new affiliation's contact field cause duplication
     */
    @isTest
    private static void shouldUpdateStatusWhenUpdateContactField() {
        System.runAs(TestDataFactory.getSystemAdminUser()){
        // prepare test data
        Contact c = TestDataFactory.createTestContactRecords(1).get(0);
        insert c;

        hed__affiliation__c uniqueAffiliation1 = new hed__affiliation__c(hed__contact__c = c.id, hed__status__c = AFFILIATION_STATUS_CURRENT);
        insert uniqueAffiliation1;

        hed__affiliation__c uniqueAffiliation2 = new hed__affiliation__c(hed__status__c = AFFILIATION_STATUS_CURRENT);
        insert uniqueAffiliation2;

        
        // Make it duplicate
        uniqueAffiliation2.hed__contact__c = c.id;

        // test
        Test.startTest();
        update uniqueAffiliation2;
        Test.stopTest();
        
        // verify
        hed__affiliation__c actualAffiliation = [select id, hed__status__c, hed__endDate__c from hed__affiliation__c where id = :uniqueAffiliation1.id];
        System.assertEquals(AFFILIATION_STATUS_FORMER, actualAffiliation.hed__status__c, 'Status should be former');
        System.assertEquals(Date.today(), actualAffiliation.hed__endDate__c, 'End date should be today');
        }
    }

    /**
     * @description Should update duplicate affiliation to former when updating new affiliation's account field cause duplication
     */
    @isTest
    private static void shouldUpdateStatusWhenUpdateAccountField() {
        System.runAs(TestDataFactory.getSystemAdminUser()){
        // prepare test data
        Account a = TestDataFactory.createTestAccount(false);
        a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Organization').getRecordTypeId();
        insert a;

        hed__affiliation__c uniqueAffiliation1 = new hed__affiliation__c(hed__account__c = a.id, hed__status__c = AFFILIATION_STATUS_CURRENT);
        insert uniqueAffiliation1;

        hed__affiliation__c uniqueAffiliation2 = new hed__affiliation__c(hed__status__c = AFFILIATION_STATUS_CURRENT);
        insert uniqueAffiliation2;

        
        // Make it duplicate
        uniqueAffiliation2.hed__account__c = a.id;

        // test
        Test.startTest();
        update uniqueAffiliation2;
        Test.stopTest();
        
        // verify
        hed__affiliation__c actualAffiliation = [select id, hed__status__c, hed__endDate__c from hed__affiliation__c where id = :uniqueAffiliation1.id];
        System.assertEquals(AFFILIATION_STATUS_FORMER, actualAffiliation.hed__status__c, 'Status should be former');
        System.assertEquals(Date.today(), actualAffiliation.hed__endDate__c, 'End date should be today');
        }
    }

    /**
     * @description Should update duplicate affiliation to former when updating new affiliation's status field cause duplication
     */
    @isTest
    private static void shouldUpdateStatusWhenUpdateStatusField() {
        System.runAs(TestDataFactory.getSystemAdminUser()){
        // prepare test data
        hed__affiliation__c uniqueAffiliation1 = new hed__affiliation__c(hed__status__c = AFFILIATION_STATUS_CURRENT);
        insert uniqueAffiliation1;

        hed__affiliation__c uniqueAffiliation2 = new hed__affiliation__c(hed__status__c = AFFILIATION_STATUS_FORMER);
        insert uniqueAffiliation2;

        
        // Make it duplicate
        uniqueAffiliation2.hed__status__c = AFFILIATION_STATUS_CURRENT;

        // test
        Test.startTest();
        update uniqueAffiliation2;
        Test.stopTest();
        
        // verify
        hed__affiliation__c actualAffiliation = [select id, hed__status__c, hed__endDate__c from hed__affiliation__c where id = :uniqueAffiliation1.id];
        System.assertEquals(AFFILIATION_STATUS_FORMER, actualAffiliation.hed__status__c, 'Status should be former');
        System.assertEquals(Date.today(), actualAffiliation.hed__endDate__c, 'End date should be today');
        }
    }

    /**
     * @description Should update duplicate affiliation to former when updating new affiliation's role field cause duplication
     */
    @isTest
    private static void shouldUpdateStatusWhenUpdateRoleField() {
        System.runAs(TestDataFactory.getSystemAdminUser()){
        // prepare test data
        hed__affiliation__c uniqueAffiliation1 = new hed__affiliation__c(hed__status__c = AFFILIATION_STATUS_CURRENT, hed__role__c = AFFILIATION_ROLE_EMPLOYEE);
        insert uniqueAffiliation1;

        hed__affiliation__c uniqueAffiliation2 = new hed__affiliation__c(hed__status__c = AFFILIATION_STATUS_CURRENT, hed__role__c = AFFILIATION_ROLE_FACULTY);
        insert uniqueAffiliation2;

        
        // Make it duplicate
        uniqueAffiliation2.hed__role__c = AFFILIATION_ROLE_EMPLOYEE;

        // test
        Test.startTest();
        update uniqueAffiliation2;
        Test.stopTest();
        
        // verify
        hed__affiliation__c actualAffiliation = [select id, hed__status__c, hed__endDate__c from hed__affiliation__c where id = :uniqueAffiliation1.id];
        System.assertEquals(AFFILIATION_STATUS_FORMER, actualAffiliation.hed__status__c, 'Status should be former');
        System.assertEquals(Date.today(), actualAffiliation.hed__endDate__c, 'End date should be today');
        }
    }

    /**
     * @description Should NOT update affiliation to former when updating affiliation's doesn't cause duplication
     */
    @isTest
    private static void shouldNotUpdateStatuswhenNoDuplicate() {
        System.runAs(TestDataFactory.getSystemAdminUser()){
        // prepare test data
        hed__affiliation__c uniqueAffiliation1 = new hed__affiliation__c(hed__status__c = AFFILIATION_STATUS_CURRENT, hed__role__c = AFFILIATION_ROLE_EMPLOYEE);
        insert uniqueAffiliation1;

        hed__affiliation__c uniqueAffiliation2 = new hed__affiliation__c(hed__status__c = AFFILIATION_STATUS_CURRENT, hed__role__c = AFFILIATION_ROLE_FACULTY);
        insert uniqueAffiliation2;

        // test
        Test.startTest();
        update uniqueAffiliation2;
        Test.stopTest();
        
        // verify
        hed__affiliation__c actualAffiliation = [select id, hed__status__c, hed__endDate__c from hed__affiliation__c where id = :uniqueAffiliation1.id];
        System.assertEquals(AFFILIATION_STATUS_CURRENT, actualAffiliation.hed__status__c, 'Status should be current');
        System.assertEquals(null, actualAffiliation.hed__endDate__c, 'End date should be null today');
        }
    }
}
