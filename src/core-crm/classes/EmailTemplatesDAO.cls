/**
 * @description DAO class for EmailTemplate
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | August 31, 2023       | DEPP-6138              | Created file                 |
      |                                |                       |                        |                              |
 */
public with sharing class EmailTemplatesDAO extends DmlBase implements IEmailTemplatesDAO{

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
		String accessLevel   
    ) {
        return Database.query(
            'SELECT Name, Subject, HtmlValue, Body ' +
              'FROM EmailTemplate ' +
             'WHERE Name IN: nameSet WITH ' +
             String.escapeSingleQuotes(accessLevel)
        );
    }
}