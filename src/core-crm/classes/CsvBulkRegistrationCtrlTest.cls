/**
 * @description Tests the CsvBulkRegistrationCtrl class 
 *
 * @see CsvBulkRegistrationCtrl
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA     | Change Summary                  |
      |---------------------------|-----------------------|----------|---------------------------------|
      | aljohn.p.motas            | December 27, 2021     | DEPP-214 | Created file                    | 
      | roy.nino.s.regala         | Janruary 14, 2022     | DEPP-214 | to SeaAllData=false             |
      | julie.jane.alegre         | September 05, 2023    | DEPP-4762| Update   test data              |
*/

@isTest
public class CsvBulkRegistrationCtrlTest {
	  
    @testSetup 
    static void setupMethod() {
        Test.startTest();
        TestDataFactoryUser.generateUserSystemAdministrator();
        Test.stopTest();
    }
    
    @isTest
    static void testGetCMSContentDataByNameFailed()
    {
    final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
        System.runAs(PORTAL_SYS_ADMIN) {
            List<NetworkMember> communityIds = [SELECT NetworkId FROM NetworkMember limit 1];
            String communityId = communityIds[0].NetworkId;
            Test.startTest();
            ConnectApi.ManagedContentVersion contentData= new ConnectApi.ManagedContentVersion();
            CsvBulkRegistrationCtrl.CMSContentDataFilter filter = new CsvBulkRegistrationCtrl.CMSContentDataFilter();
            filter.contentNames = 'Fake Name';
            filter.communityId = communityId;
            filter.contentType = 'cms_document';
            filter.language = 'en_US';
            contentData = CsvBulkRegistrationCtrl.GetCMSContentDataByName(filter);
            if(contentData!=null){
            String contentKey =  contentData.contentKey;
            System.assertEquals(contentKey,null, 'contentKey is not equal to NULL');
            }
            System.assertEquals(contentData,null, 'contentData is not equal to NULL');
            Test.stopTest();
        }
    }
    
    @isTest
    static void testGetCMSContentDataByNameError()
    {
    final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
        System.runAs(PORTAL_SYS_ADMIN) {
            String fakecommunityId = '98098EWQ';
            Test.startTest();
            ConnectApi.ManagedContentVersion contentData= new ConnectApi.ManagedContentVersion();
            CsvBulkRegistrationCtrl.CMSContentDataFilter filter = new CsvBulkRegistrationCtrl.CMSContentDataFilter();
            filter.contentNames = 'Fake Name';
            filter.communityId = fakecommunityId;
            filter.contentType = 'cms_doc';
            filter.language = 'en_US';
            contentData = CsvBulkRegistrationCtrl.GetCMSContentDataByName(filter);
            if(contentData!=null){
            String contentKey =  contentData.contentKey;
            System.assertEquals(contentKey,null,'contentKey is not equal to NULL');
            }
            System.assertEquals(contentData,null,'contentData is not equal to NULL');
            Test.stopTest();
        }
    }
    
    public static String str = 'First Name,Last Name,Email,Position,Company Name,Mobile Locale,Mobile Phone,Birthdate,Dietary Requirement,Accessibility Requirement \n' +
    'Aljohn,Motas,aljohn.motas@gmail.com,Position,Company Name,Philippines (the) (63),9350592976,2021 10 10,eqeqeq,qweqeq \n' +
    'Aljohn,Motas,dasdsada@gmail.com,Position,Company Name,Philippines (the) (63),9350592976,2021 10 10,adadadada,zczxcadad'; 
    
    @isTest
    static void testreadCSVFileSucces(){
    final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
        System.runAs(PORTAL_SYS_ADMIN) {
            List<CsvBulkRegistrationCtrl.FieldDataType> csvContent = new List<CsvBulkRegistrationCtrl.FieldDataType>();
            ContentVersion contentVersionInsert = new ContentVersion(
                Title = 'Test',
                PathOnClient = 'Test.csv',
                VersionData = Blob.valueOf(str),
                IsMajorVersion = true
            );
            insert contentVersionInsert;        
            Id getId = [SELECT ContentDocumentId 
                        FROM ContentVersion 
                        WHERE Id =:contentVersionInsert.id 
                        AND isLatest=true].ContentDocumentId;
            Test.startTest();
            csvContent = CsvBulkRegistrationCtrl.readCSVFile(getId);
            System.assert(!csvContent.isEmpty(), 'pass');
            Test.stopTest();
        }
    }
    
    
}
