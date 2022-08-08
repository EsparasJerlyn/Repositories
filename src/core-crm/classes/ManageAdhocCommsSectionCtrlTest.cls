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
    
    private static final String PROGRAM_OFFERING = 'Program_Offering__c';
    private static final String STR_TEST = 'Test';
    private static final String TEST_EMAIL = 'test@invalid.com.devgalaa1';
    private static final String QUTEX = System.Label.QUTeX;
    private static User currentUser = TestDataFactory.createUserRecords(1, QUTEX).iterator().next();
    private static final String ORG_ID = UserInfo.getOrganizationId();

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
    private static void getHeaderAndFooterImageUrlsTest(){
        System.runAs(currentUser){
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
