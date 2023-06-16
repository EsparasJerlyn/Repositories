/**
 * @description test clas for DAO Class of UserAppInfosDAO Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | June 13, 2023         | DEPP-5391              | Created file
 */
@isTest
private class UserAppInfosDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Sys_Admin' });
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getPortalSysAdminUser()) {
            System.assert(
                UserAppInfosDAO.newInstance() != null,
                'UserAppInfosDAO instance is null'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getPortalSysAdminUser()) {
            System.assert(
                new UserAppInfosDAO().getSObjectType() == UserAppInfo.SObjectType,
                'SObject is not UserAppInfosDAO'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getUserAppInfoRecordByUserIds() {
        Test.startTest();
        System.runAs(TestDataFactory.getPortalSysAdminUser()) {
            List<UserAppInfo> userAppInfoList = UserAppInfosDAO.newInstance()
                .getUserAppInfoRecordByUserIds(new Set<String>{});
            System.assert(userAppInfoList.isEmpty(), 'userAppInfoList is not empty');
        }
        Test.stopTest();
    }
}
