/**
 * @description Test Class for EmailTemplatesDAO
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
 *    |--------------------------------|-----------------------|------------------------|------------------------------|
 *    | eccarius.munoz                 | August 31, 2023       | DEPP-6138              | Created file                 |
 *    |                                |                       |                        |                              |
 */
@isTest
public with sharing class EmailTemplatesDAOTest {
    
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            System.assert(EmailTemplatesDAO.newInstance() != null, 'EmailTemplatesDAO instance is null');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            System.assert(
                new EmailTemplatesDAO().getSObjectType() == EmailTemplate.SObjectType,
                'SObject is not EmailTemplate'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getEmailTemplatesByNameSetTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<EmailTemplate> emailTempList = EmailTemplatesDAO.newInstance()
                .getEmailTemplatesByNameSet(
                    new Set<String>(),
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(emailTempList.isEmpty(), 'emailTempList should not be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void getEmailTemplatesByDeveloperNameSetTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<EmailTemplate> emailTempList = EmailTemplatesDAO.newInstance()
                .getEmailTemplatesByDeveloperNameSet(
                    new Set<String>(),
                    'USER_MODE'
                );
            System.assert(emailTempList.isEmpty(), 'emailTempList should not be empty.');
        }
        Test.stopTest();
    }

}