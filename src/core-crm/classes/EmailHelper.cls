/**
 * @description Utility class for Email Helper
 *
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | marygrace.li@qut.edu.au        | April 4, 2022         | DEPP-1479              | Created file                 |
      |                                |                       |                        |                              |
 */
public class EmailHelper {

    private static String setBodyValues(string body,Map<String,String> params){
        if(params!=null && params.size()>0){
            for(String key :params.keySet()){
                string val=params.get(key);
                body=body.replace(key,val);
                system.debug('body:'+body);
            }
        }
        return body;
    }
    
    
    public static Messaging.EmailFileAttachment attachementBuilder(string fileName,string emailHtml,Map<String,String> emailContent)
    {
        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
        attach.setContentType('application/pdf');
        attach.setFileName(fileName);
        attach.setInline(true);
       	String body=emailHtml;
        body=setBodyValues(body,emailContent);
        attach.Body = Blob.toPDF(body);
        return attach;
    }
    
    public static Messaging.SingleEmailMessage emailBuilder(String email,string subject,string emailHtml,Map<String,String> emailContent)
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setUseSignature(false);
        mail.setToAddresses(new string[]{email});
        mail.setSubject(subject);
       	String body=emailHtml;
        body=setBodyValues(body,emailContent);
        mail.setHtmlBody(body);
        return mail;
    }
}