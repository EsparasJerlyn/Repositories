/**
 * @description Test class for SMSTemplatesDAO
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | mark.j.mahilum                 | Oct 25, 2023          | DEPP-6985              | Created file                 |
 */
@isTest
public with sharing class SMSTemplatesDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_System_Administrator' });
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getSystemAdminUser()) {
            System.assert(
                new SMSTemplatesDAO().getSObjectType() == SMS_Template__c.SObjectType,
                'SObject is not SMS_Template__c'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getActiveSMSTemplatesTest() {
        System.runAs(TestDataFactory.getSystemAdminUser()) {
            Test.startTest();
            System.assert(
                SMSTemplatesDAO.newInstance().getActiveSMSTemplates(AccessLevel.SYSTEM_MODE) != null,
                'getActiveSMSTemplates retrieved is not empty'
            );
            Test.stopTest();
        }
    }
    
}