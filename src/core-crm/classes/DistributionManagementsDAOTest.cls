/**
 * @description test class for DistributionManagementsDAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                               |
      |--------------------------------|-----------------------|------------------------|----------------------------------------------|
      | kenneth.f.alsay                | April 8, 2024         | DEPP-8399              | Created file                                 |
 */
@isTest
public with sharing class DistributionManagementsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{'QUT_Advancement_Manager'});
    }
    
    @isTest
    static void getDistributionManagementByDesignationIdTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getAdvancementManager()) {
            System.assert(
                DistributionManagementsDAO.newInstance()
                    .getDistributionManagementByDesignationId(
                        new Set<Id>(),
                        AccessLevel.USER_MODE)
                    .isEmpty(),
                'Distribution Management retrieved is not empty'
            );
        }
        Test.stopTest();
    }
    
    @isTest
    static void getDistributionManagementByDesignationIdNotEmptyTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getAdvancementManager()) {
            MockIdGenerator builderForDistributionManagement = new MockIdGenerator(Distribution_Management__c.sObjectType);
            System.assert(
                DistributionManagementsDAO.newInstance()
                    .getDistributionManagementByDesignationId(
                        new Set<Id>{builderForDistributionManagement.getMockId()},
                        AccessLevel.SYSTEM_MODE)
                    .isEmpty(),
                'Distribution Management retrieved is not empty'
            );
        }
        Test.stopTest();
    }
}