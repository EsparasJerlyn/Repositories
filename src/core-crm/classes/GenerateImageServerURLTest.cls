/**
 * @description Test class for GenerateImageServerURL 
 *
 * @see GenerateImageServerURL
 * 
 * @author Accenture
 *      
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                  |
      |---------------------------|-----------------------|----------------------|---------------------------------|
      | angelika.j.s.galang       | April 21, 2022        | DEPP-1481            | Created file                    | 
*/
@isTest
private class GenerateImageServerURLTest {
    
    private static final String BADGE_LOGO = System.Label.DOC_Badge_Logo;
    private static final String ORG_ID = UserInfo.getOrganizationId();

    @TestSetup
    static void makeData(){
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

    @isTest
    private static void generateURLTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            String expectedURL = System.URL.getOrgDomainUrl().toExternalForm() + '/file-asset-public/'  + BADGE_LOGO + '?oid=' + ORG_ID;

            GenerateImageServerURL.ImageInfo imageInfo = new GenerateImageServerURL.ImageInfo();
            imageInfo.imageName = BADGE_LOGO;
            List<GenerateImageServerURL.ImageInfo> imageInfos = new List<GenerateImageServerURL.ImageInfo>{imageInfo};
            
            Test.startTest();
            List<GenerateImageServerURL.ImageURL> imageURLs = GenerateImageServerURL.generateURL(imageInfos);
            Test.stopTest();
            System.assertEquals(expectedURL,imageURLs[0].imageUrl, 'Image URL not as expected');
        }
    }
}
