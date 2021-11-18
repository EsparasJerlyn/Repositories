/**
 * @description Tests Class for DocuSignContentVersionTriggerHandler
 * @see DocuSignContentVersionTriggerHandlerTest
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | arsenio.dayrit@qut.edu.au      | November 11, 2021     | DEPP-503               | Created file                 | 
      |                                |                       |                        |                              | 
 */
@isTest(SeeAllData = false)
public class DocuSignContentVersionTriggerHandlerTest {
    
    private static User  currentUser = TestDataFactory.createUserRecords(1,'QUTeX').iterator().next();


    @isTest
    private static void insertContentVersion(){

        System.runAs(currentUser){
            
            List<ContentVersion> contentVersionRecords =TestDataFactory.createTestContentVersionRecords(100);
            Test.startTest();
            insert contentVersionRecords;
            Test.stopTest();

            List<ContentVersion> contentVersions = [SELECT Id, Title FROM ContentVersion LIMIT 100];
            for(ContentVersion checkContentVersion : contentVersions){
                System.assertEquals(80, checkContentVersion.Title.length(), 'length of the title did not match');
            }
        }

    }

    @isTest
    private static void updatetContentVersion(){
    
        System.runAs(currentUser){ 
            List<ContentVersion> contentVersionRecords =TestDataFactory.createTestContentVersionRecords(100);
            insert contentVersionRecords;

            Test.startTest();
            List<ContentVersion> updateContentVersions = new List<ContentVersion>();
            List<ContentVersion> contentVersions = [SELECT Id, Title from ContentVersion LIMIT 100];
            for(ContentVersion contentVersionUpdate : contentVersions){
                contentVersionUpdate.Title = 'Proposal - General With Content_ALPHA ZENITH PTY LTD-test sample sample opportunity that may e123123123samplesample';
                updateContentVersions.add(contentVersionUpdate);
            }            
            update updateContentVersions;
            Test.stopTest();
        }
           
        List<ContentVersion> getContentVersions = [SELECT Id, Title FROM ContentVersion LIMIT 100];
        for(ContentVersion checkContentVersion : getContentVersions){
            System.assertEquals(80, checkContentVersion.Title.length(), 'length of the title did not match');
        }
      
    }
    
}
