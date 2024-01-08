/**
 * @description Mock DAO class for EmailTemplate
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
@isTest
public inherited sharing class EmailTemplatesDAOMock extends DmlBaseMock implements IEmailTemplatesDAO{
    public Map<Id, EmailTemplate> emailTemplateMap;

    public EmailTemplatesDAOMock() {
        super(new Map<Id, EmailTemplate>(), Schema.EmailTemplate.SObjectType);
        this.emailTemplateMap = (Map<Id, EmailTemplate>) super.records;
    }

    public Schema.SObjectType getSObjectType() {
        return EmailTemplate.SObjectType;
    }

    public List<EmailTemplate> getEmailTemplatesByNameSet(
        Set<String> nameSet,
		AccessLevel accessLevel 
    ) {
        List<EmailTemplate> emailTempList = new List<EmailTemplate>();

        for (EmailTemplate record : emailTemplateMap.values()) {
            if (nameSet.contains(record.Name)) {
                emailTempList.add(record);
            }
        }

        return emailTempList;
    }

    public List<EmailTemplate> getEmailTemplatesByDeveloperNameSet(
        Set<String> developerNameSet,
		String accessLevel 
    ) {
        List<EmailTemplate> emailTempList = new List<EmailTemplate>();

        for (EmailTemplate record : emailTemplateMap.values()) {
            if (developerNameSet.contains(record.DeveloperName)) {
                emailTempList.add(record);
            }
        }

        return emailTempList;
    }
}