
/**
 * @description Test class for UsersDAO
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | September 4, 2023     | DEPP-6138              | Created file                 |
      |                                |                       |                        |                              |
 */
@isTest
public with sharing class UsersDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator' });
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(
                new UsersDAO().getSObjectType() == User.SObjectType,
                'SObject is not User'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getUsersByNameSetTest() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
            System.assert(
                UsersDAO.newInstance().getUsersByNameSet(new Set<String>{Userinfo.getUserName()}, AccessLevel.USER_MODE) != null,
                'Users retrieved is null'
            );
            Test.stopTest();
        }
    }
}