/**
 * @description test clas for DAO Class of UserRecordAccessesDAO Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | Aug 25, 2023          | DEPP-6348              | Created file
 */
@isTest
private class UserRecordAccessesDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserSystemAdministrator();
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            System.assert(
                UserRecordAccessesDAO.newInstance() != null,
                'UserRecordAccessesDAO instance is null'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            System.assert(
                new UserRecordAccessesDAO().getSObjectType() == UserRecordAccess.SObjectType,
                'SObject is not UserRecordAccessesDAO'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getUserRecordAccessesBySetRecordIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            List<UserRecordAccess> userRecordAccessList = UserRecordAccessesDAO.newInstance()
                .getUserRecordAccessesBySetRecordIds(new Set<Id>{});
            System.assert(userRecordAccessList.isEmpty(), 'userRecordAccessList is not empty');
        }
        Test.stopTest();
    }
}
