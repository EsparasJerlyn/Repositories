/**
 * @description Test class for ManageAdhocCommsSectionCtrl
 *
 * @see ManageAdhocCommsSectionCtrl
 * 
 * @author Accenture
 *      
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                               |
      |---------------------------|-----------------------|----------------------|----------------------------------------------|
      | angelika.j.s.galang       | April 6, 2022         | DEPP-2229            | Created file                                 | 
      | eugene.andrew.abuan       | October 10, 2023      | DEPP-6612            | updated sendEmailToRegisteredLearnersTest    |
*/
@isTest
private class ManageAdhocCommsSectionCtrlTest {
    
    private static final String PROGRAM_OFFERING = 'Program_Offering__c';
    private static final String STR_TEST = 'Test';
    private static final String ORG_ID = UserInfo.getOrganizationId();

    @testSetup
    static void setupMethod(){
        TestDataFactory.generateTestUsers(new List<String>{ 'QUTeX_Program_Administrator'} );
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
    
            List<Adhoc_Communication__c> adhocCommunicationList = TestDataFactory.createTestAdhocCommsRecords(1);
            adhocCommunicationList[0].Program_Offering__c = programOffering[0].Id;
            AdhocCommunicationsDAO.newInstance().insertRecords(adhocCommunicationList, false, AccessLevel.SYSTEM_MODE);
            Test.stopTest();
        }
    } 

    @isTest
    private static void getAdhocCommunicationsTest(){
        System.runAs(TestDataFactory.getProgramAdminUser()){
            Test.startTest();
            Id programOfferingId = [Select Id From Program_Offering__c Limit 1]?.Id;
            List<Adhoc_Communication__c> adhocComms = ManageAdhocCommsSectionCtrl.getAdhocCommunications(programOfferingId,PROGRAM_OFFERING);
            Test.stopTest();
            System.assertEquals(1,adhocComms.size(), 'Related Adhoc Comms not retrieved as expected');
        }
    }

    @isTest
    private static void getHeaderAndFooterImageUrlsTest(){
        System.runAs(TestDataFactory.getProgramAdminUser()){
            String imageInfos = JSON.serialize(
                new List<Map<String,String>>{
                    new Map<String,String>{
                        'imageName' => STR_TEST
                    }
                }
            );
            String expectedURL = System.URL.getOrgDomainUrl().toExternalForm() + '/file-asset-public/'  + STR_TEST + '?oid=' + ORG_ID;
            Test.startTest();
            List<GenerateImageServerURL.ImageURL> imageUrls = ManageAdhocCommsSectionCtrl.getHeaderAndFooterImageUrls(imageInfos);
            Test.stopTest();
            System.assertEquals(expectedURL,imageUrls[0].imageUrl, 'URL not retrieved as expected');
        }
    }

   @isTest
   private static void sendEmailToRegisteredLearnersTest(){
        System.runAs(TestDataFactory.getProgramAdminUser()){
           Test.startTest();
          List<Adhoc_Communication__c> adhocCommunicationList = [SELECT Id, Name, IsSent__c, Send_Date__c, Subject__c, CreatedDate, Email_Content__c, Program_Offering__c, Course_Offering__c
                                                                  FROM Adhoc_Communication__c];
           Boolean emailResult = ManageAdhocCommsSectionCtrl.sendEmailToRegisteredLearners(adhocCommunicationList);
           Test.stopTest();
         System.assertEquals(true , emailResult, 'Email Result not as expected');
      }
    }
}