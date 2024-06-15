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
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }
    
    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
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
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
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