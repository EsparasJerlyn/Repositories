/**
 * @description Test Class for ELCCompletedCadenceEvaluator
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                              |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------------------------|
      | arsenio.jr.dayrit              | May 09, 2024          | DEPP-8487              | Created file                                                |
*/
@isTest
public with sharing class ELCCompletedCadenceEvaluatorTest {

    @TestSetup
    static void setupMethod(){
        TestDataFactoryUser.generateUserQUTESB();
    }

    @isTest
    static void evaluateWithReturnTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();

            String citizenshipStatus = ContactsDAO.CITIZENSHIP_STATUS_INTERNATIONAL;

            Date executionDate = Date.today();
            Engagement_List_Criteria__c engagementListCriteria = new Engagement_List_Criteria__c();
            engagementListCriteria.Citizenship_Status__c = citizenshipStatus;
            engagementListCriteria.Completed_Cadence__c = 'Domestic Accepted and Admitted';

            List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
            contactList[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            contactList[0].QUT_Student__c = true;
            contactList[0].hed__Citizenship_Status__c = citizenshipStatus;
            ContactsDAO.newInstance().insertRecords(contactList,true,AccessLevel.USER_MODE);

            List<Nurture_Track_Configuration__c> nurtureListCon = new List<Nurture_Track_Configuration__c>();
            Nurture_Track_Configuration__c nurtureTrackConfig = new Nurture_Track_Configuration__c();
            nurtureTrackConfig.Cadence_Name__c = 'Domestic Accepted and Admitted';
            nurtureListCon.add(nurtureTrackConfig);

            NurtureTrackConfigurationsDAO.newInstance().insertRecords(nurtureListCon, false, AccessLevel.SYSTEM_MODE);

            List<Completed_Cadence__c> completedCadenceList = TestDataFactory.createCompletedCadence(CompletedCadencesDAO.SUCCESSFUL_STATUS,nurtureListCon[0].Id,new Set<Id>{contactList[0].Id});
            CompletedCadencesDAO.newInstance().insertRecords(completedCadenceList, false, AccessLevel.SYSTEM_MODE);

            ELCParser parser = new ELCParser(engagementListCriteria, executionDate);
            ELCCompletedCadenceEvaluator evaluator = new ELCCompletedCadenceEvaluator(parser);
            Map<Id, List<Completed_Cadence__c>> evaluateMap =  evaluator.evaluate(new Map<Id, Contact>(contactList));

            Test.stopTest();
            System.assert(evaluateMap.containsKey(contactList[0].Id), 'The Map should have a contact Id as a Key');
            System.assert(!evaluateMap.get(contactList[0].Id).isEmpty(), 'The Map should have Completed Cadence');
            System.assertNotEquals(null, evaluateMap.size() , ' The Evaluator should have a return');

        }
    }
}