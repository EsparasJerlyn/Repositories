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
      | julie.jane.alegre              | May 06, 2024          | DEPP-8490              | Add access level on findByCriteria method                        |

 */
@isTest
public with sharing class CompletedCadencesDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        TestDataFactoryUser.generateUserFutureStudentAgentDomestic();
    }
    
    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
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
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
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
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
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
        System.runAs(TestDataFactoryUser.selectUserFutureStudentAgentDomestic) {
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
        System.runAs(TestDataFactoryUser.selectUserFutureStudentAgentDomestic) {
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
        System.runAs(TestDataFactoryUser.selectUserFutureStudentAgentDomestic) {
            String completedCadenceName = 'Domestic Accepted and Admitted';

            CompletedCadencesDAO.Criteria completedCadenceCriteria = new CompletedCadencesDAO.Criteria();
            completedCadenceCriteria.setCompletedCadence(completedCadenceName);
            completedCadenceCriteria.setStatus(CompletedCadencesDAO.SUCCESSFUL_STATUS);
            completedCadenceCriteria.setCompletedCadanceDateFrom(Date.today().addDays(-10));
            completedCadenceCriteria.setCompletedCadanceDateTo(Date.today().addDays(10));

            ContactsDAO.Criteria contactCriteria = new ContactsDAO.Criteria();
            contactCriteria.setRecordType(ContactsDAO.PERSON_RECORDTYPE);
            contactCriteria.setIsQUTStudent(true);

            String whereClauseString = CompletedCadencesDAO.newInstance().getWhereClauseByCriteria(completedCadenceCriteria, contactCriteria);
            String expectedWhereClauseString = 'WHERE '
            + 'Cadence_Name__c = \'' + completedCadenceCriteria.getCompletedCadence() + '\' '
            + 'AND Completed_Cadence_Status__c = \'' + CompletedCadencesDAO.SUCCESSFUL_STATUS + '\' ' 
            + 'AND LastModifiedDate < ' + DynamicQueryService.convertDatetoDateTimeGMTString(completedCadenceCriteria.getCompletedCadanceDateFrom().addDays(1)) + ' ' 
            + 'AND LastModifiedDate >= ' + DynamicQueryService.convertDatetoDateTimeGMTString(completedCadenceCriteria.getCompletedCadanceDateTo()) + ' '
            + 'AND Contact__r.QUT_Student__c = ' + true + ' ' 
            + 'AND Contact__r.RecordType.DeveloperName = \'' + ContactsDAO.PERSON_RECORDTYPE + '\'';
            System.assertEquals(expectedWhereClauseString, whereClauseString, 'Incorrect Where Clause by criteria.');
        }
        Test.stopTest();
    }

    @isTest
    static void getWhereClauseByCriteriaEmptyTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserFutureStudentAgentDomestic) {
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
        System.runAs(TestDataFactoryUser.selectUserFutureStudentAgentDomestic) {
            String completedCadenceName = 'Domestic Accepted and Admitted';

            CompletedCadencesDAO.Criteria completedCadenceCriteria = new CompletedCadencesDAO.Criteria();
            completedCadenceCriteria.setCompletedCadence(completedCadenceName);
            completedCadenceCriteria.setStatus(CompletedCadencesDAO.SUCCESSFUL_STATUS);
            completedCadenceCriteria.setCompletedCadanceDateFrom(Date.today().addDays(-10));
            completedCadenceCriteria.setCompletedCadanceDateTo(Date.today().addDays(10));

            ContactsDAO.Criteria contactCriteria = new ContactsDAO.Criteria();
            contactCriteria.setRecordType(ContactsDAO.PERSON_RECORDTYPE);
            contactCriteria.setIsQUTStudent(true);
            
            String actualQueryString = CompletedCadencesDAO.newInstance()
                .getContactQueryByCriteria(
                    completedCadenceCriteria,
                    contactCriteria
                );
            
            String expectedQueryString = 'SELECT Contact__c FROM Completed_Cadence__c WHERE '
            + 'Cadence_Name__c = \'' + completedCadenceCriteria.getCompletedCadence() + '\' '
            + 'AND Completed_Cadence_Status__c = \'' + CompletedCadencesDAO.SUCCESSFUL_STATUS + '\' ' 
            + 'AND LastModifiedDate < ' + DynamicQueryService.convertDatetoDateTimeGMTString(completedCadenceCriteria.getCompletedCadanceDateFrom().addDays(1)) + ' ' 
            + 'AND LastModifiedDate >= ' + DynamicQueryService.convertDatetoDateTimeGMTString(completedCadenceCriteria.getCompletedCadanceDateTo()) + ' '
            + 'AND Contact__r.QUT_Student__c = ' + true + ' ' 
            + 'AND Contact__r.RecordType.DeveloperName = \'' + ContactsDAO.PERSON_RECORDTYPE + '\'';
            
            System.assertEquals(expectedQueryString, actualQueryString, 'Contact query by criteria should not be null.');
        }
        Test.stopTest();
    }

    @isTest
    static void getQueryByCriteriaTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserFutureStudentAgentDomestic) {
            String completedCadenceName = 'Domestic Accepted and Admitted';

            CompletedCadencesDAO.Criteria completedCadenceCriteria = new CompletedCadencesDAO.Criteria();
            completedCadenceCriteria.setCompletedCadence(completedCadenceName);
            completedCadenceCriteria.setStatus(CompletedCadencesDAO.SUCCESSFUL_STATUS);
            completedCadenceCriteria.setCompletedCadanceDateFrom(Date.today().addDays(-10));
            completedCadenceCriteria.setCompletedCadanceDateTo(Date.today().addDays(10));

            MockIdGenerator mockIdGen = new MockIdGenerator(Contact.SObjectType);
            Id contactId = mockIdGen.getMockId();

            ContactsDAO.Criteria contactCriteria = new ContactsDAO.Criteria();
            contactCriteria.setRecordType(ContactsDAO.PERSON_RECORDTYPE);
            contactCriteria.setIsQUTStudent(true);
            contactCriteria.setContactIdSet(new Set<Id>{contactId});
            
            String actualQueryString = CompletedCadencesDAO.newInstance()
                .getQueryByCriteria(
                    completedCadenceCriteria,
                    contactCriteria
                );
            String expectedQueryString = 'SELECT Id, Contact__c, Cadence_Name__c, LastModifiedDate FROM Completed_Cadence__c WHERE '
            + 'Cadence_Name__c = \'' + completedCadenceCriteria.getCompletedCadence() + '\' '
            + 'AND Completed_Cadence_Status__c = \'' + CompletedCadencesDAO.SUCCESSFUL_STATUS + '\' ' 
            + 'AND LastModifiedDate < ' + DynamicQueryService.convertDatetoDateTimeGMTString(completedCadenceCriteria.getCompletedCadanceDateFrom().addDays(1)) + ' ' 
            + 'AND LastModifiedDate >= ' + DynamicQueryService.convertDatetoDateTimeGMTString(completedCadenceCriteria.getCompletedCadanceDateTo()) + ' '
            + 'AND Contact__r.QUT_Student__c = ' + true + ' ' 
            + 'AND Contact__r.RecordType.DeveloperName = \'' + ContactsDAO.PERSON_RECORDTYPE + '\' '
            + 'AND Contact__r.Id IN ('+ DynamicQueryService.formatStringSetForWhereClause(contactCriteria.getContactIdSet()) + ')';
            System.assertEquals(expectedQueryString, actualQueryString, 'Incorrect Where Clause');
        }
        Test.stopTest();
    }

    @isTest
    static void findByCriteriaTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserFutureStudentAgentDomestic) {
            //Create record

            List<Contact> contactList = TestDataFactory.createTestContactRecords(1,'Domestic');
            contactList[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            contactList[0].QUT_Student__c = true;
            ContactsDAO.newInstance().insertRecords(contactList, true, AccessLevel.SYSTEM_MODE);
            
            List<Nurture_Track_Configuration__c> initialNurtureList = TestDataFactory.createNurtureTrackConfigRecords(1);
            List<Nurture_Track_Configuration__c> nurtureList = new List<Nurture_Track_Configuration__c>();
            for(Nurture_Track_Configuration__c nurtureTrackConfig : initialNurtureList){
                nurtureList.add(
                    new Nurture_Track_Configuration__c(
                        Id = nurtureTrackConfig.Id,
                        Cadence_Name__c = 'Domestic Accepted and Admitted',
                        Lead_Score_Threshold__c = 3
                    )
                );
            }
            NurtureTrackConfigurationsDAO.newInstance().insertRecords(nurtureList, false, AccessLevel.SYSTEM_MODE);    

            List<Completed_Cadence__c> completedCadenceListCreated = TestDataFactory.createCompletedCadence('Successful',nurtureList[0].Id,new Set<Id>{contactList[0].Id});
            CompletedCadencesDAO.newInstance().insertRecords(completedCadenceListCreated,true,AccessLevel.SYSTEM_MODE);

            CompletedCadencesDAO.Criteria completedCadenceCriteria = new CompletedCadencesDAO.Criteria();
            completedCadenceCriteria.setStatus(CompletedCadencesDAO.SUCCESSFUL_STATUS);
            completedCadenceCriteria.setCompletedCadanceDateFrom(Date.today().addDays(10));
            completedCadenceCriteria.setCompletedCadanceDateTo(Date.today().addDays(-10));

            ContactsDAO.Criteria contactCriteria = new ContactsDAO.Criteria();
            contactCriteria.setRecordType(ContactsDAO.PERSON_RECORDTYPE);
            contactCriteria.setIsQUTStudent(true);
            contactCriteria.setCitizenshipStatus(ContactsDAO.CITIZENSHIP_STATUS_DOMESTIC);
    
            List<Completed_Cadence__c> completedCadenceList = CompletedCadencesDAO.newInstance()
                .findByCriteria(
                    completedCadenceCriteria,
                    contactCriteria,
                    AccessLevel.USER_MODE
                );

            System.assertEquals(completedCadenceListCreated.size(), completedCadenceList.size(),'completedCadenceList should not be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void findByCriteriaNegativeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserFutureStudentAgentDomestic) {
            //Create record

            List<Contact> contactList = TestDataFactory.createTestContactRecords(1,'Domestic');
            contactList[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            contactList[0].QUT_Student__c = true;
            ContactsDAO.newInstance().insertRecords(contactList, true, AccessLevel.SYSTEM_MODE);
            
            List<Nurture_Track_Configuration__c> initialNurtureList = TestDataFactory.createNurtureTrackConfigRecords(1);
            List<Nurture_Track_Configuration__c> nurtureList = new List<Nurture_Track_Configuration__c>();
            for(Nurture_Track_Configuration__c nurtureTrackConfig : initialNurtureList){
                nurtureList.add(
                    new Nurture_Track_Configuration__c(
                        Id = nurtureTrackConfig.Id,
                        Cadence_Name__c = 'Domestic Accepted and Admitted',
                        Lead_Score_Threshold__c = 3
                    )
                );
            }
            NurtureTrackConfigurationsDAO.newInstance().insertRecords(nurtureList, false, AccessLevel.SYSTEM_MODE);    

            //Create complete cadence with unsuccessful status
            List<Completed_Cadence__c> completedCadenceListCreated = TestDataFactory.createCompletedCadence('Unsuccessful',nurtureList[0].Id,new Set<Id>{contactList[0].Id});
            CompletedCadencesDAO.newInstance().insertRecords(completedCadenceListCreated,true,AccessLevel.SYSTEM_MODE);

            CompletedCadencesDAO.Criteria completedCadenceCriteria = new CompletedCadencesDAO.Criteria();
            completedCadenceCriteria.setStatus(CompletedCadencesDAO.SUCCESSFUL_STATUS);

            ContactsDAO.Criteria contactCriteria = new ContactsDAO.Criteria();
            contactCriteria.setRecordType(ContactsDAO.PERSON_RECORDTYPE);
            contactCriteria.setIsQUTStudent(true);
            contactCriteria.setCitizenshipStatus(ContactsDAO.CITIZENSHIP_STATUS_DOMESTIC);
    
            List<Completed_Cadence__c> completedCadenceList = CompletedCadencesDAO.newInstance()
                .findByCriteria(
                    completedCadenceCriteria,
                    contactCriteria,
                    AccessLevel.USER_MODE
                );

            System.assert(completedCadenceList.isEmpty(),'CompletedCadenceList record should be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void criteriaIsEmptyTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserFutureStudentAgentDomestic) {
            CompletedCadencesDAO.Criteria criteria = new CompletedCadencesDAO.Criteria();
            System.assert(criteria.isEmpty(), 'Criteria should be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void criteriaIsNotEmptyTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserFutureStudentAgentDomestic) {
            String completedCadenceName = 'Domestic Accepted and Admitted';

            CompletedCadencesDAO.Criteria completedCadenceCriteria = new CompletedCadencesDAO.Criteria();
            completedCadenceCriteria.setCompletedCadence(completedCadenceName);
            completedCadenceCriteria.setStatus(CompletedCadencesDAO.SUCCESSFUL_STATUS);
            
            System.assert(!completedCadenceCriteria.isEmpty(), 'Criteria should be not be empty.');
        }
        Test.stopTest();
    }
       
    @isTest
    static void getCompletedCadencebyRecordIdTest(){
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserFutureStudentAgentDomestic) {
            List<Completed_Cadence__c> completedCadenceList = CompletedCadencesDAO.newInstance()
            .getCompletedCadencebyRecordId(
                new Set<Id>(),
                AccessLevel.SYSTEM_MODE
            );
            System.assert(completedCadenceList.isEmpty(), 'Completed Cadence should not be empty.'); 
        }
        Test.stopTest();
    }
}