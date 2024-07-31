/**
 * @description test class for DistributionSplitsDAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                               |
      |--------------------------------|-----------------------|------------------------|----------------------------------------------|
      | neil.s.h.lesidan               | April 12, 2024        | DEPP-8392              | Created file                                 |
 */
@isTest
public with sharing class DistributionSplitsDAOTest {

    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserAdvancementManager();
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            System.assert(DistributionSplitsDAO.newInstance() != null, 'DistributionSplitsDAO instance is null');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            System.assert(
                new DistributionSplitsDAO().getSObjectType() == Distribution_Split__c.SObjectType,
                'SObject is not Distribution Split'
            );
        }
        Test.stopTest();
    }


    @isTest
    static void getDistributionSplitByDistributionManagementTest() {
        Test.startTest();

        List<Designation__c> designationRecords = TestDataFactory.createDesignationRecords(1, DesignationsDAO.GIVING_TO_CAUSE_RECTYPE_ID);
        DesignationsDAO.newInstance().insertRecords(designationRecords, false, AccessLevel.USER_MODE);

        List<Distribution_Management__c> distributionManagementRecords = TestDataFactory.createDistributionManagementRecords(1, DistributionManagementsDAO.STATUS_DEFINE);
        distributionManagementRecords[0].Designation__c = designationRecords[0].Id;
        DistributionManagementsDAO.newInstance().insertRecords(distributionManagementRecords, false, AccessLevel.USER_MODE);

        List<Finance_GL_Account__c> financeGLAccountRecords = TestDataFactory.createTestFinanceGLAccountRecords(1, true);
        FinanceGLAccountsDAO.newInstance().insertRecords(financeGLAccountRecords, false, AccessLevel.USER_MODE);

        List<Distribution_Split__c> distributionSplitRecords = TestDataFactory.createTestDistributionSplitRecords(1, distributionManagementRecords[0].Id, financeGLAccountRecords[0].Id);
        DistributionSplitsDAO.newInstance().insertRecords(distributionSplitRecords, false, AccessLevel.USER_MODE);

        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            List<Distribution_Split__c> distributionSplitList = DistributionSplitsDAO.newInstance()
                .getDistributionSplitByDistributionManagement(new Set<Id>{distributionManagementRecords[0].Id}, AccessLevel.USER_MODE);
            System.assert(!distributionSplitList.isEmpty(), 'distributionSplitList is empty');
        }

        Test.stopTest();

    }
}