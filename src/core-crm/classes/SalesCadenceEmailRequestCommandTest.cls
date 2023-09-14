/**
 * @description Test class for SalesCadenceEmailRequestCommand
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz      	       | September 2, 2023     | DEPP-6138              | Created file                 | 
 */

@isTest
public with sharing class SalesCadenceEmailRequestCommandTest {

    @TestSetup
    static void setupData(){
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_System_Administrator' });
        System.runAs(TestDataFactory.getSystemAdminUser()) { 

            List<Nurture_Track_Configuration__c> initialNurtureList = TestDataFactory.createNurtureTrackConfigRecords(1);
            List<Nurture_Track_Configuration__c> nurtureList = new List<Nurture_Track_Configuration__c>();
            for(Nurture_Track_Configuration__c nurtureTrackConfig : initialNurtureList){
                nurtureList.add(
                    new Nurture_Track_Configuration__c(
                        Id = nurtureTrackConfig.Id,
                        Cadence_Name__c = 'International Application Submission - Direct Applicant (Automated)',
                        Lead_Score_Threshold__c = 3,
                        Status__c = 'Active'
                    )
                );
            }
            NurtureTrackConfigurationsDAO.newInstance().insertRecords(nurtureList, false, AccessLevel.SYSTEM_MODE);  
            
        }
    }

    @isTest
    private static void sendEmailWithSentStatusTest() {
        System.runAs(TestDataFactory.getSystemAdminUser()) {
            Lead_Score_Detail__c lsd = new Lead_Score_Detail__c();
            lsd.Total_Lead_Score__c = 350;
            insert lsd;

            List<Contact> contactList = TestDataFactory.createTestContactRecords(1,2);
            for(Contact c :contactList ){
                c.Calculated_Cadence__c = 'International Application Submission - Direct Applicant (Automated)';
                c.hed__Citizenship_Status__c = 'Domestic';
                c.Lead_Score_Detail__c = lsd.Id;
            }
            ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.USER_MODE);

            Set<Id> resultIds = (new Map<Id,SObject>(contactList)).keySet();
            List<Communication_Queue__c> commsQueueList = TestDataFactory.createCommunicationQueuePerContactOrLead(
                resultIds, 
                CommunicationQueuesDAO.STATUS_SCHEDULED
            );
            CommunicationQueuesDAO.newInstance().insertRecords(commsQueueList, false, AccessLevel.USER_MODE);
            
            List<Communication_Queue__c> communicationQueueList = CommunicationQueuesDAO.newInstance().getComminicationQueueRecordsByStatus(
                new Set<String>{CommunicationQueuesDAO.STATUS_SCHEDULED},
                AccessLevel.USER_MODE
            );
            Test.startTest();
            RequestCommand cmd = new RequestCommand();
            cmd.setCommand(new SalesCadenceEmailRequestCommand(communicationQueueList));
            cmd.executeCommand();     
            Test.stopTest();
        }

        List<Communication_Queue__c> commsQueue = CommunicationQueuesDAO.newInstance().getComminicationQueueRecordsByStatus(
            new Set<String>{CommunicationQueuesDAO.STATUS_SENT},
            AccessLevel.USER_MODE
        );

        System.assert(!commsQueue.isEmpty(), 'List should not be empty.');
    }

}