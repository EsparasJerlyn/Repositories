/**
 * @description Test class for CompletedCadencesDAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                                       |
      |--------------------------------|-----------------------|------------------------|----------------------------------------------------------------------|
      | mark.j.mahilum                 | July 25, 2023         | DEPP-6106              | created file                                                         |
      | roy.nino.s.regala              | Aug 9, 2023           | DEPP-5677              | added test method                                                    |
      | mark.j.mahilum                 | Aug 23, 2023          | DEPP-6215              | Updated test method getCompletedCadenceByTargetIdsAndCadenceNameTest |
      | eccarius.munoz                 | April 30, 2024        | DEPP-8041              | added test method for outreach case methods                          |
 */
@isTest
public with sharing class CompletedCadencesDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator', 'QUT_Domestic_Future_Student_Agent' });
    }
    
    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(
                new CompletedCadencesDAO().getSObjectType() == Completed_Cadence__c.SObjectType,
                'SObject is not Completed_Cadence__c'
            );
        }
        Test.stopTest();
    }
    
    @isTest
    static void getCompletedCadenceByContactIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Completed_Cadence__c> completedCadenceList = CompletedCadencesDAO.newInstance()
                .getCompletedCadenceByContactIds(
                    new Set<Id>(),
                    'SYSTEM_MODE'
                );
            System.assert(completedCadenceList.isEmpty(), 'completedCadenceList should not be empty.');
        }
        Test.stopTest();
    }
    
    @isTest
    static void getCompletedCadenceByLeadIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Completed_Cadence__c> completedCadenceList = CompletedCadencesDAO.newInstance()
                .getCompletedCadenceByLeadIds(
                    new Set<Id>(),
                    'SYSTEM_MODE'
                );
            System.assert(completedCadenceList.isEmpty(), 'completedCadenceList should not be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void getCompletedCadenceByTargetIdsAndCadenceNameTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getDomesticFutureStudentAgent()) {
            List<Completed_Cadence__c> completedCadenceList = CompletedCadencesDAO.newInstance()
                .getCompletedCadenceByTargetIdsAndCadenceName(
                    new Set<String>(),
                    new Set<String>(),
                    'SYSTEM_MODE'
                );
            System.assert(completedCadenceList.isEmpty(), 'completedCadenceList should not be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void getCompletedCadenceByTargetIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getDomesticFutureStudentAgent()) {
            List<Completed_Cadence__c> completedCadenceList = CompletedCadencesDAO.newInstance()
                .getCompletedCadenceByTargetIds(
                    new Set<Id>(),
                    new Set<String>(),
                    'SYSTEM_MODE'
                );
            System.assert(completedCadenceList.isEmpty(), 'completedCadenceList should not be empty.');
        }
        Test.stopTest();
    }
    
    @isTest
    static void getWhereClauseByCriteriaTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getDomesticFutureStudentAgent()) {
            String completedCadenceName = 'Domestic Accepted and Admitted';

            CompletedCadencesDAO.Criteria completedCadenceCriteria = new CompletedCadencesDAO.Criteria();
            completedCadenceCriteria.completedCadence = completedCadenceName;
            completedCadenceCriteria.status = CompletedCadencesDAO.SUCCESSFUL_STATUS;

            ContactsDAO.Criteria contactCriteria = new ContactsDAO.Criteria();
            contactCriteria.recordType = ContactsDAO.PERSON_RECORDTYPE;
            contactCriteria.isQUTStudent = true;

            String whereClauseString = CompletedCadencesDAO.newInstance().getWhereClauseByCriteria(completedCadenceCriteria, contactCriteria);
            String expectedWhereClauseString = 'WHERE Cadence_Name__c = \'' + completedCadenceName + '\' AND Completed_Cadence_Status__c = \'' + CompletedCadencesDAO.SUCCESSFUL_STATUS + '\' AND Contact__r.QUT_Student__c = ' + true + ' AND Contact__r.RecordType.DeveloperName = \'' + ContactsDAO.PERSON_RECORDTYPE + '\'';
            System.assertEquals(expectedWhereClauseString, whereClauseString, 'Incorrect Where Clause by criteria.');
        }
        Test.stopTest();
    }

    @isTest
    static void getWhereClauseByCriteriaEmptyTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getDomesticFutureStudentAgent()) {
            String whereClauseString = CompletedCadencesDAO.newInstance().
                getWhereClauseByCriteria(
                    new CompletedCadencesDAO.Criteria(), 
                    new ContactsDAO.Criteria()
                );
            System.assertEquals('', whereClauseString, 'Incorrect Where Clause by criteria.');
        }
        Test.stopTest();
    }

    @isTest
    static void getContactQueryByCriteriaTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getDomesticFutureStudentAgent()) {
            String completedCadenceName = 'Domestic Accepted and Admitted';

            CompletedCadencesDAO.Criteria completedCadenceCriteria = new CompletedCadencesDAO.Criteria();
            completedCadenceCriteria.completedCadence = completedCadenceName;
            completedCadenceCriteria.status = CompletedCadencesDAO.SUCCESSFUL_STATUS;

            ContactsDAO.Criteria contactCriteria = new ContactsDAO.Criteria();
            contactCriteria.recordType = ContactsDAO.PERSON_RECORDTYPE;
            contactCriteria.isQUTStudent = true;
            
            String actualQueryString = CompletedCadencesDAO.newInstance()
                .getContactQueryByCriteria(
                    completedCadenceCriteria,
                    contactCriteria
                );
            
            String expectedQueryString = 'SELECT Contact__c FROM Completed_Cadence__c WHERE Cadence_Name__c = \'' + completedCadenceName + '\' AND Completed_Cadence_Status__c = \'' + CompletedCadencesDAO.SUCCESSFUL_STATUS + '\' AND Contact__r.QUT_Student__c = ' + true + ' AND Contact__r.RecordType.DeveloperName = \'' + ContactsDAO.PERSON_RECORDTYPE + '\'';
            
            System.assertEquals(expectedQueryString, actualQueryString, 'Contact query by criteria should not be null.');
        }
        Test.stopTest();
    }

    @isTest
    static void getQueryByCriteriaTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getDomesticFutureStudentAgent()) {
            String completedCadenceName = 'Domestic Accepted and Admitted';

            CompletedCadencesDAO.Criteria completedCadenceCriteria = new CompletedCadencesDAO.Criteria();
            completedCadenceCriteria.completedCadence = completedCadenceName;
            completedCadenceCriteria.status = CompletedCadencesDAO.SUCCESSFUL_STATUS;

            ContactsDAO.Criteria contactCriteria = new ContactsDAO.Criteria();
            contactCriteria.recordType = ContactsDAO.PERSON_RECORDTYPE;
            contactCriteria.isQUTStudent = true;
            
            String actualQueryString = CompletedCadencesDAO.newInstance()
                .getQueryByCriteria(
                    completedCadenceCriteria,
                    contactCriteria
                );
            String expectedQueryString = 'SELECT Id, Contact__c, Cadence_Name__c, LastModifiedDate FROM Completed_Cadence__c WHERE Cadence_Name__c = \'' + completedCadenceName + '\' AND Completed_Cadence_Status__c = \'' + CompletedCadencesDAO.SUCCESSFUL_STATUS + '\' AND Contact__r.QUT_Student__c = ' + true + ' AND Contact__r.RecordType.DeveloperName = \'' + ContactsDAO.PERSON_RECORDTYPE + '\'';
            
            System.assertEquals(expectedQueryString, actualQueryString, 'Incorrect Where Clause');
        }
        Test.stopTest();
    }

    @isTest
    static void findByCriteriaTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getDomesticFutureStudentAgent()) {
            //Create record

            List<Contact> contactList;
            List<Completed_Cadence__c> completedCadenceListCreated;
    
            contactList = TestDataFactory.createTestContactRecords(1);
            contactList[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            contactList[0].Calculated_Cadence__c = 'test cadence';
            ContactsDAO.newInstance().insertRecords(contactList,true,AccessLevel.USER_MODE);
    
            completedCadenceListCreated = TestDataFactory.createCompletedCadence('Successful',null,new Set<Id>{contactList[0].Id});
            CompletedCadencesDAO.newInstance().insertRecords(completedCadenceListCreated,true,AccessLevel.SYSTEM_MODE);

            CompletedCadencesDAO.Criteria completedCadenceCriteria = new CompletedCadencesDAO.Criteria();
            completedCadenceCriteria.status = CompletedCadencesDAO.SUCCESSFUL_STATUS;

            ContactsDAO.Criteria contactCriteria = new ContactsDAO.Criteria();
            contactCriteria.recordType = ContactsDAO.PERSON_RECORDTYPE;
            contactCriteria.isQUTStudent = true;
    
            List<Completed_Cadence__c> completedCadenceList = CompletedCadencesDAO.newInstance()
                .findByCriteria(
                    completedCadenceCriteria,
                    contactCriteria
                );
        
            System.assertEquals(completedCadenceList.size(), completedCadenceListCreated.size(),  'completedCadenceList should not be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void criteriaIsEmptyTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getDomesticFutureStudentAgent()) {
            CompletedCadencesDAO.Criteria criteria = new CompletedCadencesDAO.Criteria();
            System.assert(criteria.isEmpty(), 'Criteria should be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void criteriaIsNotEmptyTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getDomesticFutureStudentAgent()) {
            String completedCadenceName = 'Domestic Accepted and Admitted';

            CompletedCadencesDAO.Criteria completedCadenceCriteria = new CompletedCadencesDAO.Criteria();
            completedCadenceCriteria.completedCadence = completedCadenceName;
            completedCadenceCriteria.status = CompletedCadencesDAO.SUCCESSFUL_STATUS;
            
            System.assert(!completedCadenceCriteria.isEmpty(), 'Criteria should be not be empty.');
        }
        Test.stopTest();
    }
       
}