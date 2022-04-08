/**
 * @description Utility class for Email Template Selector
 *
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | marygrace.li@qut.edu.au        | April 4, 2022         | DEPP-1479              | Created file                 |
      |                                |                       |                        |                              |
 */
public class EmailTemplateSelector {

    public static EmailTemplate getEmailTemplate(string name)
    {  
        return [Select Id,Name,Subject,HtmlValue,Body from EmailTemplate where name=:name LIMIT 1];
    }
}