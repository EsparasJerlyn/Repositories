/**
 * @description Test Class AffiliationsDAO
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                             |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------|
      | mark.j.mahilum                 | July 21, 2023         | DEPP-5799              | Created File                               |
 */
@isTest
public with sharing class AffiliationsDAOTest {
    
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUTeX_Program_Administrator' });
    }
    
    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(
                new AffiliationsDAO().getSObjectType() == hed__Affiliation__c.SObjectType,
                'SObject is not hed__Affiliation__c'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getAffiliationByContactIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<hed__Affiliation__c> affiliationsList = AffiliationsDAO.newInstance()
                .getAffiliationByContactIds(
                    new Set<Id>(),
                    '',
                    'SYSTEM_MODE'
                );
            System.assert(affiliationsList.isEmpty(), 'affiliationsList should not be empty.');
        }
        Test.stopTest();
    }
}