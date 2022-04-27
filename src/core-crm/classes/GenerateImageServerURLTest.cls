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
@IsTest(SeeAllData = false)
private class GenerateImageServerURLTest {
    
    private static final String BADGE_LOGO = System.Label.DOC_Badge_Logo;
    private static final String QUTEX = System.Label.QUTeX;
    private static User currentUser = TestDataFactory.createUserRecords(1, QUTEX).iterator().next(); 
    private static final String ORG_ID = UserInfo.getOrganizationId();

    @IsTest
    private static void generateURLTest(){
        System.runAs(currentUser){
            String expectedURL = System.URL.getSalesforceBaseUrl().toExternalForm().replace(
                '.my.salesforce.com',
                '--c.documentforce.com/file-asset-public/'
            ) + BADGE_LOGO + '?oid=' + ORG_ID;

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

