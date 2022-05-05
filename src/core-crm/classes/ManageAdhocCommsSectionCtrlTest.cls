/**
 * @description Test class for ManageAdhocCommsSectionCtrl
 *
 * @see ManageAdhocCommsSectionCtrl
 * 
 * @author Accenture
 *      
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                  |
      |---------------------------|-----------------------|----------------------|---------------------------------|
      | angelika.j.s.galang       | April 6, 2022         | DEPP-2229            | Created file                    | 
*/
@IsTest(SeeAllData = false)
private class ManageAdhocCommsSectionCtrlTest {
    
    private static final String EMAIL_HEADER = System.Label.DOC_Email_Header;
    private static final List<String> FILE_NAMES = new List<String>{EMAIL_HEADER};
    private static final String EMAIL_FOLDER = 'QUTeX Email Contents';
    private static final String PROGRAM_OFFERING = 'Program_Offering__c';
    private static final String STR_TEST = 'Test';
    private static final String TEST_EMAIL = 'test@invalid.com.devgalaa1';
    private static final String QUTEX = System.Label.QUTeX;
    private static User currentUser = TestDataFactory.createUserRecords(1, QUTEX).iterator().next();

    @testSetup static void setupMethod() {
        hed__Program_Plan__c programPlan = TestDataFactory.createTestProgramPlanRecords(1).iterator().next();
        insert programPlan;

        Program_Offering__c programOffering = TestDataFactory.createTestProgramOfferingRecords(
            1,new List<hed__Program_Plan__c>{programPlan}
        ).iterator().next();
        insert programOffering;

        Adhoc_Communication__c adhocCommunication = TestDataFactory.createTestAdhocCommsRecords(1).iterator().next();
        adhocCommunication.Program_Offering__c = programOffering?.Id;
        insert adhocCommunication;

        List<Document> documentList = TestDataFactory.createTestDocumentRecords(1,FILE_NAMES,EMAIL_FOLDER);
        insert documentList;
    } 

    @IsTest
    private static void getAdhocCommunicationsTest(){
        System.runAs(currentUser){
            Test.startTest();
            Id programOfferingId = [Select Id From Program_Offering__c Limit 1]?.Id;
            List<Adhoc_Communication__c> adhocComms = ManageAdhocCommsSectionCtrl.getAdhocCommunications(programOfferingId,PROGRAM_OFFERING);
            Test.stopTest();
            System.assertEquals(1,adhocComms.size(), 'Related Adhoc Comms not retrieved as expected');
        }
    }

    @IsTest
    private static void getHeaderAndFooterImageIdsTest(){
        System.runAs(currentUser){
            Id documentId = [Select Id From Document Limit 1]?.Id;
            Test.startTest();
            Map<String,Id> imageIdMap = ManageAdhocCommsSectionCtrl.getHeaderAndFooterImageIds(FILE_NAMES);
            Test.stopTest();
            System.assertEquals(documentId,imageIdMap.get(EMAIL_HEADER), 'Email Result not as expected');
        }
    }

    @IsTest
    private static void sendEmailToRegisteredLearnersTest(){
        System.runAs(currentUser){
            Test.startTest();
            String emailResult = ManageAdhocCommsSectionCtrl.sendEmailToRegisteredLearners(STR_TEST,STR_TEST,new List<String>{TEST_EMAIL});
            Test.stopTest();
            System.assertEquals('success',emailResult, 'Email Result not as expected');
        }
    }
}

