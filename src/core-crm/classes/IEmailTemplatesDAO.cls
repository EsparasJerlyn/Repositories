/**
 * @description Interface for EmailTemplatesDAO
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
 *    |--------------------------------|-----------------------|------------------------|------------------------------|
 *    | eccarius.munoz                 | August 31, 2023       | DEPP-6138              | Created file                 |
 *    |                                |                       |                        |                              |
 */
public interface IEmailTemplatesDAO extends DmlInterface{
    List<EmailTemplate> getEmailTemplatesByNameSet(
        Set<String> templateNames, 
        AccessLevel accessLevel 
    );
    List<EmailTemplate> getEmailTemplatesByDeveloperNameSet(
        Set<String> developerNameSet,
		String accessLevel   
    );
}