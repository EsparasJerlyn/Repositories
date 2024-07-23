/**
 * @description test class for DesignationFinancialsCtrl.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                | JIRA                   | Change Summary                                      |
 *    |--------------------------------|---------------------|------------------------|-----------------------------------------------------|
 *    | neil.s.h.lesidan               | April 11, 2024      | DEPP-8392              | Created file                                        |
 */
@isTest
private class DesignationFinancialsCtrlTest {

    @isTest
    private static void getDistributionManagementListTest(){
        ImplementationSelector.DAO.setMock(new DesignationsDAOMock());
        ImplementationSelector.DAO.setMock(new DistributionManagementsDAOMock());

        List<Designation__c> designationRecords = TestDataFactory.createDesignationRecords(1, DesignationsDAO.GIVING_TO_CAUSE_RECTYPE_ID);
        DesignationsDAO.newInstance().insertRecords(designationRecords, false, AccessLevel.USER_MODE);

        List<Distribution_Management__c> distributionManagementRecords = TestDataFactory.createDistributionManagementRecords(1, DistributionManagementsDAO.STATUS_DEFINE);
        distributionManagementRecords[0].Designation__c = designationRecords[0].Id;
        DistributionManagementsDAO.newInstance().insertRecords(distributionManagementRecords, false, AccessLevel.USER_MODE);

        Test.startTest();
            List<Distribution_Management__c> destributionManagementList = DesignationFinancialsCtrl.getDistributionManagementList(designationRecords[0].Id);
            System.assert(!destributionManagementList.isEmpty(), 'No Destribution Management record found');
        Test.stopTest();
    }

    @isTest
    private static void getDistributionSplitListTest(){
        ImplementationSelector.DAO.setMock(new DesignationsDAOMock());
        ImplementationSelector.DAO.setMock(new DistributionManagementsDAOMock());
        ImplementationSelector.DAO.setMock(new FinanceGLAccountsDAOMock());
        ImplementationSelector.DAO.setMock(new DistributionSplitsDAOMock());

        List<Designation__c> designationRecords = TestDataFactory.createDesignationRecords(1, DesignationsDAO.GIVING_TO_CAUSE_RECTYPE_ID);
        DesignationsDAO.newInstance().insertRecords(designationRecords, false, AccessLevel.USER_MODE);

        List<Distribution_Management__c> distributionManagementRecords = TestDataFactory.createDistributionManagementRecords(1, DistributionManagementsDAO.STATUS_DEFINE);
        distributionManagementRecords[0].Designation__c = designationRecords[0].Id;
        DistributionManagementsDAO.newInstance().insertRecords(distributionManagementRecords, false, AccessLevel.USER_MODE);

        List<Finance_GL_Account__c> financeGLAccountRecords = TestDataFactory.createTestFinanceGLAccountRecords(1, true);
        FinanceGLAccountsDAO.newInstance().insertRecords(financeGLAccountRecords, false, AccessLevel.USER_MODE);

        List<Distribution_Split__c> distributionSplitRecords = TestDataFactory.createTestDistributionSplitRecords(1, distributionManagementRecords[0].Id, financeGLAccountRecords[0].Id);
        DistributionSplitsDAO.newInstance().insertRecords(distributionSplitRecords, false, AccessLevel.USER_MODE);

        Test.startTest();
            List<Distribution_Split__c> distributionSplitList = DesignationFinancialsCtrl.getDistributionSplitList(distributionManagementRecords);

            System.assert(!distributionSplitList.isEmpty(), 'No Distribution Split record found');
        Test.stopTest();
    }
}