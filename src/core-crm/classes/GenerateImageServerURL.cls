/**
 * @description Class used by flow to generate Image Server URL from File Assets
 * 
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | angelika.j.s.galang       | April 21, 2021        | DEPP-1481    | Created file                                | 
      |                           |                       |              |                                             | 
 */

public class GenerateImageServerURL{

    private static final String ORG_ID = UserInfo.getOrganizationId();

    /**
    * @description Invocable method for the flow to generate image URL
    * @param imageInfos - list of image information
    * @return imageURLs - list of generated URLs
    */
    @InvocableMethod(Label='Generate Image Server URL' Description='Retrieve URL of Image from File Assets')
    public static List<ImageURL> generateURL(List<ImageInfo> imageInfos){
        List<ImageURL> imageURLs = new List<ImageURL>();
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm().replace(
            '.my.salesforce.com',
            '--c.documentforce.com/file-asset-public/'
        );
        for(ImageInfo imageInfo : imageInfos){
            ImageURL img = new ImageURL();
            img.imageUrl =
                baseUrl + imageInfo.imageName +
                '?oid=' + ORG_ID;
            imageURLs.add(img); 
        }
        return imageURLs;
    }

    public class ImageInfo{
        @InvocableVariable(label='Image Name' required=true) @AuraEnabled
        public String imageName;
    }

    public class ImageURL{
        @InvocableVariable @AuraEnabled
        public String imageUrl;
    }
}
