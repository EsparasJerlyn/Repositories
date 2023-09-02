/**
 * @description Service Class for Publishing DynamicDatatableEvent
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
private class DynamicDatatableEventServiceTest {

    @isTest
    private static void publishPlatformEvent() {
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

        Engagement_Code_Auto_Number__c engCodeAutoNum = EngagementCodeAutoNumbersDAO.newInstance()
            .getOrganizationalDefaults();
        engCodeAutoNum.Commercialisation__c = 1;
        engCodeAutoNum.Research_Partnership__c = 1;
        EngagementCodeAutoNumbersDAO.newInstance()
            .upsertRecords(
                new List<Engagement_Code_Auto_Number__c>{ engCodeAutoNum },
                false,
                AccessLevel.USER_MODE
            );

        System.runAs(testDataFactory.getQUTIEPartnershipManager()) {
            List<Engagement__c> engagementList = TestDataFactory.createTestEngagementRecords(
                1,
                'RCE',
                EngagementsDAO.COMMERCIALISATION_RECTYPE_ID
            );
            EngagementsDAO.newInstance()
                .insertRecords(engagementList, false, AccessLevel.USER_MODE);

            Test.startTest();
            List<Opportunity> ipuOpportunityList = TestDataFactory.createOpportunityRecords(
                1,
                'test',
                'Qualify'
            );
            ipuOpportunityList[0].Engagement__c = engagementList[0].Id;
            System.assert(
                OpportunitiesDAO.newInstance()
                        .insertRecords(ipuOpportunityList, false, AccessLevel.USER_MODE)[0]
                    .isSuccess(),
                'Opportunity is not created'
            );
            Test.stopTest();
        }
    }
}
