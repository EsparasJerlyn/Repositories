/**
 * @description Test Class for RelationshipManagerTrigger. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan            | August 01, 2023       | DEPP-6141              | Created file                 |                                                     |
 */
@isTest
public with sharing class RelationshipManagerTriggerHandlerTest {
    @testSetup
    static void setup() {
        TestDataFactoryUser.generateUserIndustryPartnershipManager();
    }

    @isTest
    private static void testPlatformEventInsertAndUpdate() {
        System.runAs(TestDataFactoryUser.selectUserIndustryPartnershipManager) {
            //create account record
            List <Account> accountBusinesOrganization = TestDataFactory.createTestAccountRecordsWithRecordType(
                1,
                AccountsDAO.ACCT_BUSINESS_ORG_ID
            );


            AccountsDAO.newInstance()
                .insertRecords(accountBusinesOrganization, false, AccessLevel.USER_MODE);

            Test.startTest();
            //create relationship manager record
            List<Relationship_Manager__c> newRelationshipManager = TestDataFactory.createRelationshipManagerWithAccountLookup(
                1,
                RelationshipManagersDAO.ACCOUNT_RELATIONSHIP_MANAGER_RECTYPE_ID,
                accountBusinesOrganization[0].Id,
                TestDataFactoryUser.selectUserIndustryPartnershipManager.Id
            );

            System.assert(
                RelationshipManagersDAO.newInstance()
                        .insertRecords(newRelationshipManager, false, AccessLevel.USER_MODE)[0]
                    .isSuccess(),
                'Relationship Manager is not created'
            );

            newRelationshipManager[0].Is_Active__c = false;

            System.assert(
                RelationshipManagersDAO.newInstance()
                        .updateRecords(newRelationshipManager, false, AccessLevel.USER_MODE)[0]
                    .isSuccess(),
                'Relationship Manager is not updated'
            );
            Test.stopTest();
        }
    }
}