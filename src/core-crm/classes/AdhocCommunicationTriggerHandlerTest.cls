/**
 * @description Test Class for AdhocCommunicationTriggerHandlerTest
 *
 * @see AdhocCommunicationTrigger
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | eugene.andrew.abuan       | October 10,2023       | DEPP-6612    | Created file                                |
*/
@IsTest
private class AdhocCommunicationTriggerHandlerTest {

    @testSetup
    static void testSetup() {
        Test.startTest();
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        Test.stopTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            
            Account acc = TestDataFactory.createTestAccount(false);
            acc.RecordTypeId = AccountsDAO.ACCT_BUSINESS_ORG_ID;
            insert acc;
            
            List<Contact> newContacts = TestDataFactory.createTestContactRecords(0, 1);
            newContacts[0].AccountId = acc.Id;
            newContacts[0].Registered_Email__c ='work0testmail@mail.test';
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);
    
            List<hed__Program_Plan__c> programList = TestDataFactory.createTestProgramPlanRecords(1);
            programList[0].Availability_Start_Date__c = System.today();
            ProgramPlansDAO.newInstance().insertRecords(programList, false, AccessLevel.SYSTEM_MODE);
    
            List<hed__Program_Enrollment__c> programEnrollmentList = TestDataFactory.createTestProgramEnrollmentRecords(1);
            programEnrollmentList[0].hed__Contact__c = newContacts[0].Id;
            ProgramEnrollmentsDAO.newInstance().insertRecords(programEnrollmentList, false, AccessLevel.SYSTEM_MODE);
    
            List<Program_Offering__c> programOffering = TestDataFactory.createTestProgramOfferingRecords(1,programList);
            insert programOffering;

            List<hed__Course_Enrollment__c> courseEnrollmentList = new List<hed__Course_Enrollment__c>();
            courseEnrollmentList.add(new hed__Course_Enrollment__c(
                hed__Contact__c = newContacts[0].Id, 
                Enrollment_Status__c = 'Test',
                hed__Program_Enrollment__c = programEnrollmentList[0].Id,
                Program_Offering__c = programOffering[0].Id,
                hed__Status__c = 'Active'
            )); 
            CourseConnectionsDAO.newInstance().insertRecords(courseEnrollmentList, false, AccessLevel.SYSTEM_MODE);
			
        }
    }

    @isTest
    static void testBeforeInsertAdhocCommunicationTriggerHandler(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Id programOfferingId = [Select Id From Program_Offering__c Limit 1]?.Id;
            List<Adhoc_Communication__c> adhocCommunicationList = TestDataFactory.createTestAdhocCommsRecords(1);
            adhocCommunicationList[0].Program_Offering__c = programOfferingId;
            
            Test.startTest();
            	AdhocCommunicationsDAO.newInstance().insertRecords(adhocCommunicationList, false, AccessLevel.SYSTEM_MODE);
            Test.stopTest();
            System.assertEquals(true, AdhocCommunicationTriggerHandler.isRunning, 'The AdhocCommunicationTriggerHandler did not fire a before insert operation');
        }
    }
    
   @isTest
    static void testBeforeUpdateAdhocCommunicationTriggerHandler() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Id programOfferingId = [Select Id From Program_Offering__c Limit 1]?.Id;
            List<Adhoc_Communication__c> adhocCommunicationList = TestDataFactory.createTestAdhocCommsRecords(1);
            adhocCommunicationList[0].Program_Offering__c = programOfferingId;
            adhocCommunicationList[0].Send_Date__c = System.today()+1;
            AdhocCommunicationsDAO.newInstance().insertRecords(adhocCommunicationList, false, AccessLevel.SYSTEM_MODE);

            Test.startTest();
                adhocCommunicationList[0].Send_Date__c = System.today();
                AdhocCommunicationTriggerHandler.isRunning = false;
                AdhocCommunicationsDAO.newInstance().updateRecords(adhocCommunicationList, false, AccessLevel.SYSTEM_MODE);
            Test.stopTest();

            System.assertEquals(true, AdhocCommunicationTriggerHandler.isRunning, 'The AdhocCommunicationTriggerHandler did not fire a before update operation');
        }
    }
}