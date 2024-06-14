/**
 * @description Test class for NurtureTrackConfigurationsDAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | mark.j.mahilum                 | July 25, 2023         | DEPP-6106              | created file                 |
 */
@isTest
public with sharing class NurtureTrackConfigurationsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }
    
    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            System.assert(
                new NurtureTrackConfigurationsDAO().getSObjectType() == Nurture_Track_Configuration__c.SObjectType,
                'SObject is not Nurture_Track_Configuration__c'
            );
        }
        Test.stopTest();
    }
    
    @isTest
    static void getExistingUnconvertedLeadsByEmailTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Nurture_Track_Configuration__c> nurtureList = NurtureTrackConfigurationsDAO.newInstance().getNurtureTrackLeadScoreThreshold('SYSTEM_MODE');
            System.assert(nurtureList.isEmpty(), 'nurtureList should not be empty');
        }
        Test.stopTest();
    }
    @isTest
    static void getNurtureTrackByCadenceNamesTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Nurture_Track_Configuration__c> nurtureList = NurtureTrackConfigurationsDAO.newInstance()
                .getNurtureTrackByCadenceNames(
                    new Set<String>(),
                    'SYSTEM_MODE'
                );
            System.assert(nurtureList.isEmpty(), 'nurtureList should not be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void getNurtureTrackTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Nurture_Track_Configuration__c> nurtureList = NurtureTrackConfigurationsDAO.newInstance()
            .getNurtureTrack(
                NurtureTrackConfigurationsDAO.NURTURE_FIELDS,
                'SYSTEM_MODE'
            );
            System.assert(nurtureList.isEmpty(), 'nurtureList should not be empty');
        }
        Test.stopTest();
    }
} 