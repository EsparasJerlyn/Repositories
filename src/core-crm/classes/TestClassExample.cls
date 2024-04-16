/**
 * @description Test Class Example
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer                      | Date                  | JIRA                   | Change Summary                      |
 *    |--------------------------------|-----------------------|------------------------|-------------------------------------|
 *    | xxxxx                          | August 10, 2023       |DEPP-5760               | Created File                        |
 */
@isTest
public with sharing class TestClassExample {
    @testSetup
    static void testSetup() {
        TestDataFactoryV2.generateUserSysAdminIntegrationUser();
        TestDataFactoryV2.generateUserQUTeXExecutiveDirector();
    }

    @isTest
    static void exmpaleMethodSysAdminIntegrationUser() {
        Test.startTest();
        System.runAs(TestDataFactoryV2.selectUserSysAdminIntegrationUser) {
           // insert method logic here to test 
        }

        list<User> usr = [SELECT Id,FirstName,LastName,UserRoleId FROM User WHERE Email = 'TestSysAdminIntegrationUser@mailinator.com' LIMIT 1];
        system.debug(usr);
        Assert.areEqual(usr.size(), 1, 'SysAdminIntegrationUse was not created');
        Assert.isNotNull(usr[0].UserRoleId, 'Role is null');
        Test.stopTest();
    }

    @isTest
    static void exmpaleMethodQUTeXExecutiveDirector() {
        Test.startTest();
        System.runAs(TestDataFactoryV2.selectUserQUTeXExecutiveDirector) {
           // insert method logic here to test 
        }

        list<User> usr = [SELECT Id FROM User WHERE Email = 'TestQUTeXExecutiveDirector@mailinator.com' LIMIT 1];
        Assert.areEqual(usr.size(), 1, 'QUTeXExecutiveDirector was not created');
        Test.stopTest();
    }

}