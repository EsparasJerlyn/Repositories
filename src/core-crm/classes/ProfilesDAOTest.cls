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
        TestDataFactory.generateTestUsers(new List<String>{ 'QUTeX_Program_Administrator' });
    }

    @isTest
    static void getProfileRecordsBySetIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Profile> profileList = ProfilesDAO.newInstance()
                .getProfileRecordsBySetIds(new Set<Id>());
            System.assert(profileList.isEmpty(), 'profileList is not empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(
                new ProfilesDAO().getSObjectType() == Profile.SObjectType,
                'SObject is not Profile'
            );
        }
        Test.stopTest();
    }
}

