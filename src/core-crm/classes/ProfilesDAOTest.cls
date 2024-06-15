/**
 * @description test class for ProfilesDAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | June 26, 2023         | DEPP-5411              | Created file
 */
@isTest
public with sharing class ProfilesDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

    @isTest
    static void getProfileRecordsBySetIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Profile> profileList = ProfilesDAO.newInstance()
                .getProfileRecordsBySetIds(new Set<Id>());
            System.assert(profileList.isEmpty(), 'profileList is not empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            System.assert(
                new ProfilesDAO().getSObjectType() == Profile.SObjectType,
                'SObject is not Profile'
            );
        }
        Test.stopTest();
    }
}

