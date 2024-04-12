/**
 * @description Test class for Adhoc Communication Batch Class
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email           | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | eugene.andrew.abuan   	  | October 10, 2023      | DEPP-6612            | Created file                 | 
 */
@isTest
public with sharing class AdhocCommunicationBatchTest {

    @testSetup 
    static void setupMethod() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator', 'QUT_IE_Partnership_Manager'} );
        System.runAs(TestDataFactory.getProgramAdminUser()){
            Test.startTest();
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
			
            Test.stopTest();
        }
    }
        
    @isTest
    private static void sendAdhocEmailBatchTest() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            AdhocCommunicationTriggerHandler.isRunning = true;

            Id programOfferingId = [Select Id From Program_Offering__c Limit 1]?.Id;
            List<Adhoc_Communication__c> adhocCommunicationList = TestDataFactory.createTestAdhocCommsRecords(1);
            adhocCommunicationList[0].Program_Offering__c = programOfferingId;

            Test.startTest();
            AdhocCommunicationsDAO.newInstance().insertRecords(adhocCommunicationList, false, AccessLevel.SYSTEM_MODE);
			AdhocCommunicationBatch batch = new AdhocCommunicationBatch();
            Database.executeBatch(batch);
            Test.stopTest();
            
            System.assert(![SELECT Id FROM AsyncApexJob WHERE ApexClass.Name = 'AdhocCommunicationBatch'].isEmpty() , 'AdhocCommunicationBatch Job was not executed');
        }
    }
    
    @isTest
    static void sendAdhocEmailBatchExceptionTest(){
        try{
            System.runAs(TestDataFactory.getQUTIEPartnershipManager()){
                AdhocCommunicationTriggerHandler.isRunning = true;

                Id programOfferingId = [Select Id From Program_Offering__c Limit 1]?.Id;
                List<Adhoc_Communication__c> adhocCommunicationList = TestDataFactory.createTestAdhocCommsRecords(1);
                adhocCommunicationList[0].Program_Offering__c = programOfferingId;

                Test.startTest();
                AdhocCommunicationsDAO.newInstance().insertRecords(adhocCommunicationList, false, AccessLevel.SYSTEM_MODE);
                AdhocCommunicationBatch batch = new AdhocCommunicationBatch();
                Database.executeBatch(batch);
                Test.stopTest();
            }
        }catch(Exception e){
         	 System.assertEquals('Exception caught in method execute in class AdhocCommunicationsBatch.', 
                                 e.getMessage(), 'adhocCommunicationsToUpdateList method in AdhocCommunicationBatch should fire an exception');

        }
    }
}