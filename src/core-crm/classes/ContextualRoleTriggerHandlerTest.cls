/**
 * @description Test Class for ContextualRoleTriggerHandler
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
private class ContextualRoleTriggerHandlerTest {
    @testSetup
    static void setup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_IE_Partnership_Manager' });
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

            List<Contextual_Role__c> partnerContextualRolesList = new List<Contextual_Role__c>();
            for (Opportunity opp : ipuOpportunityList) {
                partnerContextualRolesList.addAll(
                    TestDataFactory.createContextualRolesForOpportunity(
                        1,
                        ContextualRolesDAO.OPPORTUNITY_ROLE_RECTYPE_ID,
                        opp.Id,
                        accountList[0].Id,
                        'Partners'
                    )
                );
            }

            System.assert(
                ContextualRolesDAO.newInstance()
                        .insertRecords(partnerContextualRolesList, false, AccessLevel.USER_MODE)[0]
                    .isSuccess(),
                'contextual role is not created'
            );

            partnerContextualRolesList[0].Contextual_Role__c = 'Partner Contact';

            System.assert(
                ContextualRolesDAO.newInstance()
                        .updateRecords(partnerContextualRolesList, false, AccessLevel.USER_MODE)[0]
                    .isSuccess(),
                'contextual role is not updated'
            );
            Test.stopTest();
        }
    }
}
