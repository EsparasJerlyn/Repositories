
/**
 * @description Test Class for CompletedCadenceTriggerHelper
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan            | August 05, 2024       | DEPP-8255              | Created file                 |
 */
@isTest
private class CompletedCadenceTriggerHelperTest {

    @TestSetup
    static void testSetup(){
        
        TestDataFactoryUser.generateUserFutureStudentAgentDomestic();
        TestDataFactoryUser.generateUserIndustryPartnershipManager();

    }

    @isTest
    static void beforeUpdateCompletedCadenceStatusTest(){
        System.runAs(TestDataFactoryUser.selectUserFutureStudentAgentDomestic) {

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
            
            List<Completed_Cadence__c> newCompletedCadenceList = new List<Completed_Cadence__c>();

            for(Completed_Cadence__c completedCadenceCreated : completedCadenceListCreated){
                Completed_Cadence__c completedCadenceNew = new Completed_Cadence__c();
                completedCadenceNew.Id = completedCadenceCreated.Id;
                completedCadenceNew.Completed_Cadence_Status__c = CompletedCadencesDAO.SUCCESSFUL_STATUS;
                newCompletedCadenceList.add(completedCadenceNew);
            }

            Test.startTest();

            CompletedCadenceTriggerHelper helper = new CompletedCadenceTriggerHelper();
            helper.fastFieldUpdateAndValidation(
                new Map<Id,Completed_Cadence__c>(newCompletedCadenceList),
                new Map<Id,Completed_Cadence__c>(completedCadenceListCreated)
            );

            CompletedCadencesDAO.newInstance().updateRecords(newCompletedCadenceList, false, AccessLevel.SYSTEM_MODE);

            Test.stopTest();

            Map<Id, Completed_Cadence__c> completedCadenceMap = new Map<Id, Completed_Cadence__c>(newCompletedCadenceList);

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
            
            List<Completed_Cadence__c> newCompletedCadenceList = new List<Completed_Cadence__c>();

            for(Completed_Cadence__c completedCadenceCreated : completedCadenceListCreated){
                Completed_Cadence__c completedCadenceNew = new Completed_Cadence__c();
                completedCadenceNew.Id = completedCadenceCreated.Id;
                completedCadenceNew.Completed_Cadence_Status__c = CompletedCadencesDAO.SUCCESSFUL_STATUS;
                newCompletedCadenceList.add(completedCadenceNew);
            }



            Test.startTest();

            CompletedCadenceTriggerHelper helper = new CompletedCadenceTriggerHelper();
            helper.fastFieldUpdateAndValidation(
                new Map<Id,Completed_Cadence__c>(newCompletedCadenceList),
                new Map<Id,Completed_Cadence__c>(completedCadenceListCreated)
            );

            CompletedCadencesDAO.newInstance().updateRecords(newCompletedCadenceList, false, AccessLevel.SYSTEM_MODE);

            Test.stopTest();

            Map<Id, Completed_Cadence__c> completedCadenceMap = new Map<Id, Completed_Cadence__c>(newCompletedCadenceList);

            List<Completed_Cadence__c> completedCadenceUpdated = CompletedCadencesDAO.newInstance().
                getCompletedCadenceByRecordId(completedCadenceMap.keySet(), AccessLevel.SYSTEM_MODE);

            for(Completed_Cadence__c completedCadence : completedCadenceUpdated){
                System.assertEquals(System.today(), completedCadence.Completed_Date__c , 'Completed Date must be equal if Status is set to Successful');

            }
        }
    }


    @isTest
    static void beforeUpdateCompletedCadenceStatusExceptionTest(){
        try{
            System.runAs(TestDataFactoryUser.selectUserFutureStudentAgentDomestic) {
        
        
                Test.startTest();
                CompletedCadenceTriggerHelper helper = new CompletedCadenceTriggerHelper();
                helper.fastFieldUpdateAndValidation(null,null );        
                Test.stopTest();
            }
        }catch (Exception e){
                String exceptionMessage = e.getMessage();
                System.assert(!String.isBlank(exceptionMessage), 'completedCadenceUpdate method in CompletedCadenceTriggerHelper should fire an exception'); 
        }
    }
}