/**
 * @description Utility class for Email Helper
 *
 * @author Accenture
 * 
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                           |
      |--------------------------------|-----------------------|------------------------|------------------------------------------|
      | marygrace.li@qut.edu.au        | April 4, 2022         | DEPP-1479              | Created file                             |
      | angelika.j.s.galang            | April 22, 2022        | DEPP-2156              | Added documentation and modified methods |
      | marygrace.li@qut.edu.au        | July 20, 2022         | DEPP-3085              | Added new method for email w/o banner    |
      | alexander.cadalin              | March 23, 2023        | n/a                    | PMD - ExcessiveParameterList             |
 */
public class EmailHelper {

    private static final Map<String,String> EMAIL_LETTERHEAD = new Map<String,String>{
        'header' => System.Label.DOC_Email_Header,
        'footer' => System.Label.DOC_Email_Footer
    };

    /**
    * @description sets mergeField tags with values in email body
    * @param body - body of the email
    * @param params - parameters to be updated with values
    * @return string containing updated email body
    */
    public static String setBodyValues(
        String body,
        Map<String,String> params,
        Boolean setHeaderAndFooter
    ){
        if(params!=null && params.size()>0){
            for(String key :params.keySet()){
                string val=params.get(key);
                body=body.replace(key,val);
            }
        }
        return setHeaderAndFooter ? addHeaderAndFooter(body) : body;
    }

    /**
    * @description adds header and footer to email content
    * @param emailBody - email body to be modified
    * @return updated email body
    */
    public static String addHeaderAndFooter(String emailBody){
        List<GenerateImageServerURL.ImageInfo> imageInfos = new List<GenerateImageServerURL.ImageInfo>();
        for(String emailLetterhead : EMAIL_LETTERHEAD.values()){
            GenerateImageServerURL.ImageInfo imageInfo = new GenerateImageServerURL.ImageInfo();
            imageInfo.imageName = emailLetterhead;
            imageInfos.add(imageInfo);
        }
        List<GenerateImageServerURL.ImageURL> imageURLs = GenerateImageServerURL.generateURL(imageInfos);

        String emailHeaderTag =
            '<!--[if mso]><center><table><tr><td width="640"><![endif]-->' +
            '<div style="max-width:640px; margin:0 auto;">' +
            '<img alt="' + EMAIL_LETTERHEAD.get('header') + '" title="' + EMAIL_LETTERHEAD.get('header') + '"' +
            'src="' + imageURLs[0].imageUrl + '"/><br /><br />';
        String emailFooterTag =
            '<br /><br /><img alt="' + EMAIL_LETTERHEAD.get('footer') + '" title="' + EMAIL_LETTERHEAD.get('footer') + '"' +
            'src="' + imageURLs[1].imageUrl + '"/>' +
            '</div>' +
            '<!--[if mso]></td></tr></table></center><![endif]-->';

        return emailHeaderTag + emailBody + emailFooterTag;
    }
}