/**
 * @description test class for ABSCategorisationsDAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | mark.j.mahilum                 | May 29, 2024          | DEPP-8954              | Created file                 |
 */
@isTest
public with sharing class ABSCategorisationsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserQUTESB();
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            System.assert(ABSCategorisationsDAO.newInstance() != null, 'ABSCategorisationsDAO instance is null');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            System.assert(
                new ABSCategorisationsDAO().getSObjectType() == ABS_Categorisation__c.SObjectType,
                'SObject is not ABS_Categorisation__c'
            );
        }
        Test.stopTest();
    }
    
    @isTest
    static void testEmptyLatestActiveABSCategorisation() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            List<ABS_Categorisation__c> absCategorisationList = ABSCategorisationsDAO.newInstance()
                .getLatestUpdatedActiveCategorisationRecord(
                    'USER_MODE'
                );
            System.Assert.areEqual(0, absCategorisationList.size(), 'absCategorisationList is size is not the same');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGetLatestActiveABSCategorisation() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {          
            List<ABS_Categorisation__c> absCategorisation = new List<ABS_Categorisation__c>();
            absCategorisation.add(
                new ABS_Categorisation__c(
                    Name = 'Categorisation 1',
                    Is_Active__c = true,
                    Low_SES_Lower_Boundary__c = 0,
                    Low_SES_Upper_Boundary__c = 80,
                    Remoteness_Inner_Regional__c = true,
                    Remoteness_Outer_Regional__c = true,
                    Remoteness_Remote__c = true,
                    Remoteness_Very_Remote__c = true
                )
            );
            
            ABSCategorisationsDAO.newInstance().insertRecords(absCategorisation, false, AccessLevel.USER_MODE);
            
            List<ABS_Categorisation__c> absCategorisationList = ABSCategorisationsDAO.newInstance()
                .getLatestUpdatedActiveCategorisationRecord(
                    'USER_MODE'
                );
            
            System.Assert.areEqual(1, absCategorisationList.size(), 'absCategorisationList is size is not the same');
            System.Assert.areEqual(true, absCategorisationList[0].Is_Active__c, 'absCategorisationRecord is not Active');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testInActiveABSCategorisation() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {          
            List<ABS_Categorisation__c> absCategorisation = new List<ABS_Categorisation__c>();
            absCategorisation.add(
                new ABS_Categorisation__c(
                    Name = 'Categorisation 1',
                    Is_Active__c = false,
                    Low_SES_Lower_Boundary__c = 0,
                    Low_SES_Upper_Boundary__c = 80,
                    Remoteness_Inner_Regional__c = true,
                    Remoteness_Outer_Regional__c = true,
                    Remoteness_Remote__c = true,
                    Remoteness_Very_Remote__c = true
                )
            );
            
            ABSCategorisationsDAO.newInstance().insertRecords(absCategorisation, false, AccessLevel.USER_MODE);
            
            List<ABS_Categorisation__c> absCategorisationList = ABSCategorisationsDAO.newInstance()
                .getLatestUpdatedActiveCategorisationRecord(
                    'USER_MODE'
                );
            
            System.Assert.areEqual(0, absCategorisationList.size(), 'absCategorisationList is size is not the same');
        }
        Test.stopTest();
    }
}