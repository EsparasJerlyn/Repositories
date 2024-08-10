/* @description DAO Test Class for Marketing Segmentation 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                     |
      |--------------------------------|-----------------------|------------------------|----------------------------------------------------|
      | julie.jane.alegre              | Sept 14, 2023         | DEPP-6679              | Created file                                       |
      | johanna.a.gibas                | Jan 04, 2024          | ApexCRUDViolationFix   | Added method for getExistingMarketingSegmentations |
 */
@isTest
public with sharing class MarketingSegmentationsDAOTest {

    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            System.assert(MarketingSegmentationsDAO.newInstance() != null, 'MarketingSegmentationsDAO instance is null');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            System.assert(
                new MarketingSegmentationsDAO().getSObjectType() == Marketing_Segmentation__c.SObjectType,
                'SObject is not Marketing_Segmentation__c'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getMarketingSegmentationByContactIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Marketing_Segmentation__c> marketingSegmentationList = MarketingSegmentationsDAO.newInstance()
                .getMarketingSegmentationByContactIds(
                    new Set<Id>(),
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(marketingSegmentationList.isEmpty(), 'marketingSegmentationList should be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void getMarketingSegmentationByContactIdsNotEmptyTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            MockIdGenerator mockContact = new MockIdGenerator(Contact.SObjectType);
            List<Marketing_Segmentation__c> marketingSegmentationList = MarketingSegmentationsDAO.newInstance()
                .getMarketingSegmentationByContactIds(
                    new Set<Id>{mockContact.getMockId()},
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(marketingSegmentationList.isEmpty(), 'marketingSegmentationList should be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void getMarketingSegmentationByLeadIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Marketing_Segmentation__c> marketingSegmentationList = MarketingSegmentationsDAO.newInstance()
                .getMarketingSegmentationByLeadIds(
                    new Set<Id>(),
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(marketingSegmentationList.isEmpty(), 'marketingSegmentationList should be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void getMarketingSegmentationByContactOrLeadTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Marketing_Segmentation__c> marketingSegmentationList = MarketingSegmentationsDAO.newInstance()
                .getMarketingSegmentationByContactOrLead(
                    new Set<Id>(),
                    new Set<Id>(),
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(marketingSegmentationList.isEmpty(), 'marketingSegmentationList should be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void queryLocatorGetMarketingSegmentationsByContactOrLeadIdsTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            Test.startTest();
            System.assert(
                MarketingSegmentationsDAO.newInstance().queryLocatorGetMarketingSegmentationsByContactOrLeadIds(
                    new Set<Id>()
                ) != null,
                'marketingSegmentationList should not be empty.'
            );
            Test.stopTest();
        }
    }

    @isTest
    static void getExistingMarketingSegmentationsTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            System.assert(
                MarketingSegmentationsDAO.newInstance()
                    .getExistingMarketingSegmentations(
                        new Map<String, Contact>(),
                        AccessLevel.SYSTEM_MODE)
                    .isEmpty(),
                'Marketing segmentation retrieved is not empty'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getExistingMarketingSegmentationsNotEmptyTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Contact> contactList = TestDataFactory.createTestContactRecords(0,1);
            ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.SYSTEM_MODE);
            System.assert(
                !MarketingSegmentationsDAO.newInstance()
                    .getExistingMarketingSegmentations(
                        new Map<String, Contact>{contactList[0].Email => contactList[0]},
                        AccessLevel.SYSTEM_MODE)
                    .isEmpty(),
                'Marketing segmentation retrieved must not be empty'
            );
        }
        Test.stopTest();
    }
    
    @isTest
    static void getLinkedMarketingSegByContactOrLeadIdsTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            Test.startTest();
            MockIdGenerator mockContact = new MockIdGenerator(Contact.SObjectType);
            MockIdGenerator mockLead = new MockIdGenerator(Lead.SObjectType);
            List<Marketing_Segmentation__c> msList = MarketingSegmentationsDAO.newInstance()
                .getLinkedMarketingSegByContactOrLeadIds(
                    new Set<Id>{
                        mockContact.getMockId(),
                        mockLead.getMockId()
                    },
                    AccessLevel.USER_MODE
                );
            System.assert(msList.isEmpty(), 'marketingSegmentationList should be empty.');
        }
    }

    @isTest
    static void getLinkedMarketingSegByContactOrLeadIdsEmptyTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            Test.startTest();
            List<Marketing_Segmentation__c> msList = MarketingSegmentationsDAO.newInstance()
                .getLinkedMarketingSegByContactOrLeadIds(
                    new Set<Id>(),
                    AccessLevel.USER_MODE
                );
            System.assert(msList.isEmpty(), 'marketingSegmentationList should be empty.');
        }
    }
}
