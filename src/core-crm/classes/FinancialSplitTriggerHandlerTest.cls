/**
 * @description Test Class for FinancialSpitTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                 |
 *    |--------------------------------|-----------------------|------------------------|--------------------------------|
 *    | roy.nino.s.regala              | July 06, 2023         | DEPP-5474              | Created file                   |
 */
@isTest
private class FinancialSplitTriggerHandlerTest {
    @testSetup
    static void setup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'Industry_Partnership_Manager' });
        Opportunity_Code_Auto_Number__c opptyCodeAutoNum = OpportunityCodeAutoNumbersDAO.newInstance()
            .getOrganizationalDefaults();
        opptyCodeAutoNum.Commercialisation__c = 1;
        opptyCodeAutoNum.International_Projects_Unit__c = 1;
        opptyCodeAutoNum.Research_Partnership__c = 1;
        OpportunityCodeAutoNumbersDAO.newInstance()
            .upsertRecords(
                new List<Opportunity_Code_Auto_Number__c>{ opptyCodeAutoNum },
                false,
                AccessLevel.USER_MODE
            );
    }

    @isTest
    private static void testPlatformEventInsertAndUpdate() {
        TestDataFactory.generateTestUsers(new List<String>{ 'Industry_Partnership_Manager' });

        List<Account> accountList = TestDataFactory.createTestAccountRecords(1);
        AccountsDAO.newInstance().insertRecords(accountList, false, AccessLevel.USER_MODE);

        System.runAs(testDataFactory.getQUTIEPartnershipManager()) {
            Test.startTest();
            List<Opportunity> ipuOpportunityList = TestDataFactory.createOpportunityRecords(
                1,
                'test',
                'Qualify'
            );
            OpportunitiesDAO.newInstance()
                .insertRecords(ipuOpportunityList, false, AccessLevel.USER_MODE);

            List<Financial_Split__c> financialSplitList = new List<Financial_Split__c>();
            for (Opportunity opp : ipuOpportunityList) {
                List<Financial_Split__c> tempList = TestDataFactory.createTestFinancialSplitRecordsForOpportunity(
                    1,
                    opp.Id,
                    accountList[0].Id
                );
                financialSplitList.addAll(tempList);
            }

            System.assert(
                FinancialSplitsDAO.newInstance()
                        .insertRecords(financialSplitList, false, AccessLevel.USER_MODE)[0]
                    .isSuccess(),
                'financial split is not created'
            );

            financialSplitList[0].IsActive__c = true;

            FinancialSplitsDAO.newInstance()
                .updateRecords(financialSplitList, false, AccessLevel.USER_MODE);

            System.assert(
                FinancialSplitsDAO.newInstance()
                        .updateRecords(financialSplitList, false, AccessLevel.USER_MODE)[0]
                    .isSuccess(),
                'Financial Split is not updated'
            );
            Test.stopTest();
        }
    }
}
