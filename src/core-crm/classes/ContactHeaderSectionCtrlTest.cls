/**
 * @description Tests Controller Class for ContactHeaderSectionCtrl
 * @see ContactHeaderSectionCtrlTest
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | arsenio.jr.dayrit              | March 04, 2023        | DEPP-5322              | Created file                 | 
      | kenneth.f.alsay                | December 27, 2023     |                        | Removed unused variable      |
      |                                |                       |                        |                              | 
 */
@isTest
public class ContactHeaderSectionCtrlTest {

    @testSetup
    static void testData(){
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

    @isTest
    static void createContentDistributionTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Test.startTest();
            // Create a new test account
            List<Contact> conList = TestDataFactory.createTestContactRecords(1);
            insert conList;
            
            // Create a new ContentVersion object with the test file content
            ContentVersion testContentVersion = new ContentVersion();
            testContentVersion.Title = 'Test File';
            testContentVersion.PathOnClient = 'TestFile.jpg';
            testContentVersion.VersionData = Blob.valueOf('Test Content');
            testContentVersion.IsMajorVersion = true;
            insert testContentVersion;

            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = conList[0].id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.shareType = 'V';
            insert cdl;
            // Create a new ContentDistribution object with the test file content
            String response = ContactHeaderSectionCtrl.createContentDistribution(testContentVersion.Id);
            Test.stopTest();
            
            // Verify that the file and distribution were created
            
            ContentDistribution createdContentDistribution = [SELECT Id, Name FROM ContentDistribution WHERE ContentVersion.Id = :testContentVersion.id LIMIT 1];
            System.assertEquals('PublicShare', createdContentDistribution.Name,'No Content Destribution created');
            System.assert(response!=null, response);
        }
    }

    @isTest
    static void createContentDistributionErrorTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Test.startTest();
            Boolean exceptionOccurred = false;
            try{
                // Create a new ContentDistribution object with the test file content
                ContactHeaderSectionCtrl.createContentDistribution('test');
            }catch(Exception e){
                exceptionOccurred = true;
            }
            System.assertEquals(true, exceptionOccurred,'should error');

            Test.stopTest();
        }
    }
}