/**
 * @description Test Class for Populate_affiliation_role Flow, as this is to test a flow this is integration test instead of unit test.
 * 
 * @see ../flows/Populate_affiliation_role
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
public with sharing class Populate_affiliation_role_FlowTest {

    private static final String ACCOUNT_RECORD_TYPE_DEVELOPER_NAME_UNIVERSITY_DEPARTMENT = 'University_Department';
    private static final String ACCOUNT_RECORD_TYPE_DEVELOPER_NAME_BUSINESS_ORGANIZATION = 'Business_Organization';
    private static final String ACCOUNT_RECORD_TYPE_DEVELOPER_NAME_ADMINISTRATIVE = 'Administrative';

    private static final Id ACCOUNT_RECORD_TYPE_ID_UNIVERSITY_DEPARTMENT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCOUNT_RECORD_TYPE_DEVELOPER_NAME_UNIVERSITY_DEPARTMENT).getRecordTypeId();
    private static final Id ACCOUNT_RECORD_TYPE_ID_BUSINESS_ORGANIZATION = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCOUNT_RECORD_TYPE_DEVELOPER_NAME_BUSINESS_ORGANIZATION).getRecordTypeId();
    private static final Id ACCOUNT_RECORD_TYPE_ID_ADMINISTRATIVE = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCOUNT_RECORD_TYPE_DEVELOPER_NAME_ADMINISTRATIVE).getRecordTypeId();

    private static final String AFFILIATION_ROLE_FACULTY = 'Faculty';
    private static final String AFFILIATION_ROLE_EMPLOYEE = 'Employee';

    private static final String AFFILIATION_STATUS_CURRENT = 'Current';
    private static final String AFFILIATION_STATUS_FORMER = 'Former';

    private static Account universityDepartment;
    private static Account businessOrganization;

    private static Account anotherUniversityDepartment;
    private static Account anotherBusinessOrganization;

    private static Account administrativeAccount;

    /**
     * @description to setup test data
     */
    @testSetup
    private static void setup() {
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        // Configuration setup
        TestDataFactory.loadEDATriggers();
        TestDataFactory.configureAffiliationMapping();

        // prepare test data
        List<Account> accounts = TestDataFactory.createTestAccountRecords(5);
        accounts.get(0).RecordTypeId = ACCOUNT_RECORD_TYPE_ID_UNIVERSITY_DEPARTMENT;
        accounts.get(1).RecordTypeId = ACCOUNT_RECORD_TYPE_ID_BUSINESS_ORGANIZATION;
        accounts.get(2).RecordTypeId = ACCOUNT_RECORD_TYPE_ID_UNIVERSITY_DEPARTMENT;
        accounts.get(3).RecordTypeId = ACCOUNT_RECORD_TYPE_ID_BUSINESS_ORGANIZATION;
        accounts.get(4).RecordTypeId = ACCOUNT_RECORD_TYPE_ID_ADMINISTRATIVE;

        insert accounts;

    }

    /**
     * @description Retrieve accounts records created in @testSetup method
     */
    private static void retrieveAccounts() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            // Select accounts records
            List<Account> accounts = [Select id, RecordType.DeveloperName from Account where RecordTypeId in (:ACCOUNT_RECORD_TYPE_ID_UNIVERSITY_DEPARTMENT, :ACCOUNT_RECORD_TYPE_ID_BUSINESS_ORGANIZATION, :ACCOUNT_RECORD_TYPE_ID_ADMINISTRATIVE)];
            
            List<Account> universityDepartments = new List<Account>();
            List<Account> businessOrganizations = new List<Account>();

            // group account records by record type
            for (Account a : accounts) {
                if (a.RecordType.DeveloperName == ACCOUNT_RECORD_TYPE_DEVELOPER_NAME_UNIVERSITY_DEPARTMENT) {
                    universityDepartments.add(a);
                } else if (a.RecordType.DeveloperName == ACCOUNT_RECORD_TYPE_DEVELOPER_NAME_BUSINESS_ORGANIZATION) {
                    businessOrganizations.add(a);
                } else if (a.RecordType.DeveloperName == ACCOUNT_RECORD_TYPE_DEVELOPER_NAME_ADMINISTRATIVE) {
                    administrativeAccount = a;
                }
            }
            
            // Set static variable to account records;
            universityDepartment = universityDepartments.get(0);
            anotherUniversityDepartment = universityDepartments.get(1);

            businessOrganization = businessOrganizations.get(0);
            anotherBusinessOrganization = businessOrganizations.get(1);
        }
    }

    /**
     * @description Should populate role when user create contact record with non null primary business organization / primary department
     */
    @isTest
    private static void shouldPopulateRoleWhenInsertContact() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            // prepare test data
            retrieveAccounts();

            Contact c = TestDataFactory.createTestContactRecords(1).get(0);
            c.Primary_Department__c = universityDepartment.id;
            c.hed__Primary_Organization__c = businessOrganization.id;

            // test
            Test.startTest();
            insert c;
            Test.stopTest();
            
            // verify
            hed__affiliation__c affiliation = [select id, hed__role__c, hed__status__c from hed__affiliation__c where hed__contact__c = :c.id and hed__account__c = :universityDepartment.id limit 1];
            System.assertNotEquals(null, affiliation, 'Affiliation should be created'); // Affiliation record created by eduation cloud instead of the flow 
            System.assertEquals(AFFILIATION_ROLE_FACULTY, affiliation.hed__role__c, 'Role should be Faculty'); // The flow populated the role
            
            affiliation = [select id, hed__role__c, hed__status__c from hed__affiliation__c where hed__contact__c = :c.id and hed__account__c = :businessOrganization.id];
            System.assertNotEquals(null, affiliation, 'Affiliation should be created'); // Affiliation record created by eduation cloud instead of the flow
            System.assertEquals(AFFILIATION_ROLE_EMPLOYEE, affiliation.hed__role__c, 'Role should be Employee'); // The flow populated the role
        }
    }

    /**
     * @description Should populate role when user update contact record with non null primary business organization / primary department
     */
    @isTest
    private static void shouldPopulateRoleWhenUpdateContact() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            // prepare test data
            retrieveAccounts();

            Contact c = new Contact(lastname = 'L');
            insert c;

            // test
            Test.startTest();
            c.Primary_Department__c = universityDepartment.id;
            c.hed__Primary_Organization__c = businessOrganization.id;
            update c;
            Test.stopTest();
            
            // verify
            hed__affiliation__c affiliation = [select id, hed__role__c, hed__status__c from hed__affiliation__c where hed__contact__c = :c.id and hed__account__c = :universityDepartment.id limit 1];
            System.assertNotEquals(null, affiliation, 'Affiliation should be created'); // Affiliation record created by eduation cloud instead of the flow 
            System.assertEquals(AFFILIATION_ROLE_FACULTY, affiliation.hed__role__c, 'Role should be faculty'); // The flow populated the role

            affiliation = [select id, hed__role__c, hed__status__c from hed__affiliation__c where hed__contact__c = :c.id and hed__account__c = :businessOrganization.id];
            System.assertNotEquals(null, affiliation, 'Affiliation should be created'); // Affiliation record created by eduation cloud instead of the flow 
            System.assertEquals(AFFILIATION_ROLE_EMPLOYEE, affiliation.hed__role__c, 'Role should be employee'); // The flow populated the role
        }
    }
}