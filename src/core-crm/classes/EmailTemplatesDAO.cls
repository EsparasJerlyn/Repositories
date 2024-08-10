/**
 * @description DAO class for EmailTemplate
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
public without sharing class EmailTemplatesDAO extends DmlBase implements IEmailTemplatesDAO{

    //Add Template Names here
    public static final String TEMPLATE_NURTURE_MANAGEMENT_DOM = 'Nurture Management Email - Domestic'; 
    public static final String TEMPLATE_NURTURE_MANAGEMENT_INT = 'Nurture Management Email - International';

    public Schema.SObjectType getSObjectType(){
		return EmailTemplate.SObjectType;
	}

    public static IEmailTemplatesDAO newInstance(){
		return (IEmailTemplatesDAO) ImplementationSelector.DAO.newInstance(EmailTemplate.SObjectType);
	}

    public List<EmailTemplate> getEmailTemplatesByNameSet(
        Set<String> nameSet,
		AccessLevel accessLevel   
    ) {
        return Database.query(
            'SELECT Id, Name, Subject, HtmlValue, Body ' +
              'FROM EmailTemplate ' +
             'WHERE Name IN: nameSet ',
             accessLevel
        );
    }

    public List<EmailTemplate> getEmailTemplatesByDeveloperNameSet(
        Set<String> developerNameSet,
		String accessLevel   
    ) {
        return Database.query(
            'SELECT Name, Subject, HtmlValue, Body, DeveloperName ' +
              'FROM EmailTemplate ' +
             'WHERE DeveloperName IN: developerNameSet WITH ' +
             String.escapeSingleQuotes(accessLevel)
        );
    }
}
