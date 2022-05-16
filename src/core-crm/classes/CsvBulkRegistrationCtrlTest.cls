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
*/

@isTest(SeeAllData=false)
public class CsvBulkRegistrationCtrlTest {
	  
    @isTest
    static void testGetCMSContentDataByNameFailed()
    {
        List<NetworkMember> communityIds = [SELECT NetworkId FROM NetworkMember limit 1];
        String communityId = communityIds[0].NetworkId;
        Test.startTest();
        ConnectApi.ManagedContentVersion ContentData= new ConnectApi.ManagedContentVersion();
        ContentData= CsvBulkRegistrationCtrl.GetCMSContentDataByName('Fake Name',communityId,'cms_document','en_US');
        if(ContentData!=null){
        String contentKey =  ContentData.contentKey;
        System.assertEquals(contentKey,null, 'contentKey is not equal to NULL');            
        }
        System.assertEquals(ContentData,null, 'ContentData is not equal to NULL');            
        Test.stopTest();
    }
    
    @isTest
    static void testGetCMSContentDataByNameError()
    {
        String FakecommunityId = '98098EWQ';
        Test.startTest();
        ConnectApi.ManagedContentVersion ContentData= new ConnectApi.ManagedContentVersion();
        ContentData= CsvBulkRegistrationCtrl.GetCMSContentDataByName('Fake Name',FakecommunityId,'cms_doc','en_US');
        if(ContentData!=null){
        String contentKey =  ContentData.contentKey;
        System.assertEquals(contentKey,null,'contentKey is not equal to NULL');            
        }
        System.assertEquals(ContentData,null,'ContentData is not equal to NULL');            
        Test.stopTest();
    }
    
    public static String str = 'Salutation,First Name,Middle Name,Last Name,Suffix,Email,Mobile Phone,Phone,Birthdate \n' +
    'Mr,Aljohn,P,Motas,jr,aljohn.motas@gmail.com,9350592976,321414,2021 10 10 \n' +
    'ASD,Aljohn,P,Motas,jr,dasdsada,(935) 959-2321,9350592976,2021 10 10';
    
    @isTest
    static void testreadCSVFileSucces(){
        List<CsvBulkRegistrationCtrl.FieldDataType> cSVContent = new List<CsvBulkRegistrationCtrl.FieldDataType>();
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
        cSVContent = CsvBulkRegistrationCtrl.readCSVFile(getId);
        System.assert(!cSVContent.isEmpty(), 'pass');
	    Test.stopTest();
    }
    
    
}