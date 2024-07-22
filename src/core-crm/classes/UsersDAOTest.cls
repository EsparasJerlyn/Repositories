
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
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            System.assert(
                new UsersDAO().getSObjectType() == User.SObjectType,
                'SObject is not User'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getUsersByNameSetTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            Test.startTest();
            System.assert(
                UsersDAO.newInstance().getUsersByNameSet(new Set<String>{Userinfo.getUserName()}, AccessLevel.USER_MODE) != null,
                'Users retrieved is null'
            );
            Test.stopTest();
        }
    }

    @isTest
    static void getUsersByIdTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            Test.startTest();
            System.assert(
                UsersDAO.newInstance().getUsersById(new Set<Id>(), AccessLevel.USER_MODE).isEmpty(),
                'Users retrieved is null'
            );
            Test.stopTest();
        }
    }

    @isTest
    static void getUsersByIdNotEmptyTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            Test.startTest();
            MockIdGenerator builderForUser = new MockIdGenerator(User.sObjectType);
            System.assert(
                UsersDAO.newInstance().getUsersById(new Set<Id>{builderForUser.getMockId()}, AccessLevel.USER_MODE).isEmpty(),
                'Users retrieved is null'
            );
            Test.stopTest();
        }
    }
}