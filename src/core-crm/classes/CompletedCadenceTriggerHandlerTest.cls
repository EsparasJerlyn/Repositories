/**
 * @description Test Class for CompletedCadenceTriggerHandler
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan            | August 05, 2024       | DEPP-8255              | Created file                 |
 */

@isTest
private class CompletedCadenceTriggerHandlerTest {

    @TestSetup
    static void testSetup(){

        TestDataFactoryUser.generateUserFutureStudentAgentDomestic();

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
        List<Completed_Cadence__c> completedCadenceListCreated = new List<Completed_Cadence__c>();


        for(Integer i = 0; i < 100 ; i++){
            List<Completed_Cadence__c> completedCadence = new List<Completed_Cadence__c>();
            completedCadence = TestDataFactory.createCompletedCadence('',nurtureList[0].Id,new Set<Id>{contactList[0].Id});
            completedCadenceListCreated.add(completedCadence[0]);
        }

        CompletedCadencesDAO.newInstance().insertRecords(completedCadenceListCreated, false, AccessLevel.SYSTEM_MODE);
    }

    @isTest
    static void beforeUpdateCompletedCadenceStatusTest(){

        System.runAs(TestDataFactoryUser.selectUserFutureStudentAgentDomestic) {
            List<Completed_Cadence__c> completedCadenceListCreated = CompletedCadencesDAO.newInstance().getCompletedCadenceByStatus('', AccessLevel.SYSTEM_MODE);
            Test.startTest();

            for(Completed_Cadence__c completedCadenceUpdate : completedCadenceListCreated){
                completedCadenceUpdate.Completed_Cadence_Status__c = CompletedCadencesDAO.SUCCESSFUL_STATUS;
            }
            CompletedCadencesDAO.newInstance().updateRecords(completedCadenceListCreated, false, AccessLevel.SYSTEM_MODE);

            Test.stopTest();

            Map<Id, Completed_Cadence__c> completedCadenceMap = new Map<Id, Completed_Cadence__c>(completedCadenceListCreated);


            List<Completed_Cadence__c> completedCadenceUpdated = CompletedCadencesDAO.newInstance().
                getCompletedCadenceByRecordId(completedCadenceMap.keySet(), AccessLevel.SYSTEM_MODE);

            for(Completed_Cadence__c completedCadence : completedCadenceUpdated){
                System.assertEquals(System.today(), completedCadence.Completed_Date__c , 'Completed Date must be equal if Status is set to Successful');

            }
        }
    }

    @isTest
    static void beforeUpdateCompletedCadenceStatusNegativeTest(){

        System.runAs(TestDataFactoryUser.selectUserFutureStudentAgentDomestic) {
            List<Completed_Cadence__c> completedCadenceListCreated = CompletedCadencesDAO.newInstance().getCompletedCadenceByStatus('', AccessLevel.SYSTEM_MODE);
            Test.startTest();

            for(Completed_Cadence__c completedCadenceUpdate : completedCadenceListCreated){
                completedCadenceUpdate.Completed_Cadence_Status__c = CompletedCadencesDAO.CLOSED_FOLLOW_UP_STATUS;
            }
            CompletedCadencesDAO.newInstance().updateRecords(completedCadenceListCreated, false, AccessLevel.SYSTEM_MODE);

            Test.stopTest();

            Map<Id, Completed_Cadence__c> completedCadenceMap = new Map<Id, Completed_Cadence__c>(completedCadenceListCreated);


            List<Completed_Cadence__c> completedCadenceUpdated = CompletedCadencesDAO.newInstance().
                getCompletedCadenceByRecordId(completedCadenceMap.keySet(), AccessLevel.SYSTEM_MODE);

            for(Completed_Cadence__c completedCadence : completedCadenceUpdated){
                System.assertEquals(null, completedCadence.Completed_Date__c , 'Completed Date should not be updated when status is changed');
            }
        }
    }
}