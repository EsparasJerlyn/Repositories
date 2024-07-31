/**
 * @description Test class for ListsCtrl
 * @see ../classes/ListsCtrl
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                  |
 *    |--------------------------------|-----------------------|------------------------|---------------------------------|
 *    | ryan.j.a.dela.cruz             | February 2, 2024      | DEPP-6950              | Created file                    |
 *    |                                |                       |                        |                                 |
 */
@isTest
public with sharing class ListsCtrlTest {
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserAlumniEngagementManager();
    }

    @isTest
    static void testListRecordIdByEngagementOpportunityId_NullEngagementOpportunityId() {
        System.runAs(TestDataFactoryUser.selectUserAlumniEngagementManager) {
            Test.startTest();
            // Test case 1: When engagementOpportunityIdString is null
            System.assertEquals(
                null,
                ListsCtrl.findListRecordIdByEngagementOpportunityId(null),
                'Expected null when engagementOpportunityIdString is null'
            );
            Test.stopTest();
        }
    }

    @isTest
    static void testListRecordIdByEngagementOpportunityId_EmptyEngagementOpportunityId() {
        System.runAs(TestDataFactoryUser.selectUserAlumniEngagementManager) {
            Test.startTest();
            // Test case 2: When engagementOpportunityIdString is empty
            System.assertEquals(
                null,
                ListsCtrl.findListRecordIdByEngagementOpportunityId(''),
                'Expected null when engagementOpportunityIdString is empty'
            );
            Test.stopTest();
        }
    }

    @isTest
    static void testListRecordIdByEngagementOpportunityId_ValidWithRelatedRecord() {
        System.runAs(TestDataFactoryUser.selectUserAlumniEngagementManager) {
            Test.startTest();
            // Test case 3: When engagementOpportunityIdString is valid with related list record exists
            List<Engagement_Opportunity__c> engagementOppList = TestDataFactory.createTestEngagementOpportunityRecords(
                1
            );

            for (Engagement_Opportunity__c enOpp : engagementOppList) {
                enOpp.RecordTypeId = EngagementOpportunitiesDAO.ALUMNI_ENGAGEMENT_RECTYPE_ID;
            }

            EngagementOpportunitiesDAO.newInstance()
                .insertRecords(engagementOppList, false, AccessLevel.USER_MODE);

            String engagementOpportunityId = engagementOppList.get(0).Id;

            List<List__c> insertedList = ListsDAO.newInstance()
                .getListRecordsByRelatedEngagementOpportunitySetIds(
                    new Set<Id>{ engagementOppList.get(0).Id },
                    AccessLevel.USER_MODE
                );

            System.assertEquals(
                insertedList.get(0).Id,
                ListsCtrl.findListRecordIdByEngagementOpportunityId(engagementOppList.get(0).Id),
                'Expected list record Id when related record exists'
            );
            Test.stopTest();
        }
    }
}
