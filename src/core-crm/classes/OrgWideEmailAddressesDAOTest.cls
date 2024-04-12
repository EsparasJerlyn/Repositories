/**
 * @description Test Class for OrgWideEmailAddressesDAO
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | August 31, 2023       | DEPP-6138              | Created file                 |
      |                                |                       |                        |                              |
 */
@isTest
public with sharing class OrgWideEmailAddressesDAOTest {
    
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUTeX_Program_Administrator' });
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(OrgWideEmailAddressesDAO.newInstance() != null, 'OrgWideEmailAddressesDAO instance is null');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(
                new OrgWideEmailAddressesDAO().getSObjectType() == OrgWideEmailAddress.SObjectType,
                'SObject is not OrgWideEmailAddress'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getOrgWideEmailAddressByDisplayNameTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<OrgWideEmailAddress> orgwideEmailAdd = new List<OrgWideEmailAddress>();
            orgwideEmailAdd = OrgWideEmailAddressesDAO.newInstance()
                .getOrgWideEmailAddressByDisplayName(
                    new Set<String>(),
                    AccessLevel.USER_MODE
                );
            System.assert(orgwideEmailAdd != null, 'Org Wide Email Add should not be null.');
        }
        Test.stopTest();
    }

    
}