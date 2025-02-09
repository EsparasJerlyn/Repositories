/**
 * @description test class for ConsultanciesDAO
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 25, 2023        | DEPP-5567              | Created file
 */
@isTest
public with sharing class ConsultanciesDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

    @isTest
    static void getConsultanciesWithActionsBySetProductRequestIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Consultancy__c> consultanciesList = ConsultanciesDAO.newInstance()
                .getConsultanciesWithActionsBySetProductRequestIds(new Set<Id>());
            System.assert(consultanciesList.isEmpty(), 'consultanciesList is not empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getConsultanciesBySetNamesTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Consultancy__c> consultanciesList = ConsultanciesDAO.newInstance()
                .getConsultanciesBySetNames(new Set<String>());
            System.assert(consultanciesList.isEmpty(), 'consultanciesList is not empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            System.assert(
                new ConsultanciesDAO().getSObjectType() == Consultancy__c.SObjectType,
                'SObject is not Consultancy__c'
            );
        }
        Test.stopTest();
    }
}
