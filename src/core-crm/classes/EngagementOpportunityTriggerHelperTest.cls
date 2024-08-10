/**
 * @description Test class for EngagementOpportunityTriggerHelper
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                            |
      |--------------------------------|-----------------------|------------------------|-----------------------------------------------------------|
      | nicole.genon             	   | December 18, 2023     | DEPP-6949              | Created file                                              |
 */
@isTest
public with sharing class EngagementOpportunityTriggerHelperTest {
    public static final String CONTACT_EMAIL = '0testemail@qut.edu.au';
    public static final String CONTACT_PHONE = '61351638';
    
    @testSetup
    static void testSetup() {
        Test.startTest();

        TestDataFactoryUser.generateUserAlumniEngagementManager();

        Test.stopTest();
    }

    @isTest
    private static void createListRecordOnEngagementOpportunityCreationTest() {

        System.runAs(TestDataFactoryUser.selectUserAlumniEngagementManager) {
            Test.startTest();

            List<Engagement_Opportunity__c> engagementOppList = TestDataFactory.createTestEngagementOpportunityRecords(1);

            for(Engagement_Opportunity__c enOpp : engagementOppList){
                enOpp.RecordTypeId = EngagementOpportunitiesDAO.ALUMNI_ENGAGEMENT_RECTYPE_ID;
            }

            EngagementOpportunitiesDAO.newInstance().insertRecords(engagementOppList, false, AccessLevel.USER_MODE);

            Test.stopTest();

            List<List__c> insertedList = ListsDAO.newInstance().getListRecordsByRelatedEngagementOpportunitySetIds(new Set<Id>{engagementOppList.get(0).Id},AccessLevel.SYSTEM_MODE);

            System.assert(insertedList.get(0).Engagement_Opportunity__c == engagementOppList.get(0).Id, 'List Record is not null.');
        }
    }
}