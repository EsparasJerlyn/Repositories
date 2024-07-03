/**
 * @description test class for ConMatchingServiceConfigurationsDAO.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                | JIRA                   | Change Summary                            |
 *    |--------------------------------|---------------------|------------------------|-------------------------------------------|
 *    | roy.nino.s.regala              | June 5, 2024        | DEPP-9210              | Created file                              |
 */
@isTest
private class ConMatchingServiceConfigurationsDAOTest {
    @testSetup
    static void testSetup() {
        Test.startTest();
        TestDataFactoryUser.generateUserQUTESB();
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            System.assert(
                new ConMatchingServiceConfigurationsDAO().getSObjectType() == Contact_Matching_Service_Configuration__mdt.SObjectType,
                'SObject is not Contact_Matching_Service_Configuration__mdt'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getInstanceByDeveloperNameTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            System.assert(
                ConMatchingServiceConfigurationsDAO.newInstance()
                    .getInstanceByDeveloperName(ConMatchingServiceConfigurationsDAO.STUDENT_SANCTION_BATCH)
                    != null,
                'Contact Matching Service Configuration for Student Sanction should exist'
            );
        }
        Test.stopTest();
    }
}
